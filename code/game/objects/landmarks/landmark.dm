/obj/landmark
	name = "landmark"
	icon = 'icons/misc/landmarks.dmi'
	alpha = 64 //Or else they cover half of the map
	anchored = TRUE
	unacidable = TRUE
	simulated = FALSE
	invisibility = 101
	var/delete_me = FALSE

/obj/landmark/New()
	..()
	landmarks_list += src

/obj/landmark/proc/delete()
	delete_me = TRUE

/obj/landmark/Initialize()
	..()
	if(delete_me)
		qdel(src)

/obj/landmark/Destroy()
	landmarks_list -= src
	return ..()


