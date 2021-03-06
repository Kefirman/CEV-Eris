//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.Process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

var/global/initialization_stage = 0

datum/controller/game_controller
	var/list/shuttle_list	                    // For debugging and VV
	var/init_immediately = FALSE

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		admin_notice(SPAN_DANGER("Job setup complete"), R_DEBUG)

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	setup_objects()
	setup_genetics()
	SetupXenoarch()

	report_progress("Initializations complete")
	initialization_stage |= INITIALIZATION_COMPLETE

datum/controller/game_controller/proc/setup_objects()
	set background=1

	// Do these first since character setup will rely on them

	initialization_stage |= INITIALIZATION_HAS_BEGUN

	if(config.use_overmap)
		admin_notice(SPAN_DANGER("Initializing overmap events."), R_DEBUG)
		overmap_event_handler.create_events(maps_data.overmap_z, maps_data.overmap_size, maps_data.overmap_event_areas)

	report_progress("Initializing lathe recipes")
	populate_lathe_recipes()


	admin_notice(SPAN_DANGER("Initializing areas"), R_DEBUG)									//Also needs to be rewritten
	sleep(-1)
	for(var/area/area in all_areas)
		area.Initialize()

	// Set up antagonists.
	populate_antag_type_list()


/proc/report_progress(var/progress_message)
	admin_notice("<span class='boldannounce'>[progress_message]</span>", R_DEBUG)
	world << progress_message