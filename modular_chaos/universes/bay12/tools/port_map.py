"""Ports a Baystation 12 map to this universe: lists what it needs and converts its .dmm files.

    python port_map.py inventory <bay checkout> [--map torch] [--out report.tsv]
    python port_map.py convert <bay checkout> [--map torch] [--out map.dmm]
    python port_map.py areas <bay checkout> [--map torch] [--out areas.dm]

Both read bay_types.txt next to this script, the table of which fork type each Bay type becomes (see its header).

inventory lists every Bay type the map needs: the types placed on it, and what they bring along, found in the Bay
code: the contents of closets (WillContain()), random spawners (spawn_choices()), vendors (products), storage
(startswith) and every other var of a type that names a type (a gun's magazine_type, a rig's modules). It writes a
TSV with the status of each one (ported, skipped, or still to do) and prints a summary by category.

convert stacks the map's z-levels into one TGM .dmm, from the lowest level up, as the fork's multi-z maps are. Types
the table skips are dropped; types it does not cover yet, or whose fork type does not exist, are dropped too and
reported, so the result always compiles. A tile left without a turf or area gets the fallbacks of the table. Only the
vars of TRANSFERRED_VARS and those a rule of the table lists are kept from the var edits of the map.

areas writes the DM of the map's areas: the Bay area types it places and their parents, under a root of their own
(AREA_ROOTS), with the name, icon, sound environment and power the source gives them. It adds the icons of the areas
the fork's icons/turf/areas.dmi lacks, and reports the ones it has with other sprites.

Needs bidict (for tools/mapmerge2) and Python 3.10 or newer; areas also needs Pillow.
"""

import argparse
import collections
import csv
import os
import re
import sys

SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
REPOSITORY = os.path.normpath(os.path.join(SCRIPT_DIRECTORY, "..", "..", "..", ".."))
sys.path.insert(0, os.path.join(REPOSITORY, "tools"))
from mapmerge2 import dmm  # noqa: E402

TYPES_TABLE = os.path.join(SCRIPT_DIRECTORY, "bay_types.txt")

# The .dmm files of each map, from the lowest z-level up, relative to the Bay checkout
MAPS = {
    "torch": [
        "maps/torch/torch1_deck5.dmm",
        "maps/torch/torch2_deck4.dmm",
        "maps/torch/torch3_deck3.dmm",
        "maps/torch/torch4_deck2.dmm",
        "maps/torch/torch5_deck1.dmm",
        "maps/torch/torch6_bridge.dmm",
    ],
}

# The Bay code a map's types are looked up in, relative to the Bay checkout: the shared code, and the map's own
BAY_CODE = {
    "torch": ["code", "packs", "maps/torch"],
}

# The root the areas of each map go under, and the name and power network of the root
AREA_ROOTS = {
    "torch": ("/area/torch", "SEV Torch", "torch"),
}

# Sound environments of the source (code/game/sound.dm there) and the CM define of the same environment
SOUND_ENVIRONMENTS = {
    "STANDARD_STATION": "SOUND_ENVIRONMENT_STONEROOM",
    "LARGE_ENCLOSED": "SOUND_ENVIRONMENT_HANGAR",
    "SMALL_ENCLOSED": "SOUND_ENVIRONMENT_BATHROOM",
    "TUNNEL_ENCLOSED": "SOUND_ENVIRONMENT_CAVE",
    "LARGE_SOFTFLOOR": "SOUND_ENVIRONMENT_CARPETED_HALLWAY",
    "MEDIUM_SOFTFLOOR": "SOUND_ENVIRONMENT_LIVINGROOM",
    "SMALL_SOFTFLOOR": "SOUND_ENVIRONMENT_ROOM",
    "ASTEROID": "SOUND_ENVIRONMENT_CAVE",
    "SPACE": "SOUND_ENVIRONMENT_UNDERWATER",
    "PLAIN": "SOUND_ENVIRONMENT_PLAIN",
    "ARENA": "SOUND_ENVIRONMENT_ARENA",
    "AUDITORIUM": "SOUND_ENVIRONMENT_AUDITORIUM",
    "CONCERT_HALL": "SOUND_ENVIRONMENT_CONCERT_HALL",
    "FOREST": "SOUND_ENVIRONMENT_FOREST",
}

# The fork's file of area icons, which the areas of every map share
AREA_ICONS = os.path.join(SCRIPT_DIRECTORY, "..", "icons", "turf", "areas.dmi")

# The fork code the converted types are checked against, relative to this repository
FORK_CODE = ["code", "modular_chaos"]

