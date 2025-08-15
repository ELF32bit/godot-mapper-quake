extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: registered only
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node,
		["trigger_onlyregistered-Area3D"],
		["trigger_onlyregistered-PhysicsBody3D"])

	# setting trigger_onlyregistered script and connecting signals
	node.set_script(preload("../scripts/trigger_multiple.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_onlyregistered sound player
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	# loading trigger_onlyregistered default sounds
	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = preload("../sounds/misc/secret.wav")
		2: # beep beep
			trigger_sound_player.stream = preload("../sounds/misc/talk.wav")
		3: # large switch
			trigger_sound_player.stream = preload("../sounds/misc/trigger1.wav")

	# creating trigger_onlyregistered delay timer
	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	# handling trigger_onlyregistered spawnflags
	if entity.get_int_property("spawnflags", 0) & 1: # not touchable
		node.monitoring = false

	# binding trigger_onlyregistered properties
	bind_trigger_base(entity)

	return null
