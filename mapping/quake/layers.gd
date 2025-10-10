const RENDER_LAYERS_2D := {
}

const PHYSICS_LAYERS_2D := {
}

const NAVIGATION_LAYERS_2D := {
}

const RENDER_LAYERS_3D := {
}

const PHYSICS_LAYERS_3D := {
	"worldspawn-StaticBody3D": 1, # worldspawn
	"worldspawn-liquid-Area3D": 2, # areas that can be entered
	"worldspawn-liquid-PhysicsBody3D": 3, # bodies that can enter areas
	"worldspawn-liquid-StaticBody3D": 4, # OPTIONAL: camera blocking bodies

	"func_door-AnimatableBody3D": 1,
	"func_door-Area3D": 5, # areas that can be entered
	"func_door-CharacterBody3D": 6, # crushable characters that can enter areas
	"func_door-Object": 7, # other crushable objects

	"func_door_secret-AnimatableBody3D": 1,
	"func_door_secret-CharacterBody3D": 6, # crushable characters
	"func_door_secret-Object": 7, # other crushable objects

	"func_plat-AnimatableBody3D": 1,
	"func_plat-Area3D": 5, # areas that can be entered
	"func_plat-CharacterBody3D": 6, # crushable characters that can enter areas
	"func_plat-Object": 7, # other crushable objects

	"func_button-AnimatableBody3D": 1,
	"func_button-Area3D": 5, # areas that can be entered
	"func_button-CharacterBody3D": 6, # characters that can enter areas

	"func_train-AnimatableBody3D": 1,
	"func_train-CharacterBody3D": 6, # crushable characters
	"func_train-Object": 7, # other crushable objects

	"trigger_changelevel-Area3D": 5, # areas that can be entered
	"trigger_changelevel-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_once-StaticBody3D": 1, # health version
	"trigger_once-Area3D": 5, # areas that can be entered
	"trigger_once-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_multiple-StaticBody3D": 1, # health version
	"trigger_multiple-Area3D": 5, # areas that can be entered
	"trigger_multiple-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_onlyregistered-Area3D": 5, # areas that can be entered
	"trigger_onlyregistered-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_secret-Area3D": 5, # areas that can be entered
	"trigger_secret-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_teleport-Area3D": 5, # areas that can be entered
	"trigger_teleport-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_setskill-Area3D": 5, # areas that can be entered
	"trigger_setskill-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_monsterjump-Area3D": 5, # areas that can be entered
	"trigger_monsterjump-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_push-Area3D": 5, # areas that can be entered
	"trigger_push-PhysicsBody3D": 6, # bodies that can enter areas

	"trigger_hurt-Area3D": 5, # areas that can be entered
	"trigger_hurt-PhysicsBody3D": 6, # bodies that can enter areas

	"trap_shooter-Area3D": 1, # projectile areas
	"trap_shooter-PhysicsBody3D": 1, # bodies that can be shot

	"trap_spikeshooter-Area3D": 1, # projectile areas
	"trap_spikeshooter-PhysicsBody3D": 1, # bodies that can be shot

	"misc_fireball-Area3D": 1, # projectile areas
	"misc_fireball-PhysicsBody3D": 1, # bodies that can be shot

	"item_-Area3D": 5, # item areas
	"item_-PhysicsBody3D": 6, # bodies that can pick up items

	"misc_explobox-StaticBody3D": 1,
	"misc_explobox-Area3D": 5,
	"misc_explobox-PhysicsBody3D": 6,

	"func_detail-StaticBody3D": 1,
	"func_wall-StaticBody3D": 1,
}

const NAVIGATION_LAYERS_3D := {
}