# Var edits of the map kept on every converted atom; the others need a rule of the table that names them
TRANSFERRED_VARS = {"dir", "pixel_x", "pixel_y", "pixel_w", "pixel_z", "name", "desc", "color"}

# Procs whose type paths are what an atom spawns, so what the map needs
CONTENT_PROCS = {"WillContain", "spawn_choices", "create_objects_in_loc"}

# Vars whose type paths are not what an atom brings along but what it accepts or refuses
NON_CONTENT_VARS = {
    "parent_type", "can_hold", "cant_hold", "allowed", "accepted_types", "blacklist", "whitelist", "valid_types",
    "restricted_types", "req_type", "required_type", "can_be_inserted", "storage_types", "holster_types",
    "attachable_types", "allowed_types", "banned_types", "restricted_hardpoints", "move_intents", "default_move_intent",
    "contents_allowed", "can_be_placed_into", "abstract_type", "preserve_items", "shackled_verbs",
}

# A type path in code; proc and verb paths are left out by type_paths()
PATH_PATTERN = re.compile(r"(?<![\w'\"/.])(/(?:obj|mob|turf|area)(?:/\w+)+)")
DEFINITION_PATTERN = re.compile(r"^(/[\w/]+?)(?:/(proc|verb))?(?:/(\w+))?\s*\(")
TYPE_LINE_PATTERN = re.compile(r"^(/[\w/]+)\s*(?:\{.*)?$")
VAR_PATTERN = re.compile(r"^\t(?:var/(?:[\w/]+/)?)?(\w+)\s*=\s*(.*)$")


def type_paths(code):
    """The type paths code names, without the paths of procs and verbs."""
    return [path for path in PATH_PATTERN.findall(code) if "/proc/" not in path and "/verb/" not in path]


class TypeTree:
    """The types defined in a DM codebase, read without a compiler: absolute paths at the start of a line only."""

    def __init__(self):
        # path -> {var name: raw value}, merged over all the definitions of the type
        self.vars = collections.defaultdict(dict)
        # path -> {proc name: raw body}
        self.procs = collections.defaultdict(dict)
        # path -> file the type is first defined in
        self.files = {}
        # path -> parent path, when parent_type sets it
        self.parents = {}

    def read(self, roots):
        for root in roots:
            for directory, _, files in os.walk(root):
                for name in sorted(files):
                    if name.endswith(".dm"):
                        self.read_file(os.path.join(directory, name))
        return self

    def read_file(self, filename):
        with open(filename, encoding="utf-8", errors="replace") as file:
            lines = file.read().replace("\r\n", "\n").split("\n")
        index = 0
        while index < len(lines):
            line = lines[index]
            index += 1
            if not line.startswith("/") or line.startswith("//"):
                continue
            body = []
            while index < len(lines) and (not lines[index].strip() or lines[index][0] in "\t "
                                          or lines[index].startswith("//") or lines[index].startswith("#")):
                body.append(lines[index])
                index += 1
            definition = DEFINITION_PATTERN.match(line)
            if definition:
                path, _, proc = definition.groups()
                if proc is None:
                    # /type/name() without /proc/: the last segment is the proc
                    path, _, proc = path.rpartition("/")
                if path:
                    self.procs[path][proc] = "\n".join(body)
                    self.files.setdefault(path, filename)
                continue
            type_line = TYPE_LINE_PATTERN.match(line.split("//", 1)[0].rstrip())
            if not type_line:
                continue
            path = type_line.group(1)
            self.files.setdefault(path, filename)
            self.vars[path]  # noqa: B018 - registers the type even without vars
            self.read_vars(path, body)

    def read_vars(self, path, body):
        """Reads the vars of a type block: a line indented once starts a var, deeper ones continue its value."""
        name = None
        value = []
        # The last line only ends the last var
        for line in body + ["\tend"]:
            if line.startswith("\t") and not line.startswith("\t\t") and line.strip():
                if name is not None:
                    self.vars[path][name] = "\n".join(value)
                    if name == "parent_type":
                        self.parents[path] = value[0].split("//", 1)[0].strip()
                var = VAR_PATTERN.match(line)
                name, value = (var.group(1), [var.group(2)]) if var else (None, [])
            elif name is not None:
                value.append(line)

    def exists(self, path):
        return path in self.files

    def parent(self, path):
        if path in self.parents:
            return self.parents[path]
        parent = path.rpartition("/")[0]
        return parent if parent.count("/") >= 1 else None

    def ancestors(self, path):
        """The path and its parents, the path first."""
        chain = []
        while path and path not in chain:
            chain.append(path)
            path = self.parent(path)
        return chain

    def contents(self, path):
        """The types an atom of this type brings along, as {type: where it was found}."""
        found = {}
        chain = self.ancestors(path)
        resolved_vars = {}
        for ancestor in reversed(chain):
            resolved_vars.update(self.vars.get(ancestor, {}))
        for name, value in resolved_vars.items():
            if name in NON_CONTENT_VARS:
                continue
            for content in type_paths(value):
                found.setdefault(content, f"{path}.{name}")
        for proc in CONTENT_PROCS:
            for ancestor in chain:
                if proc in self.procs.get(ancestor, {}):
                    for content in type_paths(self.procs[ancestor][proc]):
                        found.setdefault(content, f"{ancestor}/{proc}()")
                    break
        found.pop(path, None)
        return found


