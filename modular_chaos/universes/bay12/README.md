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

It also has the rigs (`code/modules/clothing/spacesuits/rig/`): hardsuit control modules worn on the back that deploy
and seal a suit onto the body, with the infantry rig of the Torch (`maps/torch/infantry/hardsuit.dm`) and the Vox rigs
(`code/modules/clothing/spacesuits/rig/suits/vox.dm`, `code/bos/modules/clothing/vox/vox_rig.dm`). They are reworked
for upstream: no access lock, wires, AI control, EMP damage or nanoUI; the suit seals in one action; the modules are
picked from a radial menu and used with two keybindings (unbound by default); the cell is charged by a cable plugged
into an APC, a SMES or a generator; and a storage module (every rig has the smallest) makes the rig a backpack. Their
modules come from Baystation 12 and from [Sojourn Station](https://github.com/sojourn-13/sojourn-station) (a CEV-Eris
downstream): storage, vision, medical, combat (the guns unfold into the hand and fire from the suit's cell, like the
plasma caster of a Yautja) and ninja ones. The maneuvering jets and cooling units aren't ported: upstream has no zero
gravity or overheating for them.

Not ported yet: the Vox weapons other than the rig ones, and what the gizzard (eating matter), the cortical stack (the
backup of the mind) and the hindtongue (speaking Vox-pidgin) do; the organs are there.

## License

The assets are under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), like upstream's, by the
contributors of Baystation 12 and the Proxima Project. Changes to them must stay under the same license. The code is
under the AGPL-3.0, like the source and upstream.

Two sprite files come from Sojourn Station, commit `c4d39bd4efea1cf25a61a39474b3835ade953bcd`, under CC BY-SA 3.0
like the rest of CEV-Eris' assets, by the contributors of CEV-Eris and Sojourn Station:
`icons/obj/items/rig_modules_sojourn.dmi` is its `icons/obj/rig_modules.dmi` and
`icons/mob/humans/onmob/clothing/back/rig_modules_sojourn.dmi` its `icons/mob/rig_modules.dmi`, both byte-for-byte.
`asset_sources.json` lists only the files from Proxi-BoS-Bay12.

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

`icons/obj/items/rigs_infantry.dmi` is made here for the infantry hardsuit and holds all its sprites, worn ones too
(`contained_sprite`): the states of its pieces and back are copied from the clothing and rig sheets of the source,
which keep them as well, and the control module, which has no sprite in the source, is the `ce_rig` of
`icons/obj/rig_modules.dmi` recolored to the grey of the suit: without its stripe and antennas for the infantry one,
with them for the squad leader one, whose back also gets the antennas of the worn `ce_rig`.

The source has duplicate icon states in some files (`icons/mob/onmob/onmob_under.dmi`, `icons/obj/drinks.dmi` and 32
more), which the dmi test of the CI rejects. BYOND always uses the first state of a name, so the later duplicates
are removed; what the game shows is the same. Every other file is a byte-for-byte copy.
