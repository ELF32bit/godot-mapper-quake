extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: activate multiple
	var node: CollisionObject3D = null
	var has_health := bool(entity.get_int_property("health", -1) > 0)

	# creating trigger_multiple node
	if has_health:
		node = MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D", false, true, false)
		if not node:
			return null
		set_collision_layer_mask(node,
			["worldspawn-StaticBody3D"],
			[])
	else:
		node = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
		if not node:
			return null
		set_collision_layer_mask(node,
			["trigger_multiple-Area3D"],
			["trigger_multiple-PhysicsBody3D"])

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

	# loading trigger_multiple sounds
	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = preload("../sounds/misc/secret.wav")
		2: # beep beep
			trigger_sound_player.stream = preload("../sounds/misc/talk.wav")
		3: # large switch
			trigger_sound_player.stream = preload("../sounds/misc/trigger1.wav")

	# creating trigger_multiple delay timer
	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	# creating trigger_multiple wait timer
	var wait_time: float = entity.get_float_property("wait", 0.2)
	if not wait_time < 0.0:
		var wait_timer := create_safe_timer(map, node, wait_time)
		wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		node.set("_wait_timer", node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	# handling trigger_multiple spawnflags
	if entity.get_int_property("spawnflags", 0) & 1: # not touchable
		if has_health:
			for child in node.get_children():
				if child is CollisionShape3D:
					child.disabled = true
		else:
			node.monitoring = false

	# binding trigger_multiple properties
	bind_trigger_base(entity)
	if has_health:
		entity.bind_int_property("health", "max_health")

	return node
