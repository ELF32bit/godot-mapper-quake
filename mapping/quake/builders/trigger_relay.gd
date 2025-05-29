@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := Node3D.new()
	node.set_script(preload("../scripts/trigger_relay.gd"))

	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	trigger_sound_player.stream = null # TODO: add sound
	node._trigger_sound_player = node.get_path_to(trigger_sound_player)

	entity.bind_string_property("targetname", "name")
	entity.bind_string_property("message", "message")
	entity.bind_float_property("delay", "delay_time")
	entity.bind_float_property("wait", "delay_time") # for compatibility
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")

	return node
