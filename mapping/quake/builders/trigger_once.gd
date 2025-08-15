extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: activate once
	var node: CollisionObject3D = null
	var has_health := bool(entity.get_int_property("health", -1) > 0)

	# creating trigger_once node
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
			["trigger_once-Area3D"],
			["trigger_once-CollisionObject3D"])

	# setting trigger_once script and connecting signals
	if has_health:
		node.set_script(preload("../scripts/trigger_once-health.gd"))
	else:
		node.set_script(preload("../scripts/trigger_once.gd"))
		node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
		node.monitorable = false

	# creating trigger_once sound player
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	# loading trigger_once default sounds
	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = preload("../sounds/misc/secret.wav")
		2: # beep beep
			trigger_sound_player.stream = preload("../sounds/misc/talk.wav")
		3: # large switch
			trigger_sound_player.stream = preload("../sounds/misc/trigger1.wav")
		_:
			trigger_sound_player.stream = null

	# creating trigger_once delay timer
	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	# handling trigger_once spawnflags
	if entity.get_int_property("spawnflags", 0) & 1: # not touchable
		if has_health:
			for child in node.get_children():
				if child is CollisionShape3D:
					child.disabled = true
		else:
			node.monitoring = false

	# binding trigger_once properties
	bind_trigger_base(entity)
	if has_health:
		entity.bind_int_property("health", "max_health")

	return node
