extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: change level
	var node: Area3D = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_changelevel-areas"], ["trigger_changelevel-objects"])

	node.set_script(preload("../scripts/trigger_changelevel.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_changelevel sound players
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	# trigger base
	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = null
		2: # beep beep
			trigger_sound_player.stream = null
		3: # large switch
			trigger_sound_player.stream = null

	# creating generic delay timer
	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := preload("__post.gd").create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node._delay_timer = node.get_path_to(delay_timer)
		delay_timer.one_shot = true

	if entity.get_int_property("spawnflags", 0) & 1: # no intermission
		pass

	# target, targetname base
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_string_property("targetname", "name")

	# trigger base
	entity.bind_string_property("message", "message")

	entity.bind_string_property("map", "map")

	return node
