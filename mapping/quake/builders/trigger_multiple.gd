extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# trigger: activate multiple
	var node: CollisionObject3D = null
	var has_health := bool(entity.get_int_property("health", -1) > 0)

	# creating trigger_multiple node
	if has_health:
		node = MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D", false, true, false)
		if not node:
			return null
		set_collision_layer_mask(node, ["worldspawn"], [])
	else:
		node = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
		if not node:
			return null
		set_collision_layer_mask(node, ["trigger_multiple-areas"], ["trigger_multiple-characters"])

	# setting trigger_multiple script and connecting signals
	if has_health:
		node.set_script(preload("../scripts/trigger_multiple-health.gd"))
	else:
		node.set_script(preload("../scripts/trigger_multiple.gd"))
		node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
		node.monitorable = false

	# creating trigger_multiple sound player
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	preload("__post.gd").bind_trigger_base(map, entity, node, trigger_sound_player)

	var wait_time: float = entity.get_float_property("wait", 0.2)
	if not wait_time < 0.0:
		var wait_timer := preload("__post.gd").create_safe_timer(map, node, wait_time)
		wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		node.set("_wait_timer", node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	if has_health:
		entity.bind_int_property("health", "max_health")

	if entity.get_int_property("spawnflags", 0) & 1: # not touchable
		if has_health:
			for child in node.get_children():
				if child is CollisionShape3D:
					child.disabled = true
		else:
			node.monitoring = false

	return node
