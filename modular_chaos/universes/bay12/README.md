# Baystation 12 universe

The Baystation 12 setting the build targets: its races, origins, species, gear and maps. Its `code/` mirrors upstream's
`code/` like `modular_chaos/code/` does and is listed in `modular_chaos/includes.dm` after it; `icons/` and `sound/` hold
its assets. The races and origins players can pick are listed in `code/_globalvars/global_lists.dm`.

## Sources

| Repository | What is taken |
|---|---|
| [baystation12/baystation12](https://github.com/baystation12/baystation12) | code, sprites (selectively) |
| [Proxima-Project/Proxi-BoS-Bay12](https://github.com/Proxima-Project/Proxi-BoS-Bay12) | code, sprites (selectively), maps (Cadaab, Castelnau) |
| [discordia-space/CEV-Eris](https://github.com/discordia-space/CEV-Eris) | sprites, maybe code |
| [sojourn-13/sojourn-station](https://github.com/sojourn-13/sojourn-station) (a CEV-Eris fork) | sprites |

Proxi-BoS-Bay12 is a Baystation 12 downstream, so most of the Baystation 12 content here came through it, from
branch `dev`, commit `409a1d918c7fc99c162104fe77fd0ebf1ddb695d` (2023-07-14). The Sojourn Station files are from
commit `c4d39bd4efea1cf25a61a39474b3835ade953bcd`. The walls, windows and doors come from Baystation 12 itself, branch `dev`
as of 2026-11-12.

## License

As in all four sources and upstream, the code is under the AGPL-3.0 and the assets under
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), by the contributors of the source they come from.
Changes to the assets must stay under the same license.

## What is taken

Assets are taken only for what the universe needs, not everything the source's maps use:

- what the code here names (the Vox, the rigs and their modules);
- the Vox species: body, masks, hair, cyberlimbs, on-mob sheets, clothing and props;
- Castelnau and Cadaab: the files of the maps' own folders in Proxi-BoS-Bay12 (`maps/castelnau/`,
  `maps/away/cadaab/`), not the base Baystation 12 sprites the maps also place, which become CM counterparts;
- for the Cadaab map, the BoS sprites it places: the city turfs, road decals and street furniture of Inax, posters and
  the noose;
- for the Castelnau map, the base Baystation 12 floor tiles and floor decals it places, which carry the department
  colours of the ship: the tiles with the colour Bay gives their turf baked in (a coloured turf would tint the decals
  on it), and the decals as they are; its walls, carpets, wood and machines became CM counterparts;
- the SEV Torch of Baystation 12 and everything it needs, ported as Bay has it rather than with CM counterparts (see
  "Porting a map"); so far the steel, titanium, osmium-carbide plasteel and walnut walls in the paints it uses and the
  coats of paint that repaint them, windows of plain, reinforced, borosilicate and electrochromic glass on low walls of
  every material, panes and grilles, the airlocks of every department, two tiles wide too, vault, crystal and escape pod
  doors, windoors and brig doors, the morgue door, plastic doors, firedoors, blast doors and shutters, its areas, its
  power grid (see "Power") with its portable generators, solar arrays, power sensors, lights and light switches,
  its door, bolt, blast door and window tint buttons, fire alarms and security cameras, catwalks,
  lattices, railings, handrails, ladders and stairs, its floors
  (plating, tiles, carpets, wood, linoleum, grass, the pool, mainframe and crystal floors, hull plating) with Bay's
  borders and damage overlays, and its floor decals, signs and logos;
- Lordania: its clothing, flags, banner, memorial and statues, from Proxi-BoS-Bay12 commit
  [`e4e6c18`](https://github.com/Proxima-Project/Proxi-BoS-Bay12/commit/e4e6c1845b4e5b9b94017987a96f29eef88436af).

## Layout

`icons/` and `sound/` are sorted by category the way upstream's are:

- clothing in `icons/obj/items/clothing/<kind>/` and its on-mob sprites in `icons/mob/humans/onmob/clothing/<slot>/`,
  with the clothing of a faction or a map in `<kind>_by_faction/<faction>.dmi` and `<kind>_by_map/<map>.dmi`;
- in-hand sprites in `icons/mob/humans/onmob/inhands/` as `<name>_lefthand.dmi` and `<name>_righthand.dmi`;
- a species in `icons/mob/humans/species/<species>/` (on-mob sheets in its `onmob/`) and its own clothing in
  `icons/obj/items/clothing/<species>/`;
- items in `icons/obj/items/` (`food/`, `storage/`, `smoking/`, `weapons/guns/`, `weapons/melee/`), structures and
  props in `icons/obj/structures/` (`machinery/`, `doors/`, `closets/`, `props/`), pipes in `icons/obj/pipes/`,
  floors and walls in `icons/turf/floors/` and `icons/turf/walls/`;
- the sprites maps place are not split by map but kept in shared files by kind: floors in `icons/turf/floors/floors.dmi`,
  floor decals in `icons/turf/floors/decals.dmi`, areas in `icons/turf/areas.dmi`, other decals (graffiti, painted
  signs) in `icons/effects/decals.dmi`, props in `icons/obj/structures/props/props.dmi`, posters and paintings in
  `icons/obj/structures/props/wall_decorations/`. A sprite of another size goes in a file of its own named with the
  size (`props_48x48.dmi`), and a state whose name another map already uses gets a suffix (`engineering_alt`). A floor
  logo that maps put together from pieces they pick by icon_state keeps a file of its own, with the source's states
  (`icons/turf/floors/solgov_floor.dmi`);
- the ambience of a map in `sound/ambience/<map>/`, the rest of the sounds in the folders they have in the source.

File names are lowercase. Where two sources, or two layers of Proxi-BoS-Bay12 (BoS, BoH, Ark, Proxima, Mithra on top
of Baystation 12), have a file of the same kind, the name carries the source or layer: `uniforms.dmi` is the base
Baystation 12 one, `uniforms_bos.dmi` the BoS one and `rig_modules_sojourn.dmi` the Sojourn Station one.

`asset_sources.json` maps every file from Proxi-BoS-Bay12 to its path in the source, in the source's own case, or to a
list of paths when it is put together from several files.

Maps go in this universe's `maps/`: the JSON of a map as `maps/<map>.json`, with
`"map_root": "modular_chaos/universes/bay12/maps/"`, and its files in `maps/map_files/<Map>/`. The map lists that offer
them are `map_config/maps.txt` and `map_config/shipmaps.txt`, in the format of upstream's `map_config/`, loaded after
upstream's (`extra_map_sources` of `/datum/controller/configuration`). The CI tests, lints and compiles these maps like
upstream's, and `tools/deploy.sh` copies both folders. A map that is not public yet goes in `+secret/maps/` instead.
The areas, turfs and props of the maps are in this universe's `code/`.

Assets are copied as they are, except that states nothing here needs are removed, and so are duplicate icon states,
which the dmi test of the CI rejects: BYOND always uses the first state of a name, so only the later duplicates go and
the game shows the same. Merged into a shared file, a state keeps its name unless it clashes (see above). The tent of Cadaab has its states renamed to `tent` and `tent_open` (the closed one had no
name). The worn states of the Lordanian uniforms are renamed the way CM names those of a uniform: without Bay's `_s`,
and with rolled sleeves (`_r_s`) as `_d` and the jacket off (`_d_s`) as `_dj`, so that a uniform rolls and opens.

## Porting a map

`tools/port_map.py` ports a Baystation 12 map (for now the Torch), run with the path of a Baystation 12 checkout and
bidict installed:

- `python port_map.py inventory <checkout>` lists every Bay type the map needs: the ones placed on it and what they
  bring along (the contents of closets, vendors, random spawners and storage, and the types other vars name), with
  the status of each, in a TSV and a summary by category;
- `python port_map.py convert <checkout> --out <file>` stacks the map's decks into one multi-z `.dmm`, from the lowest
  up. Types without a fork counterpart yet are dropped and listed, so the result always loads.
- `python port_map.py areas <checkout> --out <file>` writes the DM of the map's areas, the Bay area tree under a root
  of the map's own (`code/game/area/torch.dm`), and adds their icons to `icons/turf/areas.dmi`.

Both follow `tools/bay_types.txt`, the table of which fork type each Bay type becomes, or why it is skipped: the
overmap, atmospherics, research and development, xenoarchaeology, the AI and cyborgs, and the engine (supermatter and
fusion) are not ported for now. A newly ported Bay type gets its rule there.

`tools/bake_floors.py`, run with the path of a Baystation 12 checkout, adds the floors and floor decals of the ported
maps to the shared `floors.dmi` and `decals.dmi`, the colour Bay gives some floors baked in, and copies the floor
logos. `tools/dmi_files.py` reads and writes the .dmi files for it and for `tools/bake_structures.py`.

## Power

CM has no power grid: every power machine joins the network named by the `powernet_name` of its area, and cables are
only for show. The areas of Bay maps set `bay_power` instead (`code/modules/power/bay_powernet.dm`), and there power
runs along Bay cables as in the source: a power machine joins the network of the cable knot on its turf, an SMES
charges through the terminal next to it from what is left on that network once everything else drew, breaker boxes
join networks, and a cut cable splits its network. The machines themselves are CM ones and take their power from the
APC of their area as on any map, so CM maps keep their power as it was.

Generators there feed their cable knot too, not the APC of their area as CM generators do. Solar panels follow a sun
of their own (`SSbay_sun`, `code/controllers/subsystem/bay_sun.dm`): with no overmap and no stars, it turns around the
ship as the source's does on a map without a star. Fuel and glass are CM sheets until Bay materials are ported.

Lights there are CM fixtures, whose status the CM code that breaks, fixes and replaces lights keeps setting, holding
Bay bulbs of their own colour, the tone of their area (`lighting_tone`). When an APC turns the lights of its area off
on its own to save its cell, they switch to the red emergency light of their bulbs, run off the environment channel.
Bay light switches start off, as in the source, so a room with one is dark until someone turns its lights on.

Bay buttons send to the doors with their `id_tag`, as the radio of the source does, which the doors keep in `id`. Bay
access is not ported yet, so buttons the map limits to some jobs are open to everyone.

## Alert levels

A map can have the alert levels of Bay instead of CM's four: its JSON names their type as `"security_state"`
(`/datum/security_state/default/torchdept` for the Torch's green, violet, orange, blue, red and delta), and
`SSbay_security` sets them up in `GLOB.bay_security_state` (`code/datums/security_state.dm`). They announce themselves
and light the alarms as in the source. CM keeps its own level, which marines, consoles and the self-destruct follow:
each Bay level sets the CM level it stands for (`cm_level`; violet and orange are blue, and delta is red, so it does not
start the CM self-destruct), and CM code that sets the CM level switches the map to the level that answers to it
(`cm_equivalent`), quietly. Admins set any level of the map with "Set Map Alert Level". Maps without one show the CM
level on Bay alarms.

## Walls, windows and doors

Bay draws its walls, low walls, windows and airlocks at runtime from greyscale layers that it colours with the paint of
the type, and the code here does the same: walls take `paint_color`, `stripe_color` and the colour of their material,
windows `frame_color` and `glass_color`, airlocks `door_color`, `stripe_color` and `window_color`. The types are the
paints of the source (`prepainted`, `fleet`, `hull`, the airlocks of each department) with its colours in
`code/__DEFINES/colors.dm`; mappers can repaint a placed one through these vars, or through `color` for walls and
airlocks. Walls and windows keep Bay's smoothing by corners, airlocks and firedoors turn along their walls on their own,
and the opening of airlocks and firedoors plays at 1 ds a frame instead of Bay's 2.

The layers are converted by `tools/bake_structures.py`, run with the path of a Baystation 12 checkout
(`python bake_structures.py <checkout>`, needs Pillow); it overwrites the files it writes. It copies the layers
greyscale into `icons/turf/walls/walls.dmi`, `icons/turf/walls/windows.dmi` and `icons/obj/structures/doors/`, renaming
their states to the CM ones. Each airlock frame (`station`, `external`, `hatch`, `secure`) gets a folder in `airlocks/`
with its frame, lights and the paint layers the source has for it, every layer with every state of the door: they are
overlays without an icon_state, which show the state the door shows. Only the map editor previews are baked with the
colours of the types, in `airlocks/previews.dmi` and windows.dmi; the script holds the same colours for them.

## Rig sprites

A rig gets one `.dmi` of its own with all its sprites, worn ones too (`contained_sprite`), as
`icons/obj/items/rigs_infantry.dmi` does for the infantry rig and the squad leader one. For a rig whose
`icon_state` is `<rig>`:

- the control module is `<rig>` and its worn sprite `<rig>_ba`;
- each piece is `<rig>_<piece>` (`helmet`, `chest`, `gloves`, `boots`), sealed `<rig>_<piece>_sealed`, and worn adds
  the slot suffix of `GLOB.slot_to_contained_sprite_shorthand` (`_he`, `_su`, `_gl`, `_sh`):
  `<rig>_helmet_sealed_he`.

The states are split into two groups, each headed by a divider state like upstream's: a movement state with one
direction and the arrow sprite, named in capitals after the group. `OBJ` has the sprites of the objects (the control
module and the pieces, unsealed and sealed), `ONMOB` the worn ones; several rigs in one file go one after another
inside each group.
