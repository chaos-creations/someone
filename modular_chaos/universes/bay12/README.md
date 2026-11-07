# Baystation 12 universe

The Baystation 12 universe (`/datum/universe/bay12`): its code, icons and sounds, ported from
[Proxima-Project/Proxi-BoS-Bay12](https://github.com/Proxima-Project/Proxi-BoS-Bay12), branch `dev`, commit
`409a1d918c7fc99c162104fe77fd0ebf1ddb695d` (2023-07-14).

## Code

`code/` mirrors upstream's `code/` like `modular_chaos/code/` does, and its files are listed in
`modular_chaos/includes.dm`. It is included after `modular_chaos/code/`, so it can use the fork's defines and
override its procs; the fork's own code can't use the defines of this folder (its unit tests use the types only).

So far it has the Vox: the species with its organs, Vox-pidgin, the shriek, the quills, the playable race with the
five arkships as origins, their clothing, space gear, survival kit, holy books and structures, and the slug. It also
adds what the Vox need from upstream's systems:

- `/obj/item/clothing/var/species_restricted`, as in Baystation 12: the Vox wear only their own gloves, footwear and
  masks;
- the Vox sprite sheets on the base types of clothing, like upstream's monkey ones, and a fallback to the human sprite
  for a state a sheet doesn't have (`/datum/species/var/sprite_sheet_fallback`);
- breathing only some gases and being poisoned by others (`breathable_gases`, `poisonous_gases`), the survival gear a
  species gets after its equipment preset, the languages it always speaks, and eyes in an icon of its own (`eye_icon`).

Not ported yet: the Vox weapons (and the rig modules with weapons), the rigs, and what the gizzard (eating matter),
the cortical stack (the backup of the mind) and the hindtongue (speaking Vox-pidgin) do; the organs are there.

## License

The assets are under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), like upstream's, by the
contributors of Baystation 12 and the Proxima Project. Changes to them must stay under the same license. The code is
under the AGPL-3.0, like the source and upstream.

## Layout

`icons/` and `sound/` are sorted by category the way upstream's are:

- clothing in `icons/obj/items/clothing/<kind>/` and its on-mob sprites in `icons/mob/humans/onmob/clothing/<slot>/`,
  with the clothing of a faction or a map in `<kind>_by_faction/<faction>.dmi` and `<kind>_by_map/<map>.dmi`
  (`ftu`, `paroled`, `regulators`, `syndicate` of Castelnau, `scg`, `terran`, `lordania`, `iccgn_*`; `castelnau`,
  `cadaab`);
- in-hand sprites in `icons/mob/humans/onmob/inhands/` as `<name>_lefthand.dmi` and `<name>_righthand.dmi`;
- the Vox in `icons/mob/humans/species/vox/` (on-mob sheets in its `onmob/`) and their clothing in
  `icons/obj/items/clothing/vox/`;
- items in `icons/obj/items/` (`food/`, `storage/`, `smoking/`, `weapons/guns/`, `weapons/melee/`), structures and
  props in `icons/obj/structures/` (`machinery/`, `doors/`, `closets/`, `props/`), pipes in `icons/obj/pipes/`,
  floors and walls in `icons/turf/floors/` and `icons/turf/walls/`, areas in `icons/turf/area_<map>.dmi`;
- the Cadaab ambience in `sound/ambience/cadaab/` and the Voronezh one in `sound/ambience/voronezh/`, the rest of the sounds in the folders they have in the source.

The source builds its content in layers on top of Baystation 12 (BoS, BoH, Ark, Proxima, Mithra). Where a layer has
a file of the same kind as the base one, its name carries the layer: `uniforms.dmi` is the base Bay12 one and
`uniforms_bos.dmi` the BoS one.

`asset_sources.json` lists for every file here its path in the source, in the source's own case.

## What is here

Everything the following maps of the source need, found from the types the maps place, the types the maps' code
names (jobs, outfits, loadout) and everything those spawn (closet and storage contents, vendor products, random
spawners):

- `maps/castelnau` (both the space and the planetside Cadaab variants, with the admin and transit levels)
- `maps/away/voxship`
- `maps/away/solship`
- `maps/away/cadaab`
- `maps/torch` (the six decks of the Torch with the admin and transit levels, and the Voronezh in `voronezh/`, which
  the source has in the folder but includes in no map)

For each such type the whole `.dmi` files are taken: its `icon`, the icons its vars name (`item_icons`,
`sprite_sheets`, `icon_override`, overlays) and, for items, the default on-mob icons of the source
(`icons/mob/onmob/`, `icons/mob/onmob/items/`). The sounds are the ones these types' vars and the maps' code name.

The Vox species is here in full: body, damage and blood masks, hair, cyberlimbs, the Vox on-mob sheets of clothing
and their voice (`sound/voice/shriek1.ogg`).

Not taken: the on-mob sheets of the other species (Unathi, Skrell, GAS, mantids, Adherent, monkeys) and the Vox
Armalis (their body, on-mob sheets, tall template and shriek). Of the away sites the Torch and Castelnau include,
only the ones above.

## Changes from the source

Files are renamed and moved as above, with lowercase names (the source names some in mixed case,
`sound/weapons/Genhit.ogg`).

The source has duplicate icon states in some files (`icons/mob/onmob/onmob_under.dmi`, `icons/obj/drinks.dmi` and 32
more), which the dmi test of the CI rejects. BYOND always uses the first state of a name, so the later duplicates
are removed; what the game shows is the same. Every other file is a byte-for-byte copy.
