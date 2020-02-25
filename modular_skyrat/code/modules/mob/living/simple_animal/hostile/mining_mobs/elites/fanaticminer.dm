#define AXE_SLAM 1
#define SUMMON_SHAMBLER 2
#define DASH 3
#define AXE_THROW 4

/**
  * # Necropolis priest
  *
  * Kind of like BD miner's son trying to impress their dad.
  */

/mob/living/simple_animal/hostile/asteroid/elite/minerpriest
	name = "Necropolis Priest"
	desc = "Once used to be a miner, now a worshipper of the necropolis."
	icon = 'modular_skyrat/icons/mob/lavaland/lavaland_elites.dmi'
	icon_state = "minerpriest"
	icon_living = "minerpriest"
	icon_aggro = "minerpriest"
	icon_dead = "minerpriest_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 800
	health = 800
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/slash.ogg'
	speed = 1
	move_to_delay = 2
	mouse_opacity = MOUSE_OPACITY_ICON
	deathsound = 'sound/voice/human/manlaugh1.ogg'
	deathmessage = "realizes what they've been doing all this time, and return to their true self."
	loot_drop = /obj/item/melee/diamondaxe

	attack_action_types = list(/datum/action/innate/elite_attack/axe_slam)

/datum/action/innate/elite_attack/axe_slam
	name = "Axe Slam"
	icon_icon = 'modular_skyrat/icons/mob/actions/actions_elites.dmi'
	button_icon_state = "axe_slam"
	chosen_message = "<span class='boldwarning'>You will attempt to slam your axe.</span>"
	chosen_attack_num = AXE_SLAM

/datum/action/innate/elite_attack/summon_shambler
	name = "Summon Shambler"
	icon_icon = 'modular_skyrat/icons/mob/actions/actions_elites.dmi'
	button_icon_state = "summon_shambler"
	chosen_message = "<span class='boldwarning'>You will attempt to summon a shambling miner.</span>"
	chosen_attack_num = SUMMON_SHAMBLER

/datum/action/innate/elite_attack/dash
	name = "Dash"
	icon_icon = 'modular_skyrat/icons/mob/actions/actions_elites.dmi'
	button_icon_state = "dash"
	chosen_message = "<span class='boldwarning'>You will attempt to dash near your target.</span>"
	chosen_attack_num = DASH

/datum/action/innate/elite_attack/axe_throw
	name = "Axe Throw"
	icon_icon = 'modular_skyrat/icons/mob/actions/actions_elites.dmi'
	button_icon_state = "axe_throw"
	chosen_message = "<span class='boldwarning'>You will attempt to throw your axe.</span>"
	chosen_attack_num = AXE_THROW

/mob/living/simple_animal/hostile/asteroid/elite/minerpriest/OpenFire()
	if(client)
		switch(chosen_attack)
			if(AXE_SLAM)
				axe_slam(target)
			if(SUMMON_SHAMBLER)
				summon_shambler(target)
			if(DASH)
				dash(target)
			if(AXE_THROW)
				axe_throw(target)
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(AXE_SLAM)
			axe_slam(target)
		if(SUMMON_SHAMBLER)
			summon_shambler(target)
		if(DASH)
			dash(target)
		if(AXE_THROW)
			axe_throw(target)

// priest actions
/mob/living/simple_animal/hostile/asteroid/elite/minerpriest/proc/axe_slam(target)
	ranged_cooldown = world.time + 30
	var/dir_to_target = get_dir(get_turf(src), get_turf(target))
	var/turf/T = get_step(get_turf(src), dir_to_target)
	for(var/i in 1 to 3)
		new /obj/effect/temp_visual/dragon_swoop/priest(T)
		T = get_step(T, dir_to_target)
	visible_message("<span class='boldwarning'>[src] prepares to slam his axe!</span>")
	sleep(5)
	T = get_step(get_turf(src), dir_to_target)
	var/list/hit_things = list()
	visible_message("<span class='boldwarning'>[src] slams his axe!</span>")
	for(var/i in 1 to 3)
		for(var/mob/living/L in T.contents)
			if(faction_check_mob(L))
				return
			hit_things += L
			visible_message("<span class='boldwarning'>[src] slams his axe on [L]!</span>")
			to_chat(L, "<span class='userdanger'>[src] slams his axe on you!</span>")
			L.Stun(15)
			L.adjustBruteLoss(30)
		T = get_step(T, dir_to_target)

