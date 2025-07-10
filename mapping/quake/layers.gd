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
	"worldspawn-liquid-bodies": 3, # camera blocking static bodies for third person view
	"worldspawn-liquid-objects": 4,

	"func_door-areas": 5,
	"func_door-characters": 6,
	"func_door-objects": 7,
	"func_plat-areas": 5,
	"func_plat-characters": 6,
	"func_plat-objects": 7,
	"func_button-areas": 5,
	"func_button-characters": 6,
	"func_train-characters": 6,
	"func_train-objects": 7,

	"trigger_changelevel-areas": 5,
	"trigger_changelevel-objects": 6,
	"trigger_once-areas": 5,
	"trigger_once-objects": 6,
	"trigger_multiple-areas": 5,
	"trigger_multiple-objects": 6,
	"trigger_onlyregistered-areas": 5,
	"trigger_onlyregistered-objects": 6,
	"trigger_secret-areas": 5,
	"trigger_secret-objects": 6,
	"trigger_teleport-areas": 5,
	"trigger_teleport-objects": 6,
	"trigger_setskill-areas": 5,
	"trigger_setskill-objects": 6,
	"trigger_monsterjump-areas": 5,
	"trigger_monsterjump-objects": 6,
	"trigger_push-areas": 5,
	"trigger_push-objects": 6,
	"trigger_hurt-areas": 5,
	"trigger_hurt-objects": 6,
}

const NAVIGATION_LAYERS_3D := {
}


static func set_collision_layer_mask(node: CollisionObject3D, layers: Array[StringName] = [], masks: Array[StringName] = []) -> void:
	node.collision_layer = 0
	node.collision_mask = 0
	for layer in layers:
		if not layer in PHYSICS_LAYERS_3D:
			continue
		node.set_collision_layer_value(PHYSICS_LAYERS_3D[layer], true)
	for mask in masks:
		if not mask in PHYSICS_LAYERS_3D:
			continue
		node.set_collision_mask_value(PHYSICS_LAYERS_3D[mask], true)
