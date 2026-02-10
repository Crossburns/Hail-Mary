/// Ambient music trigger system
/// Place these on the map to create music zones that play when players enter

/obj/effect/music_trigger
	name = "music trigger"
	desc = "You shouldn't be seeing this - report to admins."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	alpha = 100
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER

	/// The sound file to play (set this in map editor or via admin panel)
	var/sound_file = null

	/// Volume (0-100)
	var/sound_volume = 50

	/// How long to fade in (deciseconds)
	var/fade_in_time = 20

	/// How long to fade out when exiting (deciseconds)
	var/fade_out_time = 30

	/// Cooldown per player before they can trigger again (deciseconds)
	var/cooldown_time = 100

	/// Should the music loop?
	var/sound_loop = TRUE

	/// Which sound channel to use (using channel 9 for ambient music)
	var/sound_channel = 9

	/// List of ckeys currently in the trigger and their music datum
	var/list/active_players = list()

	/// List of ckeys on cooldown
	var/list/cooldown_players = list()

/obj/effect/music_trigger/Initialize()
	. = ..()
	// Set up the trigger area
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/music_trigger/Destroy()
	// Clean up all active music
	for(var/ckey in active_players)
		var/datum/music_handler/handler = active_players[ckey]
		if(handler)
			handler.stop_music(fade_out_time)
			qdel(handler)
	active_players.Cut()
	cooldown_players.Cut()
	return ..()

/obj/effect/music_trigger/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isliving(AM))
		return

	var/mob/living/L = AM

	// Only trigger for player-controlled mobs
	if(!L.client || !L.ckey)
		return

	// Check if on cooldown
	if(cooldown_players[L.ckey])
		return

	// Check if already playing for this player
	if(active_players[L.ckey])
		return

	// Check if music file is set
	if(!sound_file)
		return

	// Start music for this player
	start_music_for_player(L)

/obj/effect/music_trigger/proc/on_exited(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isliving(AM))
		return

	var/mob/living/L = AM

	if(!L.ckey)
		return

	// Stop music for this player
	stop_music_for_player(L)

/obj/effect/music_trigger/proc/start_music_for_player(mob/living/player)
	if(!player || !player.client || !sound_file)
		return

	var/datum/music_handler/handler = new(player, src)
	active_players[player.ckey] = handler
	handler.start_music()

/obj/effect/music_trigger/proc/stop_music_for_player(mob/living/player)
	if(!player || !player.ckey)
		return

	var/datum/music_handler/handler = active_players[player.ckey]
	if(!handler)
		return

	// Remove from active list
	active_players -= player.ckey

	// Fade out and clean up
	handler.stop_music(fade_out_time)

	// Start cooldown
	cooldown_players[player.ckey] = TRUE
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown), player.ckey), cooldown_time)

	// Clean up handler after fade completes
	QDEL_IN(handler, fade_out_time + 5)

/obj/effect/music_trigger/proc/clear_cooldown(ckey)
	cooldown_players -= ckey

/// Admin examine
/obj/effect/music_trigger/examine(mob/user)
	. = ..()
	if(!isobserver(user) && !user.client?.holder)
		return

	. += "<span class='boldnotice'>===== MUSIC TRIGGER =====</span>"
	. += "<span class='notice'>Sound File: [sound_file ? sound_file : "NOT SET"]</span>"
	. += "<span class='notice'>Volume: [sound_volume]%</span>"
	. += "<span class='notice'>Fade In: [fade_in_time/10]s | Fade Out: [fade_out_time/10]s</span>"
	. += "<span class='notice'>Cooldown: [cooldown_time/10]s</span>"
	. += "<span class='notice'>Loop: [sound_loop ? "Yes" : "No"]</span>"
	. += "<span class='notice'>Active Players: [active_players.len]</span>"
	if(user.client?.holder)
		. += "<span class='boldnotice'>Click to configure</span>"

/// Admin configuration
/obj/effect/music_trigger/attack_ghost(mob/user)
	if(!check_rights_for(user.client, R_ADMIN))
		return ..()
	configure(user)
	return TRUE

