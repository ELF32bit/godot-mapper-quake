@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: relay
	var node := Node3D.new()
	node.set_script(preload("../scripts/trigger_relay.gd"))

	# creating trigger_relay sound player
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

	# target, targetname base
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_string_property("targetname", "name")

	# trigger base
	entity.bind_float_property("delay", "delay_time")
	entity.bind_string_property("message", "message")
	entity.bind_float_property("wait", "delay_time") # for compatibility

	return node
