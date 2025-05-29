extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var has_health: bool = (entity.get_int_property("health", -1) > 0)

	var node: CollisionObject3D = null
	if not has_health:
		node = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
		if not node:
			return null
		node.set_script(preload("../scripts/trigger_once.gd"))
		node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
		node.monitorable = false
		node.collision_layer = 0; node.collision_mask = 0;
		node.set_collision_layer_value(PHYSICS_LAYERS_3D["trigger_once-areas"], true)
		node.set_collision_mask_value(PHYSICS_LAYERS_3D["trigger_once-bodies"], true)
	else:
		node = MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D", false, true, false)
		if not node:
			return null
		node.set_script(preload("../scripts/trigger_once+.gd"))
		node.collision_layer = 0; node.collision_mask = 0;
		node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)

	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	trigger_sound_player.stream = null # TODO: add sound
	node._trigger_sound_player = node.get_path_to(trigger_sound_player)

	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := Timer.new()
		delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.add_child(delay_timer, map.settings.readable_node_names)
		node._delay_timer = node.get_path_to(delay_timer)
		delay_timer.wait_time = clampf(delay_time, 0.05, INF)
		delay_timer.one_shot = true

	if entity.get_int_property("spawnflags", 0) & 1 != 0:
		if not has_health:
			node.monitoring = false
		else:
			for child in node.get_children():
				if child is CollisionShape3D:
					child.disabled = true

	if has_health:
		entity.bind_int_property("health", "max_health")
	entity.bind_string_property("targetname", "name")
	entity.bind_string_property("message", "message")
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")

	return node
