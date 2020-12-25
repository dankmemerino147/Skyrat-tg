GLOBAL_LIST_EMPTY(assaultops_targets)

/datum/game_mode/assaultops
	name = "assault operatives"
	config_tag = "assaultops"
	report_type = "assaultops"
	false_report_weight = 10
	required_players = 30 // 30 players - 3 players to be the nuke ops = 27 players remaining
	required_enemies = 2
	recommended_enemies = 5
	antag_flag = ROLE_ASSAULTOPS
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Syndicate forces are approaching the station in an attempt to occupy it!\n\
	<span class='danger'>Operatives</span>: Subdue all security forces and occupy the station.\n\
	<span class='notice'>Crew</span>: Defend the station from all syndicate assault members and ensure you survive."

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/operatives_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/list/pre_operatives = list()

	var/datum/team/assaultops/assault_team

	var/operative_antag_datum_type = /datum/antagonist/assaultops
	var/leader_antag_datum_type = /datum/antagonist/assaultops/leader

/datum/game_mode/assaultops/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, agents_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_operatives += new_op
			new_op.assigned_role = "Assault Operative"
			new_op.special_role = "Assault Operative"
			log_game("[key_name(new_op)] has been selected as an Assault operative")
		return TRUE
	else
		setup_error = "Not enough assault op candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/assaultops/post_setup()
	//Assign leader
	var/datum/mind/leader_mind = pre_operatives[1]
	var/datum/antagonist/assaultops/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	assault_team = L.assault_team
	//Assign the remaining operatives
	for(var/i = 2 to pre_operatives.len)
		var/datum/mind/assault_mind = pre_operatives[i]
		assault_mind.add_antag_datum(operative_antag_datum_type)
	//Assign the targets
	for(var/i in GLOB.player_list)
		if(ishuman(i))
			var/mob/living/carbon/human/H = i
			if(H.job == "Captain" || "Head of Personnel" || "Quartermaster" || "Head of Security" || "Chief Engineer" || "Research Director" || "Blueshield" || "Security Officer" || "Warden") //UGH SHITCODE!!
				GLOB.assaultops_targets.Add(H)
	return ..()

/*
/datum/game_mode/assaultops/check_finished()
	//Keep the round going if ops are dead but bomb is ticking.
	if(assault_team.operatives_dead())
		for(var/obj/machinery/assaultopsbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
	return ..()
*/

/datum/game_mode/assaultops/set_round_result()
	..()
	var/result = assault_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - takeover failed - crew secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(ASSAULT_RESULT_ASSAULT_WIN)
			SSticker.mode_result = "win - syndicate takeover"
			SSticker.news_report = STATION_NUKED
		if(ASSAULT_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - no takeover"
			SSticker.news_report = OPERATIVES_KILLED
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/game_mode/assaultops/generate_report()
	return "Several Nanotransen-affiliated stations in your sector are currently beseiged by the Gorlex Marauders, and current trends suggests your station is next in line.\
           They are heavily armed and dangerous, and we recommend you fortify any defensible positions immediately. They may attempt to communicate or negotiate. Stall for as long as possible. \
            Our ERT force is stretched thin in this sector, so there are no guarantee of reinforcements. As a result, the crew is permitted to aid security as a militia under the directive of the captain . Do not give up control of the station, unless you are unable to resist effectively any further. \
            In which case, surrender to keep costs to a minimal. We will come back eventually to retake the station."

/proc/is_assault_operative(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/assaultops)


//KITS
/datum/outfit/assaultops
	name = "I couldn't choose one!"

	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/thermal
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves =  /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/tablet/nukeops
	id = /obj/item/card/id/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	suit_store = /obj/item/gun/ballistic/automatic/pistol/aps
	r_pocket = /obj/item/ammo_box/magazine/m9mm_aps
	belt = /obj/item/storage/belt/utility/syndicate

	var/command_radio = FALSE
	var/cqc = FALSE

/datum/outfit/assaultops/cqb
	name = "Assault Operative - CQB"

	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,\
		/obj/item/gun/ballistic/automatic/c20r,\
		/obj/item/ammo_box/magazine/smgm45=4,\
		/obj/item/clothing/suit/armor)

	cqc = TRUE

/datum/outfit/assaultops/demoman
	name = "Assault Operative - Demolitions"

	belt = /obj/item/storage/belt/grenade/full
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,\
		/obj/item/gun/ballistic/automatic/gyropistol,\
		/obj/item/ammo_box/magazine/m75=4,\
		/obj/item/grenade/syndieminibomb=4,\
		/obj/item/grenade/c4=2,\
		/obj/item/implant/explosive/macro,\
		/obj/item/clothing/suit/space/hardsuit/rd)

/datum/outfit/assaultops/medic
	name = "Assault Operative - Medic"

	glasses = /obj/item/clothing/glasses/hud/health
	belt = /obj/item/storage/belt/medical/paramedic
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,\
		/obj/item/gun/ballistic/automatic/submachine_gun/pps,\
		/obj/item/ammo_box/magazine/pps=4,\
		/obj/item/storage/firstaid/tactical=2,\
		/obj/item/gun/medbeam)

/datum/outfit/assaultops/heavy
	name = "Assault Operative - Heavy Gunner"

	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,\
		/obj/item/gun/ballistic/automatic/l6_saw/unrestricted/mg34,\
		/obj/item/ammo_box/magazine/mg34=4,\
		/obj/item/grenade/syndieminibomb)

/datum/outfit/assaultops/assault
	name = "Assault Operative - Assault"

	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,\
		/obj/item/gun/ballistic/automatic/assault_rifle/akm,\
		/obj/item/ammo_box/magazine/akm=4,\
		/obj/item/grenade/syndieminibomb=2)


/datum/outfit/assaultops/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE

	if(cqc)
		//ADD CQC SHIT
		H.AddComponent(/datum/martial_art/cqc)

	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()


/datum/objective/assaultops
	name = "assaultops"
	explanation_text = "Commence a hostile takeover of the station, kill all loyalist nanotrasen crew members."
	martyr_compatible = TRUE

/datum/objective/assaultops/check_completion()
	var/finished = TRUE
	for(var/mob/living/carbon/human/H in GLOB.assaultops_targets)
		if(H.stat != DEAD)
			finished = FALSE
	if(finished)
		return TRUE
	return FALSE
