const RENDER_LAYERS_2D := {
}

const PHYSICS_LAYERS_2D := {
}

const NAVIGATION_LAYERS_2D := {
}

const RENDER_LAYERS_3D := {
}

const PHYSICS_LAYERS_3D := {
	"worldspawn": 1,
	"worldspawn-liquid-areas": 2,
	"worldspawn-liquid-bodies": 3, # camera blocking static bodies
	"worldspawn-liquid-characters": 4, # characters that can enter swim areas
	"func_door-areas": 5,
	"func_door-characters": 6, # characters that can opens doors
	"func_door-objects": 7, # objects other than characters that can be crushed
	"func_plat-areas": 5,
	"func_plat-characters": 6, # characters that can trigger platforms
	"func_plat-objects": 7, # objects other than characters that can be crushed
	"func_button-areas": 5,
	"func_button-characters": 6,
	"func_train-characters": 6, # crushable characters
	"func_train-objects": 7, # crushable objects other than characters
	"trigger_teleport-areas": 5,
	"trigger_teleport-bodies": 6,
	"trigger_push-areas": 5,
	"trigger_push-bodies": 6,
	"trigger_once-areas": 5,
	"trigger_once-bodies": 6,
	"trigger_multiple-areas": 5,
	"trigger_multiple-bodies": 6, #TODO: not implemented
	"trigger_changelevel-areas": 5,
	"trigger_changelevel-bodies": 6,
}

const NAVIGATION_LAYERS_3D := {
}