/mob/living/simple_animal/hostile/asteroid/elite/minerpriest/proc/summon_shambler(target)
	ranged_cooldown = world.time + 150
	visible_message("<span class='boldwarning'>[src] summons a minion!</span>")
	var/list/turfs = list()
	for(var/turf/T in oview(2, src))
		turfs += T
	var/turf/pick1 = pick(turfs)
	new /obj/effect/temp_visual/small_smoke/halfsecond(pick1)
	var/mob/living/simple_animal/hostile/asteroid/miner/m1 = new /mob/living/simple_animal/hostile/asteroid/miner(pick1)
	m1.GiveTarget(target)

/mob/living/simple_animal/hostile/asteroid/elite/minerpriest/proc/dash(atom/dash_target)
	ranged_cooldown = world.time + 20
	visible_message("<span class='boldwarning'>[src] dashes into the air!</span>")
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(src)
	if(!QDELETED(dash_target))
		self_dist_to_target += get_dist(dash_target, own_turf)
	for(var/turf/open/O in RANGE_TURFS(4, own_turf))
		var/turf_dist_to_target = 0
		if(!QDELETED(dash_target))
			turf_dist_to_target += get_dist(dash_target, O)
		if(get_dist(src, O) <= 4 && turf_dist_to_target <= self_dist_to_target && !islava(O) && !ischasm(O))
			var/valid = TRUE
			for(var/turf/T in getline(own_turf, O))
				if(is_blocked_turf(T, TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[O] = turf_dist_to_target
	var/turf/target_turf
	if(!QDELETED(dash_target))
		var/closest_dist = 4
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] != closest_dist)
				accessable_turfs -= t
	if(!LAZYLEN(accessable_turfs))
		return
	target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, -(src.dir))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(own_turf)
	forceMove(step_back_turf)
	return TRUE


/mob/living/simple_animal/hostile/asteroid/elite/minerpriest/proc/axe_throw(target)
	ranged_cooldown = world.time + 50
	visible_message("<span class='boldwarning'>[src] prepares to throw his axe!</span>")
	var/turf/targetturf = get_turf(target)
	sleep(5)
	var/obj/item/melee/diamondaxe/A = new /obj/item/melee/diamondaxe(get_step(src, src.dir))
	A.throw_at(targetturf, 4, 4)
	addtimer(CALLBACK(A, /obj/item/melee/diamondaxe/Destroy), 20)

// priest helpers

/obj/effect/temp_visual/dragon_swoop/priest
	duration = 5
	color = rgb(255,0,0)

//loot

/obj/item/melee/diamondaxe
	name = "Fanatic's Axe"
	desc = "Used to be a diamond pickaxe, now there's no pick, just axe."
	icon = 'modular_skyrat/icons/obj/lavaland/artefacts.dmi'
	icon_state = "diamondaxe"
	lefthand_file = 'modular_skyrat/icons/mob/inhands/axes_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/axes_righthand.dmi'
	item_state = "diamondaxe"
	attack_verb = list("slashed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	throwforce = 20
	embedding = list("embedded_pain_multiplier" = 3, "embed_chance" = 90, "embedded_fall_chance" = 50)
	armour_penetration = 100
	block_chance = 25
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/melee/diamondaxe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 50, 100, null, null, TRUE)

/obj/item/melee/diamondaxe/Destroy()
	qdel(src)