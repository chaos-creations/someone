# Baystation 12 universe

The Baystation 12 universe (`/datum/universe/bay12`). Its `code/` mirrors upstream's `code/` like
`modular_chaos/code/` does and is listed in `modular_chaos/includes.dm`; `icons/` and `sound/` hold its assets.

## Sources

| Repository | What is taken |
|---|---|
| [baystation12/baystation12](https://github.com/baystation12/baystation12) | code, sprites (selectively) |
| [Proxima-Project/Proxi-BoS-Bay12](https://github.com/Proxima-Project/Proxi-BoS-Bay12) | code, sprites (selectively), maps (Cadaab, Castelnau) |
| [discordia-space/CEV-Eris](https://github.com/discordia-space/CEV-Eris) | sprites, maybe code |
| [sojourn-13/sojourn-station](https://github.com/sojourn-13/sojourn-station) (a CEV-Eris fork) | sprites |

Proxi-BoS-Bay12 is a Baystation 12 downstream, so most of the Baystation 12 content here came through it, from
branch `dev`, commit `409a1d918c7fc99c162104fe77fd0ebf1ddb695d` (2023-07-14). The Sojourn Station files are from
commit `c4d39bd4efea1cf25a61a39474b3835ade953bcd`.

## License

As in all four sources and upstream, the code is under the AGPL-3.0 and the assets under
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), by the contributors of the source they come from.
Changes to the assets must stay under the same license.

## What is taken

Assets are taken only for what the universe needs, not everything the source's maps use:

- what the code here names (the Vox, the rigs and their modules);
- the Vox species: body, masks, hair, cyberlimbs, on-mob sheets, clothing and props;
- Castelnau and Cadaab: the files of the maps' own folders in Proxi-BoS-Bay12 (`maps/castelnau/`,
  `maps/away/cadaab/`), not the base Baystation 12 sprites the maps also place;
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
  floors and walls in `icons/turf/floors/` and `icons/turf/walls/`, areas in `icons/turf/area_<map>.dmi`;
- the ambience of a map in `sound/ambience/<map>/`, the rest of the sounds in the folders they have in the source.

File names are lowercase. Where two sources, or two layers of Proxi-BoS-Bay12 (BoS, BoH, Ark, Proxima, Mithra on top
of Baystation 12), have a file of the same kind, the name carries the source or layer: `uniforms.dmi` is the base
Baystation 12 one, `uniforms_bos.dmi` the BoS one and `rig_modules_sojourn.dmi` the Sojourn Station one.

`asset_sources.json` maps every file from Proxi-BoS-Bay12 to its path in the source, in the source's own case.

Assets are byte-for-byte copies, except that duplicate icon states, which the dmi test of the CI rejects, are removed:
BYOND always uses the first state of a name, so only the later duplicates go and the game shows the same.

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