class TypesTable:
    """bay_types.txt: which fork type each Bay type becomes."""

    def __init__(self, filename):
        # Bay path -> (fork path or None when skipped, reason, kept vars {Bay var: fork var})
        self.exact = {}
        # Bay prefix -> the same, for the rules ending in /*
        self.prefixes = {}
        self.fallbacks = {}
        with open(filename, encoding="utf-8") as file:
            for number, line in enumerate(file, 1):
                line = line.split("#", 1)[0].strip()
                if not line:
                    continue
                words = line.split()
                if words[0].startswith("@"):
                    self.fallbacks[words[0][1:]] = words[1]
                    continue
                if len(words) < 2:
                    sys.exit(f"{filename}:{number}: a rule needs a Bay type and a fork type or 'skip'")
                bay, fork, extra = words[0], words[1], words[2:]
                if fork == "skip":
                    rule = (None, " ".join(extra), {})
                else:
                    kept = {}
                    for word in extra:
                        source, _, target = word.partition(">")
                        target = target or source
                        # The TGM reader of CM takes var names of letters and underscores only (var_edits_tgm in
                        # code/modules/mapping/reader.dm); one with a digit makes it give the vars of the line before
                        if not re.fullmatch(r"[A-Za-z_]+", target):
                            sys.exit(f"{filename}:{number}: the map loader cannot read the var {target}")
                        kept[source] = target
                    rule = (fork, "", kept)
                if bay.endswith("/*"):
                    self.prefixes[bay[:-2]] = rule
                else:
                    self.exact[bay] = rule

    def find(self, path):
        """The rule for a Bay type: (fork path or None, reason, kept vars), or None if the table does not cover it."""
        if path in self.exact:
            return self.exact[path]
        prefix = path
        while prefix:
            if prefix in self.prefixes:
                fork, reason, kept = self.prefixes[prefix]
                if fork is None:
                    return self.prefixes[prefix]
                return (fork[:-2] + path[len(prefix):] if fork.endswith("/*") else fork, reason, kept)
            prefix = prefix.rpartition("/")[0]
        return None


def status(table, fork_tree, path):
    """(status, detail) of a Bay type: ported (fork type), skipped (reason), missing (fork type not there) or todo.

    A rule can give several fork types joined by "+", for a Bay type that spawns several things.
    """
    rule = table.find(path)
    if rule is None:
        return "todo", ""
    fork, reason, _ = rule
    if fork is None:
        return "skipped", reason
    for fork_path in fork.split("+"):
        if not fork_tree.exists(fork_path):
            return "missing", fork_path
    return "ported", fork


def placed_types(checkout, map_name):
    """{Bay type: number of tiles it is on} over all the z-levels of the map."""
    counts = collections.Counter()
    for map_file in MAPS[map_name]:
        bay_map = dmm.DMM.from_file(os.path.join(checkout, map_file))
        uses = collections.Counter(bay_map.grid.values())
        for key, tile in bay_map.dictionary.items():
            for atom in tile:
                counts[dmm.parse_map_atom(atom)[0]] += uses[key]
    return counts


def category(path):
    """The group a type is counted in by the summary: /area/x, /turf/x, or /obj/x/y and /mob/x/y."""
    depth = 3 if path.startswith(("/area", "/turf")) else 4
    return "/".join(path.split("/")[:depth])


