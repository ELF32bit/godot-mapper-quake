const RENDER_LAYERS_2D := {
}

const PHYSICS_LAYERS_2D := {
}

const NAVIGATION_LAYERS_2D := {
}

const RENDER_LAYERS_3D := {
}

const PHYSICS_LAYERS_3D := {
	"worldspawn-StaticBody3D": 1,
	"worldspawn-liquid-Area3D": 2,
	"worldspawn-liquid-StaticBody3D": 3, # camera blocking
	"worldspawn-liquid-PhysicsBody3D": 4,

	"func_door-Area3D": 5,
	"func_door-CharacterBody3D": 6,
	"func_door-Object": 7,

	"func_door_secret-Area3D": 5,
	"func_door_secret-CharacterBody3D": 6,
	"func_door_secret-Object": 7,

	"func_plat-Area3D": 5,
	"func_plat-CharacterBody3D": 6,
	"func_plat-Object": 7,

	"func_button-Area3D": 5,
	"func_button-CharacterBody3D": 6,

	"func_train-CharacterBody3D": 6,
	"func_train-Object": 7,

	"trigger_changelevel-Area3D": 5,
	"trigger_changelevel-PhysicsBody3D": 6,

	"trigger_once-Area3D": 5,
	"trigger_once-PhysicsBody3D": 6,

	"trigger_multiple-Area3D": 5,
	"trigger_multiple-PhysicsBody3D": 6,

	"trigger_onlyregistered-Area3D": 5,
	"trigger_onlyregistered-PhysicsBody3D": 6,

	"trigger_secret-Area3D": 5,
	"trigger_secret-PhysicsBody3D": 6,

	"trigger_teleport-Area3D": 5,
	"trigger_teleport-PhysicsBody3D": 6,

	"trigger_setskill-Area3D": 5,
	"trigger_setskill-PhysicsBody3D": 6,

	"trigger_monsterjump-Area3D": 5,
	"trigger_monsterjump-PhysicsBody3D": 6,

	"trigger_push-Area3D": 5,
	"trigger_push-PhysicsBody3D": 6,

	"trigger_hurt-Area3D": 5,
	"trigger_hurt-PhysicsBody3D": 6,
}

const NAVIGATION_LAYERS_3D := {
}
