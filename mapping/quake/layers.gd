class_name MapperQuake

const RENDER_LAYERS_2D := {}
const PHYSICS_LAYERS_2D := {}
const NAVIGATION_LAYERS_2D := {}
const RENDER_LAYERS_3D := {}
const NAVIGATION_LAYERS_3D := {}

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

	"item-Area3D": 5, # item areas
	"item-PhysicsBody3D": 6, # bodies that can pick up items

	"trap_shooter-Area3D": 1, # projectile areas
	"trap_shooter-PhysicsBody3D": 1, # bodies that can be shot

	"trap_spikeshooter-Area3D": 1, # projectile areas
	"trap_spikeshooter-PhysicsBody3D": 1, # bodies that can be shot

	"misc_explobox-StaticBody3D": 1,
	"misc_explobox-Area3D": 5, # explosion area
	"misc_explobox-PhysicsBody3D": 6, # bodies that can be exploded

	"misc_fireball-Area3D": 1, # projectile areas
	"misc_fireball-PhysicsBody3D": 1, # bodies that can be shot
}


static func set_collision_layer_mask(node: CollisionObject3D, layers: Array[StringName] = [], masks: Array[StringName] = []) -> void:
	node.collision_layer = 0
	node.collision_mask = 0
	for layer in layers:
		if not layer in PHYSICS_LAYERS_3D:
			push_warning("Layer %s not found in Quake layers." % [layer])
			continue
		node.set_collision_layer_value(PHYSICS_LAYERS_3D[layer], true)
	for mask in masks:
		if not mask in PHYSICS_LAYERS_3D:
			push_warning("Mask %s not found in Quake layers." % [mask])
			continue
		node.set_collision_mask_value(PHYSICS_LAYERS_3D[mask], true)


static func create_safe_timer(map: MapperMap, parent: Node, wait_time: float = 1.0, name: String = "") -> Timer:
	var timer := Timer.new()
	if not name.is_empty():
		timer.name = name
	parent.add_child(timer, map.settings.readable_node_names)
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	# Godot timers don't work correctly with small wait times
	timer.wait_time = clampf(wait_time, 0.05, INF)
	return timer


static func bind_appearflags_base(map: MapperMap, entity: MapperEntity) -> bool:
	entity.bind_int_property("spawnflags", "spawnflags")
	match map.settings.options.get("game_mode"):
		"easy":
			if entity.get_int_property("spawnflags", 0) & 256:
				return true
		"normal":
			if entity.get_int_property("spawnflags", 0) & 512:
				return true
		"hard":
			if entity.get_int_property("spawnflags", 0) & 1024:
				return true
		"deathmatch":
			if entity.get_int_property("spawnflags", 0) & 2048:
				return true
	return false


static func bind_targetname_base(entity: MapperEntity) -> void:
	entity.bind_string_property("targetname", "name")


static func bind_target_base(entity: MapperEntity, target_classname: String = "*") -> void:
	entity.bind_node_path_property("target", "targetname", "_target", target_classname)
	entity.bind_node_path_property("killtarget", "targetname", "_kill_target", target_classname)
	entity.bind_node_path_array_property("target", "targetname", "_targets", target_classname)
	entity.bind_node_path_array_property("killtarget", "targetname", "_kill_targets", target_classname)
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal", target_classname)
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free", target_classname)


static func bind_item_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_string_property("message", "message")
	entity.bind_float_property("delay", "delay_time")


static func bind_weapon_base(entity: MapperEntity) -> void:
	bind_item_base(entity)


static func bind_ammo_base(entity: MapperEntity) -> void:
	bind_item_base(entity)


static func bind_trigger_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_int_property("sounds", "sounds")
	entity.bind_float_property("delay", "delay_time")
	entity.bind_string_property("message", "message")


static func bind_monster_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
