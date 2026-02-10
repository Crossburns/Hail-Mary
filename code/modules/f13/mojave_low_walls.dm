// Mojave low walls (manual). Implemented as tables with Mojave bitmask smoothing.

/obj/structure/table/f13/mojave/low_wall
	name = "low wall"
	desc = "A low Mojave wall."
	icon = 'mojave/icons/turf/walls/metal.dmi'
	icon_state = "low-0"
	anchored = TRUE
	density = TRUE
	plane = WALL_PLANE
	mojave_bitmask = TRUE
	mojave_base_icon_state = "low"
	mojave_smooth_group = list("mojave_low_wall", "mojave_wall")

/obj/structure/table/f13/mojave/low_wall/Initialize(mapload)
	. = ..()
	mojave_update_bitmask(src)

/obj/structure/table/f13/mojave/low_wall/metal
	name = "low metal wall"
	icon = 'mojave/icons/turf/walls/metal.dmi'

/obj/structure/table/f13/mojave/low_wall/metal/rust
	name = "low rusted metal wall"
	icon = 'mojave/icons/turf/walls/rustmetal.dmi'

/obj/structure/table/f13/mojave/low_wall/wood
	name = "low wood wall"
	icon = 'mojave/icons/turf/walls/wood.dmi'

/obj/structure/table/f13/mojave/low_wall/wood/fresh
	name = "low fresh log wall"
	icon = 'mojave/icons/turf/walls/woodfresh.dmi'

/obj/structure/table/f13/mojave/low_wall/scrap
	name = "low scrap wall"
	icon = 'mojave/icons/turf/walls/scrap.dmi'

/obj/structure/table/f13/mojave/low_wall/scrap/white
	icon = 'mojave/icons/turf/walls/scrapwhite.dmi'

/obj/structure/table/f13/mojave/low_wall/scrap/red
	icon = 'mojave/icons/turf/walls/scrapred.dmi'

/obj/structure/table/f13/mojave/low_wall/scrap/blue
	icon = 'mojave/icons/turf/walls/scrapblue.dmi'

/obj/structure/table/f13/mojave/low_wall/concrete
	name = "low concrete wall"
	icon = 'mojave/icons/turf/walls/concrete.dmi'

/obj/structure/table/f13/mojave/low_wall/adobe
	name = "low adobe wall"
	icon = 'mojave/icons/turf/walls/drought/adobe.dmi'

/obj/structure/table/f13/mojave/low_wall/siding
	name = "low sided wall"
	icon = 'mojave/icons/turf/walls/drought/siding.dmi'

/obj/structure/table/f13/mojave/low_wall/siding/blue
	icon = 'mojave/icons/turf/walls/drought/siding_blue.dmi'

/obj/structure/table/f13/mojave/low_wall/siding/red
	icon = 'mojave/icons/turf/walls/drought/siding_red.dmi'

/obj/structure/table/f13/mojave/low_wall/siding/green
	icon = 'mojave/icons/turf/walls/drought/siding_green.dmi'

/obj/structure/table/f13/mojave/low_wall/prison
	name = "low sided wall"
	icon = 'mojave/icons/turf/walls/drought/prison.dmi'

/obj/structure/table/f13/mojave/low_wall/brick
	name = "low brick wall"
	icon = 'mojave/icons/turf/walls/brick.dmi'

/obj/structure/table/f13/mojave/low_wall/brick/alt
	icon = 'mojave/icons/turf/walls/brickalt.dmi'

/obj/structure/table/f13/mojave/low_wall/brick/gray
	icon = 'mojave/icons/turf/walls/brickgray.dmi'

/obj/structure/table/f13/mojave/low_wall/reinforced
	name = "low reinforced wall"
	icon = 'mojave/icons/turf/walls/rmetal.dmi'

/obj/structure/table/f13/mojave/low_wall/reinforced/rust
	name = "rusted low reinforced metal wall"
	icon = 'mojave/icons/turf/walls/rrustmetal.dmi'

/obj/structure/table/f13/mojave/low_wall/bunker
	name = "low bunker wall"
	icon = 'mojave/icons/turf/walls/bunker.dmi'

/obj/structure/table/f13/mojave/low_wall/sewer
	name = "low sewer wall"
	icon = 'mojave/icons/turf/walls/sewer.dmi'

/obj/structure/table/f13/mojave/low_wall/vault
	name = "low vault wall"
	icon = 'mojave/icons/turf/walls/vault_wall.dmi'

/obj/structure/table/f13/mojave/low_wall/vault/rust
	name = "low vault wall"
	icon = 'mojave/icons/turf/walls/vault_wall_rust.dmi'

/obj/structure/table/f13/mojave/low_wall/dungeon
	name = "low reinforced bunker wall"
	icon = 'mojave/icons/turf/walls/dungeon_1.dmi'

/obj/structure/table/f13/mojave/low_wall/dungeon/rust
	name = "low reinforced bunker wall"
	icon = 'mojave/icons/turf/walls/dungeon_rust_1.dmi'
