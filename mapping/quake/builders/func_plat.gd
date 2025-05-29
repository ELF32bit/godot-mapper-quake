extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	node.set_script(preload("../scripts/classes/PhysicsCrushingBody3D.gd"))

	var root := Node3D.new()
	root.set_script(preload("../scripts/func_plat.gd"))
	root.transform = node.transform
	if map.settings.brush_aabb_metadata_property_enabled: # only for size
		root.set_meta(map.settings.brush_aabb_metadata_property, entity.aabb)

	var area := Area3D.new()
	area.body_entered.connect(Callable(root, "_on_body_entered"), CONNECT_PERSIST)
	node.connect("crushing_object", Callable(root, "_on_crushing_object"), CONNECT_PERSIST)
	node.connect("crushing_character", Callable(root, "_on_crushing_character"), CONNECT_PERSIST)
	area.monitorable = false
	area.transform = node.transform
	MapperUtilities.add_global_child(area, root, map.settings)
	root._area = root.get_path_to(area)

	MapperUtilities.add_global_child(node, root, map.settings)

	var move_sound_player := AudioStreamPlayer3D.new()
	node.add_child(move_sound_player, map.settings.readable_node_names)
	var stop_sound_player := AudioStreamPlayer3D.new()
	node.add_child(stop_sound_player, map.settings.readable_node_names)

	match entity.get_int_property("sounds", 0): # TODO: set correct sounds
		0:
			move_sound_player.stream = null
			stop_sound_player.stream = null
		1:
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		2:
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
	# using custom sounds if they are loading
	var noise1_sound: AudioStream = entity.get_sound_property("noise1", null)
	move_sound_player.stream = noise1_sound if noise1_sound else move_sound_player.stream
	var noise2_sound: AudioStream = entity.get_sound_property("noise2", null)
	stop_sound_player.stream = noise2_sound if noise2_sound else stop_sound_player.stream

	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	var up_axis_index := (map.settings.basis * Vector3(0, 0, 1)).normalized().max_axis_index()
	var up_vector: Vector3 = [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD][up_axis_index]
	var extra_platform_height := 8.0 / map.settings.unit_size

	var collision_shape := CollisionShape3D.new()
	collision_shape.position = entity.aabb.get_center() + up_vector * (entity.aabb.size[up_axis_index] + extra_platform_height) / 2.0
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = entity.aabb.size
	collision_shape.shape.size[up_axis_index] = extra_platform_height

	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(root, "_on_animation_finished"), CONNECT_PERSIST)
	root.add_child(animation_player, map.settings.readable_node_names)
	root._animation_player = root.get_path_to(animation_player)

	var wait_time: float = entity.get_float_property("wait", 1.0)
	if not wait_time < 0.0:
		var wait_timer := Timer.new()
		wait_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		wait_timer.timeout.connect(Callable(root, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		root.add_child(wait_timer, map.settings.readable_node_names)
		root._wait_timer = root.get_path_to(wait_timer)
		wait_timer.wait_time = clampf(wait_time, 0.05, INF)
		wait_timer.one_shot = true

	var reset_animation := Animation.new()
	var extend_animation := Animation.new()
	var extended_animation := Animation.new()
	var retract_animation := Animation.new()
	var retracted_animation := Animation.new()

	var platform_track_name: String = node.name
	var collision_shape_track_name: String = area.name.path_join(collision_shape.name)
	var collision_shape_size_track_name := collision_shape_track_name.path_join(":shape:size")
	var move_sound_playing_track_name := platform_track_name.path_join(move_sound_player.name) + ":playing"
	var stop_sound_playing_track_name := platform_track_name.path_join(stop_sound_player.name) + ":playing"

	reset_animation.add_track(Animation.TYPE_POSITION_3D)
	reset_animation.track_set_path(0, platform_track_name)
	reset_animation.add_track(Animation.TYPE_POSITION_3D)
	reset_animation.track_set_path(1, collision_shape_track_name)
	reset_animation.add_track(Animation.TYPE_VALUE)
	reset_animation.track_set_path(2, collision_shape_size_track_name)
	reset_animation.add_track(Animation.TYPE_VALUE)
	reset_animation.track_set_path(3, move_sound_playing_track_name)
	reset_animation.add_track(Animation.TYPE_VALUE)
	reset_animation.track_set_path(4, stop_sound_playing_track_name)

	retracted_animation.add_track(Animation.TYPE_POSITION_3D)
	retracted_animation.track_set_path(0, platform_track_name)
	retracted_animation.add_track(Animation.TYPE_POSITION_3D)
	retracted_animation.track_set_path(1, collision_shape_track_name)
	retracted_animation.add_track(Animation.TYPE_VALUE)
	retracted_animation.track_set_path(2, collision_shape_size_track_name)
	retracted_animation.add_track(Animation.TYPE_VALUE)
	retracted_animation.track_set_path(3, move_sound_playing_track_name)

	extended_animation.add_track(Animation.TYPE_POSITION_3D)
	extended_animation.track_set_path(0, platform_track_name)
	extended_animation.add_track(Animation.TYPE_POSITION_3D)
	extended_animation.track_set_path(1, collision_shape_track_name)
	extended_animation.add_track(Animation.TYPE_VALUE)
	extended_animation.track_set_path(2, collision_shape_size_track_name)
	extended_animation.add_track(Animation.TYPE_VALUE)
	extended_animation.track_set_path(3, move_sound_playing_track_name)

	extend_animation.add_track(Animation.TYPE_POSITION_3D)
	extend_animation.track_set_path(0, platform_track_name)
	extend_animation.add_track(Animation.TYPE_POSITION_3D)
	extend_animation.track_set_path(1, collision_shape_track_name)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(2, collision_shape_size_track_name)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(3, move_sound_playing_track_name)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(4, stop_sound_playing_track_name)

	retract_animation.add_track(Animation.TYPE_POSITION_3D)
	retract_animation.track_set_path(0, platform_track_name)
	retract_animation.add_track(Animation.TYPE_POSITION_3D)
	retract_animation.track_set_path(1, collision_shape_track_name)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(2, collision_shape_size_track_name)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(3, move_sound_playing_track_name)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(4, stop_sound_playing_track_name)

	var height: float = entity.get_unit_property("height", 0.0)
	var speed: float = entity.get_unit_property("speed", 150.0)
	var animation_delay: float = 0.15

	var inverse_transform := root.transform.affine_inverse()
	var offset := clampf(height, 0.0, INF)
	if height == 0.0:
		offset = entity.aabb.size[up_axis_index] - extra_platform_height
	var platform_retract_position := inverse_transform * (entity.aabb.get_center() - up_vector * offset)
	var platform_extend_position := inverse_transform * entity.aabb.get_center()
	var collision_shape_extend_position := collision_shape.position
	var collision_shape_extend_size: Vector3 = collision_shape.shape.size
	var collision_shape_retract_position: Vector3
	var collision_shape_retract_size := entity.aabb.size
	if height == 0.0:
		collision_shape_retract_position = inverse_transform * (entity.aabb.get_center() + up_vector * extra_platform_height)
	else:
		collision_shape_retract_position = inverse_transform * (entity.aabb.get_center() + up_vector * (entity.aabb.size[up_axis_index] + extra_platform_height - height) / 2.0)
		collision_shape_retract_size[up_axis_index] = height + extra_platform_height
	if map.settings.brush_aabb_metadata_property_enabled:
		var retract_area_aabb := AABB(collision_shape_retract_position, collision_shape_retract_size)
		var extend_area_aabb := AABB(collision_shape_extend_position, collision_shape_extend_size)
		area.set_meta(map.settings.brush_aabb_metadata_property + "_retracted", retract_area_aabb)
		area.set_meta(map.settings.brush_aabb_metadata_property + "_extended", extend_area_aabb)
	var frames := [0.0, animation_delay, offset / speed + animation_delay, offset / speed + 2.0 * animation_delay]

	reset_animation.length = 0.0
	reset_animation.position_track_insert_key(0, frames[0], platform_extend_position)
	reset_animation.position_track_insert_key(1, frames[0], collision_shape_extend_position)
	reset_animation.track_insert_key(2, frames[0], collision_shape_extend_size)
	reset_animation.track_insert_key(3, frames[0], false)
	reset_animation.track_insert_key(4, frames[0], false)

	retracted_animation.length = 0.0
	retracted_animation.position_track_insert_key(0, frames[0], platform_retract_position)
	retracted_animation.position_track_insert_key(1, frames[0], collision_shape_retract_position)
	retracted_animation.track_insert_key(2, frames[0], collision_shape_retract_size)
	retracted_animation.track_insert_key(3, frames[0], false)

	extended_animation.length = 0.0
	extended_animation.position_track_insert_key(0, frames[0], platform_extend_position)
	extended_animation.position_track_insert_key(1, frames[0], collision_shape_extend_position)
	extended_animation.track_insert_key(2, frames[0], collision_shape_extend_size)
	extended_animation.track_insert_key(3, frames[0], false)

	extend_animation.length = frames[3]
	extend_animation.position_track_insert_key(0, frames[1], platform_retract_position)
	extend_animation.position_track_insert_key(1, frames[1], collision_shape_retract_position)
	extend_animation.track_insert_key(2, frames[1], collision_shape_retract_size)
	extend_animation.track_insert_key(3, frames[1], true)
	extend_animation.position_track_insert_key(0, frames[2], platform_extend_position)
	extend_animation.position_track_insert_key(1, frames[2], collision_shape_extend_position)
	extend_animation.track_insert_key(2, frames[2], collision_shape_extend_size)
	extend_animation.track_insert_key(3, frames[2], false)
	extend_animation.track_insert_key(4, frames[2], true)

	retract_animation.length = frames[3]
	retract_animation.position_track_insert_key(0, frames[1], platform_extend_position)
	retract_animation.position_track_insert_key(1, frames[1], collision_shape_extend_position)
	retract_animation.track_insert_key(2, frames[1], collision_shape_extend_size)
	retract_animation.track_insert_key(3, frames[1], true)
	retract_animation.position_track_insert_key(0, frames[2], platform_retract_position)
	retract_animation.position_track_insert_key(1, frames[2], collision_shape_retract_position)
	retract_animation.track_insert_key(2, frames[2], collision_shape_retract_size)
	retract_animation.track_insert_key(3, frames[2], false)
	retract_animation.track_insert_key(4, frames[2], true)

	reset_animation.track_set_imported(0, true)
	reset_animation.track_set_imported(1, true)
	reset_animation.track_set_imported(2, true)
	reset_animation.track_set_imported(3, true)
	reset_animation.track_set_imported(4, true)

	retracted_animation.track_set_imported(0, true)
	retracted_animation.track_set_imported(1, true)
	retracted_animation.track_set_imported(2, true)
	retracted_animation.track_set_imported(3, true)

	extended_animation.track_set_imported(0, true)
	extended_animation.track_set_imported(1, true)
	extended_animation.track_set_imported(2, true)
	extended_animation.track_set_imported(3, true)

	extend_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	extend_animation.track_set_interpolation_loop_wrap(0, false)
	extend_animation.track_set_imported(0, true)
	extend_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_LINEAR)
	extend_animation.track_set_interpolation_loop_wrap(1, false)
	extend_animation.track_set_imported(1, true)
	extend_animation.value_track_set_update_mode(2, Animation.UPDATE_CONTINUOUS)
	extend_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_LINEAR)
	extend_animation.track_set_interpolation_loop_wrap(2, false)
	extend_animation.track_set_imported(2, true)
	extend_animation.value_track_set_update_mode(3, Animation.UPDATE_DISCRETE)
	extend_animation.track_set_interpolation_type(3, Animation.INTERPOLATION_NEAREST)
	extend_animation.track_set_interpolation_loop_wrap(3, false)
	extend_animation.track_set_imported(3, true)
	extend_animation.value_track_set_update_mode(4, Animation.UPDATE_DISCRETE)
	extend_animation.track_set_interpolation_type(4, Animation.INTERPOLATION_NEAREST)
	extend_animation.track_set_interpolation_loop_wrap(4, false)
	extend_animation.track_set_imported(4, true)

	retract_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	retract_animation.track_set_interpolation_loop_wrap(0, false)
	retract_animation.track_set_imported(0, true)
	retract_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_LINEAR)
	retract_animation.track_set_interpolation_loop_wrap(1, false)
	retract_animation.track_set_imported(1, true)
	retract_animation.value_track_set_update_mode(2, Animation.UPDATE_CONTINUOUS)
	retract_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_LINEAR)
	retract_animation.track_set_interpolation_loop_wrap(2, false)
	retract_animation.track_set_imported(2, true)
	retract_animation.value_track_set_update_mode(3, Animation.UPDATE_DISCRETE)
	retract_animation.track_set_interpolation_type(3, Animation.INTERPOLATION_NEAREST)
	retract_animation.track_set_interpolation_loop_wrap(3, false)
	retract_animation.track_set_imported(3, true)
	retract_animation.value_track_set_update_mode(4, Animation.UPDATE_DISCRETE)
	retract_animation.track_set_interpolation_type(4, Animation.INTERPOLATION_NEAREST)
	retract_animation.track_set_interpolation_loop_wrap(4, false)
	retract_animation.track_set_imported(4, true)

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("RESET", reset_animation)
	animation_library.add_animation("extend", extend_animation)
	animation_library.add_animation("extended", extended_animation)
	animation_library.add_animation("retract", retract_animation)
	animation_library.add_animation("retracted", retracted_animation)
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "retracted"

	if not entity.get_string_property("targetname", "").is_empty():
		animation_player.autoplay = "extended"
		area.monitoring = false

	entity.bind_string_property("targetname", "name")
	node.damage = entity.get_int_property("dmg", 1)

	area.collision_layer = 0; area.collision_mask = 0;
	area.set_collision_layer_value(PHYSICS_LAYERS_3D["func_plat-areas"], true)
	area.set_collision_mask_value(PHYSICS_LAYERS_3D["func_plat-characters"], true)

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["func_plat-characters"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["func_plat-objects"], true)

	return root
