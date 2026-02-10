// Mojave walls (manual, curated) with Mojave-scoped bitmask smoothing.

/turf/closed/wall/mojave
	name = "mojave wall"
	desc = "A Mojave wall."
	icon_state = "wall-0"
	mojave_bitmask = TRUE
	mojave_base_icon_state = "wall"
	mojave_smooth_group = "mojave_wall"
	smooth = SMOOTH_FALSE
	canSmoothWith = null
	var/weldable = FALSE

/turf/closed/wall/mojave/Initialize()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/AfterChange()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/try_decon(obj/item/I, mob/user, turf/T)
	if(!weldable)
		return FALSE
	return ..()

/turf/closed/wall/mojave/deconstruction_hints(mob/user)
	if(!weldable)
		return
	return ..()

// Metal & scrap
/turf/closed/wall/mojave/metal
	name = "metal wall"
	desc = "A sturdy metal wall."
	icon = 'mojave/icons/turf/walls/metal.dmi'

/turf/closed/wall/mojave/metal/rust
	name = "rusted metal wall"
	desc = "A metal wall rusted with age."
	icon = 'mojave/icons/turf/walls/rustmetal.dmi'

/turf/closed/wall/mojave/metal/reinforced
	name = "reinforced metal wall"
	desc = "A heavy duty, reinforced metal wall."
	icon = 'mojave/icons/turf/walls/rmetal.dmi'

/turf/closed/wall/mojave/metal/reinforced/industrial
	desc = "A reinforced metal wall with some patches of rust."
	icon = 'mojave/icons/turf/walls/rusty_industrial.dmi'

/turf/closed/wall/mojave/metal/reinforced/rust
	name = "rusted reinforced metal wall"
	desc = "A rusty but still quite sturdy reinforced metal wall."
	icon = 'mojave/icons/turf/walls/rrustmetal.dmi'

/turf/closed/wall/mojave/scrap
	name = "scrap wall"
	desc = "A wall made of scrap metal."
	icon = 'mojave/icons/turf/walls/scrap.dmi'

/turf/closed/wall/mojave/scrap/white
	icon = 'mojave/icons/turf/walls/scrapwhite.dmi'

/turf/closed/wall/mojave/scrap/red
	icon = 'mojave/icons/turf/walls/scrapred.dmi'

/turf/closed/wall/mojave/scrap/blue
	icon = 'mojave/icons/turf/walls/scrapblue.dmi'

// Wood
/turf/closed/wall/mojave/wood
	name = "log wall"
	desc = "A rustic log wall."
	icon = 'mojave/icons/turf/walls/wood.dmi'

/turf/closed/wall/mojave/wood/fresh
	name = "fresh log wall"
	desc = "A somewhat freshly made log wall."
	icon = 'mojave/icons/turf/walls/woodfresh.dmi'

// Adobe / siding / prison (randomized variants)
/turf/closed/wall/mojave/adobe
	name = "adobe wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/adobe.dmi'

/turf/closed/wall/mojave/siding
	name = "sided wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/siding.dmi'

/turf/closed/wall/mojave/siding/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/drought/siding_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/drought/siding_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/drought/siding_3.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/siding/blue
	name = "sided wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/siding_blue.dmi'

/turf/closed/wall/mojave/siding/blue/Initialize()
	. = ..()
	var/state = rand(1,4)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/drought/siding_blue_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/drought/siding_blue_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/drought/siding_blue_3.dmi'
		if(4) icon = 'mojave/icons/turf/walls/drought/siding_blue.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/siding/green
	name = "sided wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/siding_green.dmi'

/turf/closed/wall/mojave/siding/green/Initialize()
	. = ..()
	var/state = rand(1,4)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/drought/siding_green_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/drought/siding_green_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/drought/siding_green_3.dmi'
		if(4) icon = 'mojave/icons/turf/walls/drought/siding_green.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/siding/red
	name = "sided wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/siding_red.dmi'

/turf/closed/wall/mojave/siding/red/Initialize()
	. = ..()
	var/state = rand(1,4)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/drought/siding_red_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/drought/siding_red_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/drought/siding_red_3.dmi'
		if(4) icon = 'mojave/icons/turf/walls/drought/siding_red.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/prison
	name = "prison wall"
	desc = ""
	icon = 'mojave/icons/turf/walls/drought/prison.dmi'

/turf/closed/wall/mojave/prison/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/drought/prison_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/drought/prison_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/drought/prison_3.dmi'
	mojave_update_bitmask(src)

// Brick / concrete / bunker / sewer
/turf/closed/wall/mojave/brick
	name = "brick wall"
	desc = "A brick wall. Try banging your head against this."
	icon = 'mojave/icons/turf/walls/brick.dmi'

/turf/closed/wall/mojave/brick/alt
	icon = 'mojave/icons/turf/walls/brickalt.dmi'

/turf/closed/wall/mojave/brick/gray
	icon = 'mojave/icons/turf/walls/brickgray.dmi'

/turf/closed/wall/mojave/concrete
	name = "concrete wall"
	desc = "A tough concrete wall."
	icon = 'mojave/icons/turf/walls/concrete.dmi'

/turf/closed/wall/mojave/concrete/alt
	icon = 'mojave/icons/turf/walls/concretealt.dmi'

/turf/closed/wall/mojave/sewer
	name = "sewer wall"
	desc = "A sewer wall. Gross."
	icon = 'mojave/icons/turf/walls/sewer.dmi'

/turf/closed/wall/mojave/bunker
	name = "bunker wall"
	desc = "A bunker wall. Serious business."
	icon = 'mojave/icons/turf/walls/bunker.dmi'

