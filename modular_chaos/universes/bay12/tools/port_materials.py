"""Ports the material definitions of Baystation 12 (code/modules/materials/definitions/) into this universe.

    python port_materials.py <Baystation 12 checkout>

It writes code/modules/materials/definitions/<file>.dm here, one file per file of the source, with the material types
and the vars of KEPT_VARS: what the materials are (names, colours, sprites, strength) rather than what other systems of
the source do with them. A var whose value names something this universe has not ported (the stacks, the reagents of
chem_products, research levels) is dropped, and listed; when that system is ported, add its vars to KEPT_VARS and run
this again rather than editing the files it writes. Colours given by a define of the source are written as their value,
since the CM defines of the same names are not always the same colours. Procs are not ported; the few the code here
needs are in code/modules/materials/_materials.dm. Sounds a material plays are copied into sound/ and pointed at there.
"""
import os
import re
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
UNIVERSE = os.path.normpath(os.path.join(HERE, ".."))
OUT = os.path.join(UNIVERSE, "code", "modules", "materials", "definitions")

# The vars of /material kept from the definitions, as code/modules/materials/_materials.dm declares them
KEPT_VARS = {
	"name", "display_name", "adjective_name", "use_name", "wall_name", "flags", "sheet_singular_name",
	"sheet_plural_name", "lore_text", "mechanics_text", "antag_text", "hidden_from_codex", "shard_type", "shard_icon",
	"shard_can_repair", "destruction_desc", "icon_colour", "sheet_icon_base", "sheet_icon_reinf",
	"sheet_has_plural_icon", "wall_icon_base", "wall_icon_reinf", "wall_flags", "wall_blend_icons", "door_icon_base", "table_icon_base",
	"table_icon_reinf", "cut_delay", "radioactivity", "ignition_point", "melting_point", "brute_armor", "burn_armor",
	"integrity", "opacity", "explosion_resistance", "conductive", "luminescence", "alloy_materials", "alloy_product",
	"units_per_sheet", "hardness", "weight", "tableslam_noise", "dooropen_noise", "hitsound", "construction_difficulty",
	"ore_name", "ore_desc", "ore_smelts_to", "ore_compresses_to", "ore_result_amount", "ore_spread_chance",
	"ore_scan_icon", "ore_icon_overlay", "sale_price", "value", "is_fusion_fuel", "tans_to",
}

# Defines a kept value may use as they are: those of code/__DEFINES/materials.dm here, and CM's
KEPT_DEFINE = re.compile(r"^(MATERIAL_[A-Z0-9_]+|SHARD_[A-Z_]+|T0C|T20C|TRUE|FALSE|null)$")
# Defines of the source that have other names here, as CM has its own of the same name
RENAMED_DEFINES = {"MATERIAL_WOOD": "BAY_MATERIAL_WOOD"}
# Defines of the source written as their value
VALUE_DEFINE = re.compile(r"^(COLOR_[A-Z0-9_]+|WOOD_COLOR_[A-Z0-9_]+|GLASS_COLOR[A-Z0-9_]*|FLAGS_OFF|PHORON_MINIMUM_BURN_TEMPERATURE)$")

TYPE_LINE = re.compile(r"^(/material[\w/]*)\s*$")
VAR_LINE = re.compile(r"^\t(?:var/)?(\w+)\s*=\s*(.*)$")


def read_defines(checkout):
	"""The defines of the source, name -> value."""
	defines = {"FLAGS_OFF": "0"}
	define_dir = os.path.join(checkout, "code", "__defines")
	for path in sorted(os.listdir(define_dir)):
		with open(os.path.join(define_dir, path), encoding="utf-8") as file:
			for line in file:
				match = re.match(r"#define\s+(\w+)\s+(.+?)\s*(//.*)?$", line)
				if match:
					defines[match.group(1)] = match.group(2)
	return defines


def balanced(text):
	"""Whether the brackets and quotes of a value are closed."""
	depth = 0
	in_string = False
	escaped = False
	for char in text:
		if escaped:
			escaped = False
		elif char == "\\":
			escaped = True
		elif char == '"':
			in_string = not in_string
		elif not in_string and char in "([":
			depth += 1
		elif not in_string and char in ")]":
			depth -= 1
	return depth <= 0 and not in_string


