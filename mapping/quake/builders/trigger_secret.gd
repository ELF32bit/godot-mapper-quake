extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# trigger: secret
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_secret-areas"], ["trigger_secret-objects"])

	# setting trigger_secret script and connecting signals
	node.set_script(preload("../scripts/trigger_once.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_once sound player
	var trigger_sound_player := AudioStreamPlayer3D.new()
	node.add_child(trigger_sound_player, map.settings.readable_node_names)
	node.set("_trigger_sound_player", node.get_path_to(trigger_sound_player))

	preload("__post.gd").bind_trigger_base(map, entity, node, trigger_sound_player)

	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = null
		2: # beep beep
			trigger_sound_player.stream = null
		_:
			trigger_sound_player.stream = null

	if entity.get_int_property("spawnflags", 0) & 1: # not touchable
		node.monitoring = false

	return node
