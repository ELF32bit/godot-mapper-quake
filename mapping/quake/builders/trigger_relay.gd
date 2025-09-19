extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: relay
	var node := Node3D.new()
	node.set_script(map.loader.load_script("scripts/trigger_relay"))

	# creating trigger_relay sound player
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	trigger_sound_player.name = "TriggerSoundPlayer3D"

	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	# loading trigger_relay default sounds
	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = map.loader.load_sound("sounds/misc/secret")
		2: # beep beep
			trigger_sound_player.stream = map.loader.load_sound("sounds/misc/talk")
		3: # large switch
			trigger_sound_player.stream = map.loader.load_sound("sounds/misc/trigger1")

	# binding trigger_relay properties
	bind_trigger_base(entity)
	entity.bind_float_property("wait", "delay_time") # for compatibility

	return node