/obj/effect/music_trigger/proc/configure(mob/user)
	if(!check_rights_for(user.client, R_ADMIN))
		return

	var/choice = input(user, "Configure Music Trigger", "Music Trigger") as null|anything in list(
		"Set Sound File",
		"Set Volume",
		"Set Fade In Time",
		"Set Fade Out Time",
		"Set Cooldown",
		"Toggle Loop",
		"Test Music",
		"Stop All"
	)

	if(!choice)
		return

	switch(choice)
		if("Set Sound File")
			var/new_file = input(user, "Choose a sound file.", "Sound File") as null|sound
			if(new_file)
				sound_file = new_file
				to_chat(user, span_notice("Sound file set to [sound_file]."))

		if("Set Volume")
			var/new_vol = input(user, "Set volume (0-100).", "Volume", sound_volume) as null|num
			if(!isnull(new_vol))
				sound_volume = clamp(new_vol, 0, 100)
				to_chat(user, span_notice("Volume set to [sound_volume]%."))

		if("Set Fade In Time")
			var/new_time = input(user, "Fade in time (seconds).", "Fade In", fade_in_time/10) as null|num
			if(!isnull(new_time))
				fade_in_time = clamp(new_time, 0, 100) * 10
				to_chat(user, span_notice("Fade in time set to [fade_in_time/10] seconds."))

		if("Set Fade Out Time")
			var/new_time = input(user, "Fade out time (seconds).", "Fade Out", fade_out_time/10) as null|num
			if(!isnull(new_time))
				fade_out_time = clamp(new_time, 0, 100) * 10
				to_chat(user, span_notice("Fade out time set to [fade_out_time/10] seconds."))

		if("Set Cooldown")
			var/new_cooldown = input(user, "Cooldown time (seconds).", "Cooldown", cooldown_time/10) as null|num
			if(!isnull(new_cooldown))
				cooldown_time = clamp(new_cooldown, 0, 300) * 10
				to_chat(user, span_notice("Cooldown set to [cooldown_time/10] seconds."))

		if("Toggle Loop")
			sound_loop = !sound_loop
			to_chat(user, span_notice("Loop [sound_loop ? "enabled" : "disabled"]."))

		if("Test Music")
			if(!sound_file)
				to_chat(user, span_warning("No sound file set!"))
				return
			var/sound/S = sound(sound_file)
			S.channel = sound_channel
			S.volume = sound_volume
			S.repeat = sound_loop
			SEND_SOUND(user, S)
			to_chat(user, span_notice("Playing test sound..."))

		if("Stop All")
			var/sound/S = sound(null)
			S.channel = sound_channel
			for(var/ckey in active_players)
				var/datum/music_handler/handler = active_players[ckey]
				if(handler && handler.player && handler.player.client)
					SEND_SOUND(handler.player, S)
			to_chat(user, span_notice("Stopped all active music."))

/// Music handler datum - manages music state for a single player
/datum/music_handler
	var/mob/living/player
	var/obj/effect/music_trigger/trigger
	var/currently_playing = FALSE

/datum/music_handler/New(mob/living/L, obj/effect/music_trigger/T)
	player = L
	trigger = T

/datum/music_handler/Destroy()
	player = null
	trigger = null
	return ..()

/datum/music_handler/proc/start_music()
	if(!player || !player.client || !trigger || !trigger.sound_file)
		return

	// Check player prefs
	if(!(player.client.prefs.toggles & SOUND_MIDI))
		return

	currently_playing = TRUE

	var/sound/S = sound(trigger.sound_file)
	S.channel = trigger.sound_channel
	S.repeat = trigger.sound_loop
	S.wait = 0
	S.volume = 0 // Start at 0 for fade in

	SEND_SOUND(player, S)

	// Fade in
	if(trigger.fade_in_time > 0)
		var/steps = 10
		var/step_time = trigger.fade_in_time / steps
		var/volume_per_step = trigger.sound_volume / steps

		for(var/i in 1 to steps)
			if(!player || !player.client || !currently_playing)
				return
			var/sound/fade = sound(null)
			fade.channel = trigger.sound_channel
			fade.volume = volume_per_step * i
			SEND_SOUND(player, fade)
			sleep(step_time)
	else
		// No fade, just set volume
		var/sound/instant = sound(null)
		instant.channel = trigger.sound_channel
		instant.volume = trigger.sound_volume
		SEND_SOUND(player, instant)

/datum/music_handler/proc/stop_music(fade_time = 30)
	if(!player || !player.client || !currently_playing)
		return

	currently_playing = FALSE

	// Fade out
	if(fade_time > 0)
		var/steps = 10
		var/step_time = fade_time / steps
		var/volume_per_step = trigger.sound_volume / steps

		for(var/i in 1 to steps)
			if(!player || !player.client)
				return
			var/sound/fade = sound(null)
			fade.channel = trigger.sound_channel
			fade.volume = trigger.sound_volume - (volume_per_step * i)
			SEND_SOUND(player, fade)
			sleep(step_time)

	// Stop completely
	if(player && player.client)
		var/sound/S = sound(null)
		S.channel = trigger.sound_channel
		SEND_SOUND(player, S)

/// Preset music triggers for common areas

/obj/effect/music_trigger/wasteland_ambient
	name = "wasteland ambient music trigger"
	sound_file = 'sound/f13music/desert_wind.ogg'
	sound_volume = 30

/obj/effect/music_trigger/cave_ambient
	name = "cave ambient music trigger"
	sound_file = 'sound/f13music/metallic_monks.ogg'
	sound_volume = 40

/obj/effect/music_trigger/dungeon_ominous
	name = "dungeon music trigger"
	sound_file = 'sound/f13music/vats_of_goo.ogg'
	sound_volume = 45
	fade_in_time = 30
	fade_out_time = 40

/obj/effect/music_trigger/quartz
	name = "quartz music trigger"
	sound_file = 'sound/f13music/quartz.ogg'
	sound_volume = 35

/obj/effect/music_trigger/new_reno
	name = "new reno music trigger"
	sound_file = 'sound/f13music/new_reno.ogg'
	sound_volume = 35

/obj/effect/music_trigger/mysterious
	name = "mysterious music trigger"
	sound_file = 'sound/f13music/mysterious_stranger.ogg'
	sound_volume = 40

/obj/effect/music_trigger/bubbles
	name = "bubbles ambient trigger"
	sound_file = 'sound/f13music/Bubbles.ogg'
	sound_volume = 35

/obj/effect/music_trigger/coastal
	name = "coastal music trigger"
	sound_file = 'sound/f13music/thecoastpart1fo4.ogg'
	sound_volume = 35

/obj/effect/music_trigger/doc_mitchell
	name = "doc mitchell music trigger"
	sound_file = 'sound/f13music/doc_mitchell.ogg'
	sound_volume = 40
	sound_loop = FALSE
