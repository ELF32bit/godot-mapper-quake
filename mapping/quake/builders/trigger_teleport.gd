extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: teleporter
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node,
		["trigger_teleport-Area3D"],
		["trigger_teleport-PhysicsBody3D"])

	# setting trigger_teleport script and connecting signals
	node.set_script(map.loader.load_script("scripts/trigger_teleport"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_teleport sound player
	var teleport_sound_player := AudioStreamPlayer3D.new()
	node.add_child(teleport_sound_player, map.settings.readable_node_names)
	node.set("_teleport_sound_player", node.get_path_to(teleport_sound_player))

	# loading trigger_teleport default sounds
	var teleport_sounds: Array[AudioStream] = [
		map.loader.load_sound("sounds/misc/r_tele1"),
		map.loader.load_sound("sounds/misc/r_tele2"),
		map.loader.load_sound("sounds/misc/r_tele3"),
		map.loader.load_sound("sounds/misc/r_tele4"),
		map.loader.load_sound("sounds/misc/r_tele5"),
	]
	node.set("teleport_sounds", teleport_sounds)

	# disabling trigger_teleport area if activated by a signal
	if not entity.get_string_property("targetname", "").is_empty():
		node.monitoring = false

	# handling trigger_teleport spawnflags
	var spawnflags: int = entity.get_int_property("spawnflags", 0)
	if spawnflags & 1: # player only
		node.set("player_only", true)
	if spawnflags & 2: # silent
		node.set("teleport_sounds", [])

	# binding trigger_teleport properties
	bind_target_base(entity, "info_teleport_destination")
	bind_targetname_base(entity)

	return node
