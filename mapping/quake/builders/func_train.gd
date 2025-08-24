extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# moving platform
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		["func_train-CharacterBody3D", "func_train-Object"])

	# setting trigger_train script and connecting signals
	node.set_script(map.loader.load_script("scripts/func_train"))
	node.connect("crushing_character", Callable(node, "_on_crushing_character"), CONNECT_PERSIST)
	node.connect("crushing_object", Callable(node, "_on_crushing_object"), CONNECT_PERSIST)

	# creating func_train sound players
	var move_sound_player := AudioStreamPlayer3D.new()
	node.add_child(move_sound_player, map.settings.readable_node_names)
	node.set("_move_sound_player", node.get_path_to(move_sound_player))

	var stop_sound_player := AudioStreamPlayer3D.new()
	node.add_child(stop_sound_player, map.settings.readable_node_names)
	node.set("_stop_sound_player", node.get_path_to(stop_sound_player))

	# setting default quake sounds
	match entity.get_int_property("sounds", 1):
		0: # silent
			move_sound_player.stream = null
			stop_sound_player.stream = null
		1: # ratchet metal
			move_sound_player.stream = map.loader.load_sound("sounds/plats/train1")
			stop_sound_player.stream = map.loader.load_sound("sounds/plats/train2")

	# using custom sounds if they are loading
	var noise1: AudioStream = entity.get_sound_property("noise1", null)
	var noise2: AudioStream = entity.get_sound_property("noise2", null)
	if entity.get_int_property("sounds", 1) != 0:
		if noise1:
			move_sound_player.stream = noise1
		if noise2:
			stop_sound_player.stream = noise2

	# creating generic wait timer for path_corner
	var wait_timer := create_safe_timer(map, node)
	wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
	node.set("_wait_timer", node.get_path_to(wait_timer))
	wait_timer.one_shot = true

	# removing func_train from voxelGI
	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	# binding func_train properties
	bind_targetname_base(entity)
	if not entity.get_string_property("targetname", "").is_empty():
		node.set("is_waiting_for_signal", true)

	entity.bind_node_path_array_property("target", "targetname", "_targets", "path_corner")
	node.set("speed", entity.get_unit_property("speed", 64.0))
	node.set("damage", entity.get_int_property("dmg", 2))

	# implementation specific property
	entity.bind_float_property("wait", "damage_interval")

	return node