def inventory(arguments):
    bay_tree = TypeTree().read(os.path.join(arguments.checkout, root) for root in BAY_CODE[arguments.map])
    fork_tree = TypeTree().read(os.path.join(REPOSITORY, root) for root in FORK_CODE)
    table = TypesTable(TYPES_TABLE)
    placed = placed_types(arguments.checkout, arguments.map)

    reached = {path: "placed" for path in placed}
    queue = list(placed)
    while queue:
        path = queue.pop()
        rule = table.find(path)
        if rule is not None and rule[0] is None:
            continue  # skipped, so what it brings along is not needed either
        for content, source in bay_tree.contents(path).items():
            if content not in reached:
                reached[content] = source
                queue.append(content)

    rows = []
    summary = collections.defaultdict(collections.Counter)
    for path in sorted(reached):
        state, detail = status(table, fork_tree, path)
        if not bay_tree.exists(path) and state == "todo":
            state = "unknown"
        rows.append((path, state, detail, placed.get(path, 0), reached[path],
                     os.path.relpath(bay_tree.files[path], arguments.checkout).replace("\\", "/")
                     if path in bay_tree.files else ""))
        summary[category(path)][state] += 1

    with open(arguments.out, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file, delimiter="\t", lineterminator="\n")
        writer.writerow(["bay_type", "status", "fork_type_or_reason", "tiles", "reached_via", "bay_file"])
        writer.writerows(rows)

    states = ["ported", "skipped", "missing", "todo", "unknown"]
    print(f"{'category':45}" + "".join(f"{state:>9}" for state in states))
    totals = collections.Counter()
    for name in sorted(summary):
        totals.update(summary[name])
        print(f"{name:45}" + "".join(f"{summary[name][state]:>9}" for state in states))
    print(f"{'total':45}" + "".join(f"{totals[state]:>9}" for state in states))
    print(f"{len(rows)} types, written to {arguments.out}")


def convert_atom(table, fork_tree, atom, dropped):
    """The fork atoms for a Bay atom of the map, none if it is dropped (then added to dropped, unless skipped).

    The kept var edits go on the first of them.
    """
    path, bay_vars = dmm.parse_map_atom(atom)
    state, detail = status(table, fork_tree, path)
    if state != "ported":
        if state != "skipped":
            dropped.append((state, path, detail))
        return []
    kept = {name: name for name in TRANSFERRED_VARS}
    kept.update(table.find(path)[2])
    fork_vars = [(kept[name], value) for name, value in bay_vars.items() if name in kept]
    first, *rest = detail.split("+")
    if fork_vars:
        first += "{" + ";".join(f"{name} = {value}" for name, value in fork_vars) + "}"
    return [first, *rest]


def convert(arguments):
    fork_tree = TypeTree().read(os.path.join(REPOSITORY, root) for root in FORK_CODE)
    table = TypesTable(TYPES_TABLE)
    for fallback in ("turf", "area"):
        if fallback not in table.fallbacks or not fork_tree.exists(table.fallbacks[fallback]):
            sys.exit(f"{TYPES_TABLE}: @{fallback} must name an existing fork type")

    levels = [dmm.DMM.from_file(os.path.join(arguments.checkout, map_file)) for map_file in MAPS[arguments.map]]
    width, height = levels[0].size.x, levels[0].size.y
    result = dmm.DMM(3, dmm.Coordinate(width, height, len(levels)))
    # (state, Bay type, fork type) of the dropped atoms -> number of tiles they were on
    dropped = collections.Counter()
    # Bay tile -> (fork tile, the dropped atoms of the Bay tile)
    converted_tiles = {}
    for z, level in enumerate(levels, 1):
        for (x, y, _), key in level.grid.items():
            bay_tile = level.dictionary[key]
            if bay_tile not in converted_tiles:
                dropped_atoms = []
                atoms = [fork_atom for atom in bay_tile for fork_atom in convert_atom(table, fork_tree, atom, dropped_atoms)]
                movables, turfs, areas = dmm.split_atom_groups(atoms)
                fork_tile = tuple(movables + (turfs[:1] or [table.fallbacks["turf"]])
                                  + (areas[:1] or [table.fallbacks["area"]]))
                converted_tiles[bay_tile] = (fork_tile, dropped_atoms)
            fork_tile, dropped_atoms = converted_tiles[bay_tile]
            dropped.update(dropped_atoms)
            result.set_tile(dmm.Coordinate(x, y, z), fork_tile)
    result.to_file(arguments.out)

    print(f"{arguments.out}: {width}x{height}x{len(levels)}, {len(result.dictionary)} keys")
    if dropped:
        print("Dropped, not covered by the table or without a fork type yet (tiles, type):")
        for (state, path, detail), count in sorted(dropped.items(), key=lambda item: -item[1]):
            print(f"{count:>8} {path}" + (f" -> {detail} (missing)" if state == "missing" else ""))


