extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	node.set_script(preload("../scripts/func_train.gd"))
	node.connect("crushing_object", Callable(node, "_on_crushing_object"), CONNECT_PERSIST)
	node.connect("crushing_character", Callable(node, "_on_crushing_character"), CONNECT_PERSIST)

	var move_sound_player := AudioStreamPlayer3D.new()
	node.add_child(move_sound_player, map.settings.readable_node_names)
	node._move_sound_player = node.get_path_to(move_sound_player)
	var stop_sound_player := AudioStreamPlayer3D.new()
	node.add_child(stop_sound_player, map.settings.readable_node_names)
	node._stop_sound_player = node.get_path_to(stop_sound_player)
	# setting default quake sounds
	move_sound_player.stream = preload("../sounds/plats/train1.wav")
	stop_sound_player.stream = preload("../sounds/plats/train2.wav")
	# using custom sounds if they are loading
	var noise1_sound: AudioStream = entity.get_sound_property("noise1", null)
	move_sound_player.stream = noise1_sound if noise1_sound else move_sound_player.stream
	var noise2_sound: AudioStream = entity.get_sound_property("noise2", null)
	stop_sound_player.stream = noise2_sound if noise2_sound else stop_sound_player.stream

	var wait_timer := Timer.new()
	wait_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	node.add_child(wait_timer, map.settings.readable_node_names)
	wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
	node._wait_timer = node.get_path_to(wait_timer)
	wait_timer.one_shot = true

	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	if not entity.get_string_property("targetname", "").is_empty():
		node.is_waiting_for_signal = true

	entity.bind_string_property("targetname", "name")
	entity.bind_node_path_array_property("target", "targetname", "_targets", "path_corner")
	entity.bind_float_property("wait", "damage_interval") # implementation specific property
	node.damage = entity.get_int_property("dmg", 1)
	entity.bind_unit_property("speed", "speed")

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["func_train-characters"], true)
	# allowing different trains to collide with each other
	#node.set_collision_layer_value(PHYSICS_LAYERS_3D["func_train-objects"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["func_train-objects"], true)

	return node
