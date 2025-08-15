extends "../layers.gd"


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


static func create_safe_timer(map: MapperMap, parent: Node, wait_time: float = 1.0) -> Timer:
	var timer := Timer.new()
	parent.add_child(timer, map.settings.readable_node_names)
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	# Godot timers don't work correctly with small wait times
	timer.wait_time = clampf(wait_time, 0.05, INF)
	return timer