def first_line(value):
    """The value of a var without what follows its first line, comments included."""
    return value.split("\n", 1)[0].split("//", 1)[0].strip()


def areas(arguments):
    from dmi_files import Dmi

    bay_tree = TypeTree().read(os.path.join(arguments.checkout, root) for root in BAY_CODE[arguments.map])
    placed = placed_types(arguments.checkout, arguments.map)
    root, root_name, powernet = AREA_ROOTS[arguments.map]
    needed = set()
    for path in placed:
        if path.startswith("/area/") and path != "/area/space":
            needed.update(ancestor for ancestor in bay_tree.ancestors(path) if ancestor != "/area")

    blocks = [f"""//Areas of the {root_name} (the areas of maps/{arguments.map}/ and code/game/area/ in the source), written by
//tools/port_map.py areas, which this should be written by again rather than edited: the area types of the source the
//map places and their parents, under {root}, with their names, icons, sound environments and power.

/// Every area of the {root_name}: a ship whose power runs along its cables, as in the source
{root}
	name = "{root_name}"
	icon = 'modular_chaos/universes/bay12/icons/turf/areas.dmi'
	icon_state = "unknown"
	ceiling = CEILING_METAL
	powernet_name = "{powernet}"
	bay_power = TRUE
	sound_environment = SOUND_ENVIRONMENT_STONEROOM
	ambience_exterior = AMBIENCE_ALMAYER
	ceiling_muffle = FALSE
	weather_enabled = FALSE"""]
    icon_states = {"unknown"}
    for path in sorted(needed):
        bay_vars = {name: first_line(value) for name, value in bay_tree.vars.get(path, {}).items()}
        lines = []
        if "name" in bay_vars:
            lines.append(f"name = {bay_vars['name']}")
        if "icon_state" in bay_vars:
            lines.append(f"icon_state = {bay_vars['icon_state']}")
            icon_states.add(bay_vars["icon_state"].strip('"'))
        if "sound_env" in bay_vars:
            environment = SOUND_ENVIRONMENTS.get(bay_vars["sound_env"])
            if environment:
                lines.append(f"sound_environment = {environment}")
            else:
                print(f"{path}: no CM sound environment for {bay_vars['sound_env']}")
        if bay_vars.get("requires_power") in ("0", "FALSE"):
            lines += ["requires_power = FALSE", "unlimited_power = TRUE"]
        if bay_vars.get("always_unpowered") in ("1", "TRUE"):
            lines.append("always_unpowered = TRUE")
        if not lines and not bay_tree.exists(path):
            continue  # a node of the tree only, which DM makes from its subtypes
        blocks.append("\n".join([root + path[len("/area"):]] + [f"\t{line}" for line in lines]))

    with open(arguments.out, "w", newline="\n", encoding="utf-8") as file:
        file.write("\n\n".join(blocks) + "\n")
    print(f"{arguments.out}: {len(blocks)} areas")

    source_icons = Dmi.load(os.path.join(arguments.checkout, "icons", "turf", "areas.dmi"))
    fork_icons = Dmi.load(AREA_ICONS)
    added = []
    for name in sorted(icon_states):
        state = source_icons.get(name)
        if state is None:
            print(f"the source has no area icon \"{name}\"")
            continue
        existing = fork_icons.get(name)
        if existing is None:
            fork_icons.states.append(state)
            added.append(name)
        elif [image.tobytes() for frames in existing.images for image in frames] != \
                [image.tobytes() for frames in state.images for image in frames]:
            print(f"areas.dmi has another \"{name}\" than the source")
    if added:
        fork_icons.save(AREA_ICONS)
    print(f"areas.dmi: {len(added)} icons added")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["inventory", "convert", "areas"])
    parser.add_argument("checkout", help="path of a Baystation 12 checkout")
    parser.add_argument("--map", default="torch", choices=sorted(MAPS))
    parser.add_argument("--out", help="output file (default: <map>_inventory.tsv, <map>.dmm or <map>_areas.dm here)")
    arguments = parser.parse_args()
    commands = {
        "inventory": (inventory, f"{arguments.map}_inventory.tsv"),
        "convert": (convert, f"{arguments.map}.dmm"),
        "areas": (areas, f"{arguments.map}_areas.dm"),
    }
    command, default_out = commands[arguments.command]
    arguments.out = arguments.out or default_out
    command(arguments)


if __name__ == "__main__":
    main()