def resolve(value, defines, checkout, dropped, where):
	"""The value as it is written here, or None if it names something not ported."""
	# Strings are kept as they are; the identifiers outside them are checked
	outside = re.sub(r'"(?:[^"\\]|\\.)*"', '""', value, flags=re.S)
	if re.search(r"/(obj|datum|turf|mob|singleton|area)/", outside) or "proc" in outside:
		dropped.append(f"{where}: {value.strip()}")
		return None
	for sound in re.findall(r"'([^']+)'", outside):
		source = os.path.join(checkout, sound)
		if not sound.startswith("sound/") or not os.path.exists(source):
			dropped.append(f"{where}: {value.strip()}")
			return None
		target = os.path.join(UNIVERSE, sound)
		os.makedirs(os.path.dirname(target), exist_ok=True)
		shutil.copyfile(source, target)
		value = value.replace(f"'{sound}'", f"'modular_chaos/universes/bay12/{sound}'")

	def replace(match):
		token = match.group(0)
		if token in RENAMED_DEFINES:
			return RENAMED_DEFINES[token]
		if KEPT_DEFINE.match(token):
			return token
		if VALUE_DEFINE.match(token) and token in defines:
			return defines[token]
		raise KeyError(token)

	try:
		parts = re.split(r'("(?:[^"\\]|\\.)*")', value, flags=re.S)
		for index in range(0, len(parts), 2):
			parts[index] = re.sub(r"\b[A-Z][A-Z0-9_]{2,}\b", replace, parts[index])
	except KeyError as error:
		dropped.append(f"{where}: {value.strip()} ({error.args[0]})")
		return None
	return "".join(parts)


def port_file(path, defines, checkout, dropped):
	"""The DM of the material types of one file of the source."""
	with open(path, encoding="utf-8") as file:
		lines = file.read().split("\n")
	blocks = []
	current = None
	pending = None
	for line in lines:
		if pending is not None:
			pending[1] += "\n" + line
			if balanced(pending[1]):
				current[1].append(pending)
				pending = None
			continue
		type_match = TYPE_LINE.match(line)
		if type_match:
			current = [type_match.group(1), []]
			blocks.append(current)
			continue
		if line and not line[0].isspace():
			current = None  # a proc or anything else at the top level
			continue
		var_match = VAR_LINE.match(line)
		if current is None or not var_match:
			continue
		entry = [var_match.group(1), var_match.group(2)]
		if balanced(entry[1]):
			current[1].append(entry)
		else:
			pending = entry
	out = []
	for path_name, entries in blocks:
		kept = []
		for name, value in entries:
			value = value.split("//", 1)[0].rstrip() if '"' not in value else value.rstrip()
			if name not in KEPT_VARS:
				continue
			resolved = resolve(value, defines, checkout, dropped, f"{path_name}.{name}")
			if resolved is not None:
				kept.append(f"\t{name} = {resolved}")
		out.append("\n".join([path_name] + kept))
	return out


def main():
	if len(sys.argv) < 2:
		sys.exit(__doc__)
	checkout = sys.argv[1]
	source_dir = os.path.join(checkout, "code", "modules", "materials", "definitions")
	defines = read_defines(checkout)
	os.makedirs(OUT, exist_ok=True)
	dropped = []
	for name in sorted(os.listdir(source_dir)):
		if not name.endswith(".dm"):
			continue
		blocks = port_file(os.path.join(source_dir, name), defines, checkout, dropped)
		header = (f"//Materials of Baystation 12 (code/modules/materials/definitions/{name} in the source), written by "
			"tools/port_materials.py,\n//which this should be written by again rather than edited\n\n")
		with open(os.path.join(OUT, name), "w", encoding="utf-8", newline="\n") as file:
			file.write(header + "\n\n".join(blocks) + "\n")
		print(f"{name}: {len(blocks)} materials")
	print(f"{len(dropped)} values dropped (systems not ported):")
	kinds = {}
	for entry in dropped:
		var = entry.split(":", 1)[0].rsplit(".", 1)[1]
		kinds[var] = kinds.get(var, 0) + 1
	for var, count in sorted(kinds.items(), key=lambda item: -item[1]):
		print(f"{count:>5} {var}")


if __name__ == "__main__":
	main()