// Vault walls
/turf/closed/wall/mojave/vault
	name = "vault wall"
	desc = "A secure vault wall."
	icon = 'mojave/icons/turf/walls/vault_wall.dmi'

/turf/closed/wall/mojave/vault/rust
	name = "rusted vault wall"
	desc = "A rusted vault wall."
	icon = 'mojave/icons/turf/walls/vault_wall_rust.dmi'

// Vent sections are fixed variants; keep them from being overwritten by bitmask.
/turf/closed/wall/mojave/vault/vent
	name = "vent section"
	icon = 'mojave/icons/turf/walls/vault_vent.dmi'
	icon_state = "wall-141"
	mojave_bitmask = FALSE

/turf/closed/wall/mojave/vault/rust/vent
	name = "rusted vent section"
	icon = 'mojave/icons/turf/walls/vault_vent_rust.dmi'
	icon_state = "wall-141"
	mojave_bitmask = FALSE

// Dungeon walls (randomized)
/turf/closed/wall/mojave/dungeon
	name = "reinforced bunker wall"
	desc = "A reinforced bunker wall. The pinnacle of pre-war engineering."
	icon = 'mojave/icons/turf/walls/dungeon_1.dmi'

/turf/closed/wall/mojave/dungeon/Initialize()
	. = ..()
	var/state = rand(1,4)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/dungeon_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/dungeon_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/dungeon_3.dmi'
		if(4) icon = 'mojave/icons/turf/walls/dungeon_4.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/dungeon/rust
	name = "rusted reinforced bunker wall"
	desc = "A rusted reinforced bunker wall. Still stands strong."
	icon = 'mojave/icons/turf/walls/dungeon_rust_1.dmi'

/turf/closed/wall/mojave/dungeon/rust/Initialize()
	. = ..()
	var/state = rand(1,4)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/dungeon_rust_1.dmi'
		if(2) icon = 'mojave/icons/turf/walls/dungeon_rust_2.dmi'
		if(3) icon = 'mojave/icons/turf/walls/dungeon_rust_3.dmi'
		if(4) icon = 'mojave/icons/turf/walls/dungeon_rust_4.dmi'
	mojave_update_bitmask(src)

// Craftable-style rough walls (map-use)
/turf/closed/wall/mojave/roughscrap
	name = "crude scrap wall"
	desc = "A crude wall made of scrap metal. This looks very recently constructed."
	icon = 'mojave/icons/turf/walls/roughscrap.dmi'

/turf/closed/wall/mojave/roughscrap/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/roughscrap_2.dmi'
		if(2) icon = 'mojave/icons/turf/walls/roughscrap_3.dmi'
		if(3) icon = 'mojave/icons/turf/walls/roughscrap.dmi'
	mojave_update_bitmask(src)

// Craftable Mojave walls (no frills)
/turf/closed/wall/mojave/craftable
	name = "craftable mojave wall"
	desc = "A Mojave wall that looks recently constructed."
	baseturfs = /turf/open/floor/plating
	weldable = TRUE

/turf/closed/wall/mojave/craftable/deconstruction_hints(mob/user)
	return span_notice("You could use a <b>welder</b> to cut through this wall.")

/turf/closed/wall/mojave/craftable/scrap
	name = "crude scrap wall"
	desc = "A crude wall made of scrap metal. This looks very recently constructed."
	icon = 'mojave/icons/turf/walls/roughscrap.dmi'
	girder_type = null
	sheet_type = /obj/item/stack/sheet/metal
	sheet_amount = 6
	slicing_duration = 30 SECONDS

/turf/closed/wall/mojave/craftable/scrap/Initialize()
	. = ..()
	var/state = rand(1,3)
	switch(state)
		if(1) icon = 'mojave/icons/turf/walls/roughscrap_2.dmi'
		if(2) icon = 'mojave/icons/turf/walls/roughscrap_3.dmi'
		if(3) icon = 'mojave/icons/turf/walls/roughscrap.dmi'
	mojave_update_bitmask(src)

/turf/closed/wall/mojave/craftable/wood
	name = "crude log wall"
	desc = "A freshly made, crude log wall. This looks very recently constructed."
	icon = 'mojave/icons/turf/walls/woodfresh.dmi'
	girder_type = null
	sheet_type = /obj/item/stack/sheet/mineral/wood
	sheet_amount = 2
	slicing_duration = 30 SECONDS

// Indestructible Mojave walls / minerals
/turf/closed/indestructible/mojave
	name = "mojave indestructible wall"
	desc = "An indestructible Mojave wall."
	icon_state = "wall-0"
	mojave_bitmask = TRUE
	mojave_base_icon_state = "wall"
	mojave_smooth_group = "mojave_wall"
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/turf/closed/indestructible/mojave/Initialize()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/indestructible/mojave/AfterChange()
	. = ..()
	mojave_update_bitmask(src)

/turf/closed/indestructible/mojave/metal
	name = "metal wall"
	desc = "A sturdy metal wall."
	icon = 'mojave/icons/turf/walls/metal.dmi'

/turf/closed/indestructible/mojave/comb
	name = "comb wall"
	desc = "Honeybeast comb, lining the walls. They subtly drip a substance."
	icon = 'mojave/icons/turf/walls/comb.dmi'

/turf/closed/indestructible/mojave/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'mojave/icons/turf/walls/rock.dmi'
	mojave_smooth_group = "mojave_mineral"

/turf/closed/indestructible/mojave/rock/drought
	icon = 'mojave/icons/turf/walls/rockdrought.dmi'

/turf/closed/indestructible/mojave/rock/mammoth
	icon = 'mojave/icons/turf/walls/rockmammoth.dmi'
