extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: Area3D = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	node.set_script(preload("../scripts/trigger_teleport.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	var teleport_sound_player := AudioStreamPlayer3D.new()
	node.add_child(teleport_sound_player, map.settings.readable_node_names)
	node._teleport_sound_player = node.get_path_to(teleport_sound_player)
	var teleport_sounds: Array[AudioStream] = [
		preload("../sounds/misc/r_tele1.wav"),
		preload("../sounds/misc/r_tele2.wav"),
		preload("../sounds/misc/r_tele3.wav"),
		preload("../sounds/misc/r_tele4.wav"),
		preload("../sounds/misc/r_tele5.wav"),
	]
	node.teleport_sounds = teleport_sounds

	if not entity.get_string_property("targetname", "").is_empty():
		node.monitoring = false

	entity.bind_string_property("targetname", "name")
	entity.bind_node_path_array_property("target", "targetname", "_targets", "info_teleport_destination")

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["trigger_teleport-areas"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["trigger_teleport-bodies"], true)

	return node
