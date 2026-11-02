/datum/human_ai_brain
	/// Lines potentially said when an AI enters combat
	var/list/enter_combat_lines = list(
		"CONTACT!",
		"Contact!",
		"SHIT- CONTACT!",
		"CONTACT, FRONT!",
		"WE GOT CONTACT!",
		"Look alive!",
		"GUNS UP!",
		"There!",
		"Over there!",
		"OPEN FIRE!",
		"Open fire!",
		"ENGAGE!",
		"Engage!",
		"Weapons free!",
		"Wipe 'em out!",
		"Light 'em up!",
		"Cut 'em down!",
		"Fuck 'em up!",
		"WASTE THE MOTHERFUCKERS!",
		"Kill that fucker!",
		"Ice that fucker!",
		"Let's rock!",
		"Eat shit!",
		"Die, you son of a bitch!",
		"Get some!",
		"GET SOME!",
		"GET SOME, MOTHERFUCKER!",
		"*warcry",
	)

	/// Lines potentially said when an AI exits combat
	var/list/exit_combat_lines = list(
		"CEASE FIRE!",
		"Cease fire!",
		"Cease your fire!",
		"Hold your fire!",
		"HOLD FIRE!",
		"We're clear!",
		"We clear?",
		"Looks clear!",
		"CLEAR!",
		"Keep your eyes peeled!",
		"Might be more- Keep your eyes peeled.",
	)

	/// Lines potentially said when an AI's squadmate dies
	var/list/squad_member_death_lines = list(
		"FUCK!",
		"SHIT!",
		"CRAP!",
		"MOTHERFUCKER!",
		"GOD DAMN IT!",
		"WE'RE TAKING HITS HERE!",
		"THEY GOT THEM-- RETURN THE FUCKING FAVOUR!",
		"YOU'LL FUCKING PAY, MOTHERFUCKER!",
		"YOU'LL FUCKING PAY, ASSHOLE!",
		"THEY'RE DOWN!",
		"THEY'RE DEAD!",
		"THEY GOT THEM!",
	)

	/// Lines potentially said when an AI throws a grenade
	var/list/grenade_thrown_lines = list(
		"GRENADE!",
		"THROWING GRENADE!",
		"GRENADE, GET CLEAR!",
		"EAT IT, FUCKER!",
		"RETURN TO SENDER!",
		"DELIVERY, MOTHERFUCKER!",
	)

	/// Lines potentially said when an AI reloads a magazine-fed gun
	var/list/reload_lines = list(
		"RELOADING!",
		"Reloading!",
		"Swapping magazines!",
		"Swapping mags!",
		"Changing magazines!",
		"Changing mags!",
		"Cover me, reloading!",
		"NEED COVERING FIRE!",
		"COVER ME!",
		"RED! RED!-- GREEN!",
		"I'M RED!",
		"RED!",
	)

	/// Lines potentially said when an AI reloads a tube-fed gun
	var/list/reload_internal_mag_lines = list(
		"RELOADING!",
		"Reloading!",
		"Cover me, reloading!",
		"NEED COVERING FIRE!",
		"COVER ME!",
		"RED! RED!-- GREEN!",
		"I'M RED!",
		"I NEED A FUCKING SPEEDLOADER- CHRIST!",
		"RED!",
	)

	/// Currently unused
	var/list/need_healing_lines = list(
		"FUCK ME!",
		"FUCK!",
		"SHIT!",
		"CRAP!",
		"MOTHERFUCKER!",
		"GOD DAMN IT!",
		"JESUS CHRIST!",
		"BLEEDING!",
		"MOTHER OF GOD-- NO!",
		"I'M TAKING HITS HERE!",
		"I'M HIT!",
		"I'M HURT!",
		"INJECTOR GOING IN!",
		"INJECTOR IN!",
		"I NEED GAUZE!",
		"SOMEONE PATCH THIS FUCKING HOLE!",
		"NEED MORPHINE!",
	)

	/// What a medic says when they start treating an ally
	var/list/treat_ally_lines = list(
		"HOLD STILL!",
		"I GOT YOU!",
		"STAY WITH ME!",
		"LET ME SEE THAT!",
		"DON'T YOU DIE ON ME!",
		"MEDIC'S HERE!",
		"KEEP PRESSURE ON IT!",
	)

	/// What a medic mutters while patching an ally up
	var/list/treat_ally_fumble_lines = list(
		"WHERE'S THE GAUZE- COME ON!",
		"SHIT, MY HANDS ARE SHAKING!",
		"HOLD THIS- NO, THE OTHER END!",
		"DAMN IT, IT WON'T STICK!",
		"STOP SQUIRMING!",
		"WHERE'S THE BLEEDER?!",
		"COME ON, COME ON...",
		"FUCK, DROPPED IT- GOT IT!",
	)

	/// What a medic says when they are done with an ally
	var/list/treat_ally_done_lines = list(
		"YOU'RE GOOD, GET UP!",
		"PATCHED UP, GET BACK IN THERE!",
		"THAT'LL HOLD!",
		"ALL DONE, I'M READY!",
		"YOU'LL LIVE! READY TO MOVE!",
		"DONE HERE, READY!",
	)

	/// Chance that an AI says a voiceline when entering combat
	var/in_combat_line_chance = 40
	/// Chance that an AI says a voiceline when exiting combat
	var/exit_combat_line_chance = 40
	/// Chance that an AI says a voiceline when a squadmember dies
	var/squad_member_death_line_chance = 20
	/// Chance that an AI says a voiceline when they throw a grenade
	var/grenade_thrown_line_chance = 60
	/// Chance that an AI says a voiceline when they reload a gun
	var/reload_line_chance = 40
	/// Currently unused
	var/need_healing_line_chance = 90
	/// Chance that a medic says a voiceline when they start treating an ally
	var/treat_ally_line_chance = 70
	/// Chance that a medic says a voiceline every time they apply something to an ally
	var/treat_ally_fumble_line_chance = 30
	/// Chance that a medic says a voiceline when they are done with an ally
	var/treat_ally_done_line_chance = 80

