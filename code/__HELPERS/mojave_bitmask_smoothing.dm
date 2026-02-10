// Mojave-scoped bitmask smoothing (small, self-contained).
// Applies only to atoms with mojave_bitmask = TRUE.

/atom/var/mojave_bitmask = FALSE
/atom/var/mojave_smooth_group = null
/atom/var/mojave_base_icon_state = null

/atom/proc/mojave_groups_match(atom/other)
	if(!other)
		return FALSE
	if(!mojave_smooth_group || !other.mojave_smooth_group)
		return FALSE
	var/a = mojave_smooth_group
	var/b = other.mojave_smooth_group
	if(islist(a))
		if(islist(b))
			for(var/entry in a)
				if(entry in b)
					return TRUE
			return FALSE
		return (b in a)
	if(islist(b))
		return (a in b)
	return a == b

/atom/proc/mojave_can_smooth_with(atom/other)
	if(!other)
		return FALSE
	if(mojave_smooth_group)
		return mojave_groups_match(other)
	return istype(other, type)

/atom/proc/mojave_get_neighbor(atom/A, dir)
	if(!A)
		return null
	if(isturf(A))
		var/turf/T = get_step(A, dir)
		if(A.mojave_can_smooth_with(T))
			return T
		return null
	var/turf/OT = get_step(A, dir)
	if(!OT)
		return null
	for(var/atom/O in OT)
		if(ismovable(O))
			var/atom/movable/AM = O
			if(!AM.anchored)
				continue
		if(A.mojave_can_smooth_with(O))
			return O
	return null

/atom/proc/mojave_infer_base_icon_state()
	if(!istext(icon_state))
		return null
	var/regex/R = regex("^(.+)-[0-9]+$")
	if(!R.Find(icon_state))
		return null
	return R.group[1]

/atom/proc/mojave_calc_bitmask()
	var/mask = 0
	if(mojave_get_neighbor(src, NORTH))
		mask |= NORTH
	if(mojave_get_neighbor(src, EAST))
		mask |= EAST
	if(mojave_get_neighbor(src, SOUTH))
		mask |= SOUTH
	if(mojave_get_neighbor(src, WEST))
		mask |= WEST
	return mask

/atom/proc/mojave_apply_bitmask()
	if(!mojave_bitmask)
		return
	if(!mojave_base_icon_state)
		mojave_base_icon_state = mojave_infer_base_icon_state()
		if(!mojave_base_icon_state)
			return
		if(!mojave_smooth_group)
			mojave_smooth_group = mojave_base_icon_state
	var/mask = mojave_calc_bitmask()
	icon_state = "[mojave_base_icon_state]-[mask]"

/proc/mojave_update_bitmask(atom/A)
	if(!A || !A.mojave_bitmask)
		return
	A.mojave_apply_bitmask()
	var/list/dirs = list(NORTH, EAST, SOUTH, WEST)
	for(var/d in dirs)
		var/atom/N = A.mojave_get_neighbor(A, d)
		if(N && N.mojave_bitmask)
			N.mojave_apply_bitmask()
