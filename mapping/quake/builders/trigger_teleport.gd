extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: teleporter
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_teleport-areas"], ["trigger_teleport-objects"])

	node.set_script(preload("../scripts/trigger_teleport.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_teleport sound player
	var teleport_sound_player := AudioStreamPlayer3D.new()
	node.add_child(teleport_sound_player, map.settings.readable_node_names)
	node.set("_teleport_sound_player", node.get_path_to(teleport_sound_player))

	# loading default quake sounds
	var teleport_sounds: Array[AudioStream] = [
		preload("../sounds/misc/r_tele1.wav"),
		preload("../sounds/misc/r_tele2.wav"),
		preload("../sounds/misc/r_tele3.wav"),
		preload("../sounds/misc/r_tele4.wav"),
		preload("../sounds/misc/r_tele5.wav"),
	]
	node.set("teleport_sounds", teleport_sounds)

	# handling trigger_teleport spawnflags
	var spawnflags: int = entity.get_int_property("spawnflags", 0)
	if spawnflags & 1:
		pass # player only
	if spawnflags & 2:
		node.set("teleport_sounds", [])
	if not entity.get_string_property("targetname", "").is_empty():
		node.monitoring = false

	# target, targetname base
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_string_property("targetname", "name")

	entity.bind_node_path_array_property("target", "targetname", "_targets", "info_teleport_destination")

	return node