/datum/human_ai_brain/proc/say_in_combat_line(chance = in_combat_line_chance)
	if(!length(enter_combat_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(enter_combat_lines))

/datum/human_ai_brain/proc/say_exit_combat_line(chance = exit_combat_line_chance)
	if(!length(exit_combat_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(exit_combat_lines))

/datum/human_ai_brain/proc/on_squad_member_death(mob/living/carbon/human/dead_member)
	if(!length(squad_member_death_lines) || !prob(squad_member_death_line_chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(squad_member_death_lines))

/datum/human_ai_brain/proc/say_grenade_thrown_line(chance = grenade_thrown_line_chance)
	if(!length(grenade_thrown_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(grenade_thrown_lines))

/datum/human_ai_brain/proc/say_reload_line(chance = reload_line_chance)
	if(!length(reload_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit) || !primary_weapon)
		return
	if(istype(primary_weapon.current_mag, /obj/item/ammo_magazine/internal))
		tied_human.say(pick(reload_internal_mag_lines))
	else
		tied_human.say(pick(reload_lines))

/datum/human_ai_brain/proc/say_need_healing_line(chance = need_healing_line_chance)
	if(!length(need_healing_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(need_healing_lines))

/datum/human_ai_brain/proc/say_treat_ally_line(chance = treat_ally_line_chance)
	if(!length(treat_ally_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(treat_ally_lines))

/datum/human_ai_brain/proc/say_treat_ally_fumble_line(chance = treat_ally_fumble_line_chance)
	if(!length(treat_ally_fumble_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(treat_ally_fumble_lines))

/datum/human_ai_brain/proc/say_treat_ally_done_line(chance = treat_ally_done_line_chance)
	if(!length(treat_ally_done_lines) || !prob(chance) || (tied_human.health < tied_human.health_threshold_crit))
		return
	tied_human.say(pick(treat_ally_done_lines))
