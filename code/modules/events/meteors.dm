/datum/event/meteor_wave
	startWhen		= 30	// About one minute early warning
	endWhen 		= 60	// Adjusted automatically in tick()
	var/alarmWhen   = 30
	var/next_meteor = 40
	var/waves = 1
	var/start_side
	var/next_meteor_lower = 10
	var/next_meteor_upper = 20


/datum/event/meteor_wave/setup()
	waves = 0
	for(var/n in 1 to severity)
		waves += rand(5,15)

	start_side = pick(cardinal)
	endWhen = worst_case_end()

/datum/event/meteor_wave/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			using_map.meteors_detected_announcement()
		else
			command_announcement.Announce("The [station_name()] is now in a meteor shower.", "[station_name()] Sensor Array")

/datum/event/meteor_wave/tick()
	// Begin sending the alarm signals to shield diffusers so the field is already regenerated (if it exists) by the time actual meteors start flying around.
	if(alarmWhen < activeFor)
		for(var/obj/machinery/shield_diffuser/SD in machines)
			if(SD.z in using_map.station_levels)
				SD.meteor_alarm(10)

	if(waves && activeFor >= next_meteor)
		send_wave()

/datum/event/meteor_wave/proc/worst_case_end()
	return activeFor + ((30 / severity) * waves) + 30

/datum/event/meteor_wave/proc/send_wave()
	var/pick_side = prob(80) ? start_side : (prob(50) ? turn(start_side, 90) : turn(start_side, -90))
	spawn() spawn_meteors(severity * rand(2,4), get_meteors(), pick_side)
	next_meteor += rand(next_meteor_lower, next_meteor_upper) / severity
	waves--
	endWhen = worst_case_end()

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce("The [station_name()] has cleared the meteor storm.", "[station_name()] Sensor Array")
		else
			command_announcement.Announce("The [station_name()] has cleared the meteor shower", "[station_name()] Sensor Array")

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return meteors_major
		if(EVENT_LEVEL_MODERATE)
			return meteors_moderate
		else
			return meteors_minor

/var/list/meteors_minor = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
)

/var/list/meteors_moderate = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	/obj/effect/meteor/emp        = 10,
)

/var/list/meteors_major = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/emp        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	/obj/effect/meteor/tunguska   = 1,
)

/datum/event/meteor_wave/overmap
	next_meteor_lower = 5
	next_meteor_upper = 10
	next_meteor = 0
