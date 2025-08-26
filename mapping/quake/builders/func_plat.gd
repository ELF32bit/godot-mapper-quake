extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# elevator
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		["func_plat-CharacterBody3D", "func_plat-Object"])

	# creating root node
	var root_node := Node3D.new()
	root_node.set_script(map.loader.load_script("scripts/func_plat"))
	root_node.transform = node.transform

	# parenting node to root node
	node.set_script(map.loader.load_script("scripts/classes/crushing"))
	MapperUtilities.add_global_child(node, root_node, map.settings)

	# creating func_plat area
	var area := Area3D.new()
	root_node.add_child(area, map.settings.readable_node_names)
	set_collision_layer_mask(area,
		["func_plat-Area3D"],
		["func_plat-CharacterBody3D"])
	root_node.set("_area", root_node.get_path_to(area))

	# connecting func_plat area signals
	area.body_entered.connect(Callable(root_node, "_on_body_entered"), CONNECT_PERSIST)
	node.connect("crushing_character", Callable(root_node, "_on_crushing_character"), CONNECT_PERSIST)
	node.connect("crushing_object", Callable(root_node, "_on_crushing_object"), CONNECT_PERSIST)
	area.monitorable = false

	# creating func_plat sound players
	var move_sound_player := AudioStreamPlayer3D.new()
	move_sound_player.name = "MoveSoundPlayer3D"
	node.add_child(move_sound_player, map.settings.readable_node_names)

	var stop_sound_player := AudioStreamPlayer3D.new()
	stop_sound_player.name = "StopSoundPlayer3D"
	node.add_child(stop_sound_player, map.settings.readable_node_names)

	# loading func_plat default sounds
	match entity.get_int_property("sounds", 0):
		0: # none
			move_sound_player.stream = null
			stop_sound_player.stream = null
		1: # base fast
			move_sound_player.stream = map.loader.load_sound("sounds/plats/plat1")
			stop_sound_player.stream = map.loader.load_sound("sounds/plats/plat2")
		2: # chain slow
			move_sound_player.stream = map.loader.load_sound("sounds/plats/medplat1")
			stop_sound_player.stream = map.loader.load_sound("sounds/plats/medplat2")

	# using custom sounds if they are loading
	var noise1: AudioStream = entity.get_sound_property("noise1", null)
	var noise2: AudioStream = entity.get_sound_property("noise2", null)
	if entity.get_int_property("sounds", 0) != 0:
		if noise1:
			move_sound_player.stream = noise1
		if noise2:
			stop_sound_player.stream = noise2

	if entity.get_int_property("spawnflags", 0) & 1: # low trigger volume
		move_sound_player.volume_db = -10.0
		stop_sound_player.volume_db = -10.0

	# removing func_plat from voxelGI
	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	# getting up axis information for AABB manipulation
	var up_axis := map.settings.get_up_axis()
	var up_axis_index := map.settings.get_up_axis_index()
	var extra_platform_height := 8.0 / map.settings.unit_size

	# creating func_plat area collision shape above platform
	var collision_shape := CollisionShape3D.new()
	var collision_shape_offset := (entity.aabb.size[up_axis_index] + extra_platform_height) / 2.0
	collision_shape.position = entity.aabb.get_center() + up_axis * collision_shape_offset
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = entity.aabb.size
	collision_shape.shape.size[up_axis_index] = extra_platform_height

	# creating func_plat animation player
	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(root_node, "_on_animation_finished"), CONNECT_PERSIST)
	root_node.add_child(animation_player, map.settings.readable_node_names)
	root_node.set("_animation_player", root_node.get_path_to(animation_player))

	# creating wait timer (implementation specific property)
	var wait_time: float = entity.get_float_property("wait", 1.0)
	if not wait_time < 0.0:
		var wait_timer := create_safe_timer(map, root_node, wait_time)
		wait_timer.timeout.connect(Callable(root_node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		root_node.set("_wait_timer", root_node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	# creating animations for func_plat states
	var animations := create_animations(entity, [
		root_node,
		node,
		area,
		collision_shape,
		move_sound_player,
		stop_sound_player,
	], extra_platform_height)

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("extend", animations[0])
	animation_library.add_animation("extended", animations[1])
	animation_library.add_animation("retract", animations[2])
	animation_library.add_animation("retracted", animations[3])
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "retracted"

	# creating reset animation for the animation library
	MapperUtilities.create_reset_animation(animation_player, animation_library)

	# if targeted, the func_plat will spawn in the extended position
	entity.bind_string_property("targetname", "name")
	if not entity.get_string_property("targetname", "").is_empty():
		animation_player.autoplay = "extended"
		area.monitoring = false

	node.set("damage", entity.get_int_property("dmg", 2))

	return root_node


static func create_animations(entity: MapperEntity, nodes: Array[Node], extra_platform_height: float) -> Array[Animation]:
	var root_node: Node3D = nodes[0]
	var node: AnimatableBody3D = nodes[1]
	var area: Area3D = nodes[2]
	var collision_shape: CollisionShape3D = nodes[3]
	var move_sound_player: AudioStreamPlayer3D = nodes[4]
	var stop_sound_player: AudioStreamPlayer3D = nodes[5]

	# animation parameters
	var height: float = entity.get_unit_property("height", 0.0)
	var speed: float = entity.get_unit_property("speed", 150.0)
	var animation_delay: float = 0.15

	# creating empty animations
	var extend_animation := Animation.new()
	var extended_animation := Animation.new()
	var retract_animation := Animation.new()
	var retracted_animation := Animation.new()

	# creating animation track names
	var platform_track := str(node.name)
	var collision_shape_track := str(area.name.path_join(collision_shape.name))
	var collision_shape_size_track := collision_shape_track + ":shape:size"
	var move_sound_playing_track := node.name.path_join(move_sound_player.name) + ":playing"
	var stop_sound_playing_track := node.name.path_join(stop_sound_player.name) + ":playing"

	# creating animation tracks
	extend_animation.add_track(Animation.TYPE_POSITION_3D)
	extend_animation.track_set_path(0, platform_track)
	extend_animation.add_track(Animation.TYPE_POSITION_3D)
	extend_animation.track_set_path(1, collision_shape_track)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(2, collision_shape_size_track)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(3, move_sound_playing_track)
	extend_animation.add_track(Animation.TYPE_VALUE)
	extend_animation.track_set_path(4, stop_sound_playing_track)

	extended_animation.add_track(Animation.TYPE_POSITION_3D)
	extended_animation.track_set_path(0, platform_track)
	extended_animation.add_track(Animation.TYPE_POSITION_3D)
	extended_animation.track_set_path(1, collision_shape_track)
	extended_animation.add_track(Animation.TYPE_VALUE)
	extended_animation.track_set_path(2, collision_shape_size_track)
	extended_animation.add_track(Animation.TYPE_VALUE)
	extended_animation.track_set_path(3, move_sound_playing_track)

	retract_animation.add_track(Animation.TYPE_POSITION_3D)
	retract_animation.track_set_path(0, platform_track)
	retract_animation.add_track(Animation.TYPE_POSITION_3D)
	retract_animation.track_set_path(1, collision_shape_track)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(2, collision_shape_size_track)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(3, move_sound_playing_track)
	retract_animation.add_track(Animation.TYPE_VALUE)
	retract_animation.track_set_path(4, stop_sound_playing_track)

	retracted_animation.add_track(Animation.TYPE_POSITION_3D)
	retracted_animation.track_set_path(0, platform_track)
	retracted_animation.add_track(Animation.TYPE_POSITION_3D)
	retracted_animation.track_set_path(1, collision_shape_track)
	retracted_animation.add_track(Animation.TYPE_VALUE)
	retracted_animation.track_set_path(2, collision_shape_size_track)
	retracted_animation.add_track(Animation.TYPE_VALUE)
	retracted_animation.track_set_path(3, move_sound_playing_track)

	# preparing to create animation key frames
	var inverse_transform := root_node.transform.affine_inverse()
	var up_axis := entity.factory.settings.get_up_axis()
	var up_axis_index := entity.factory.settings.get_up_axis_index()
	var entity_center := entity.aabb.get_center()

	# calculating func_plat positions
	var offset := clampf(height, 0.0, INF)
	if height == 0.0:
		offset = entity.aabb.size[up_axis_index] - extra_platform_height

	var platform_retract_position := inverse_transform * (entity_center - up_axis * offset)
	var platform_extend_position := inverse_transform * entity_center

	var collision_shape_extend_position := collision_shape.position
	var collision_shape_extend_size: Vector3 = collision_shape.shape.size

	var collision_shape_retract_position: Vector3
	var collision_shape_retract_size := entity.aabb.size
	if height == 0.0:
		collision_shape_retract_position = inverse_transform * (entity_center + up_axis * extra_platform_height)
	else:
		var collision_shape_offset := (entity.aabb.size[up_axis_index] + extra_platform_height - height) / 2.0
		collision_shape_retract_position = inverse_transform * (entity_center + up_axis * collision_shape_offset)
		collision_shape_retract_size[up_axis_index] = height + extra_platform_height

	# creating animation frame times
	var frames := [
		0.0,
		animation_delay,
		offset / speed + animation_delay,
		offset / speed + 2.0 * animation_delay
	]

	# inserting keys into animations
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

	extended_animation.length = 0.0
	extended_animation.position_track_insert_key(0, frames[0], platform_extend_position)
	extended_animation.position_track_insert_key(1, frames[0], collision_shape_extend_position)
	extended_animation.track_insert_key(2, frames[0], collision_shape_extend_size)
	extended_animation.track_insert_key(3, frames[0], false)

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

	retracted_animation.length = 0.0
	retracted_animation.position_track_insert_key(0, frames[0], platform_retract_position)
	retracted_animation.position_track_insert_key(1, frames[0], collision_shape_retract_position)
	retracted_animation.track_insert_key(2, frames[0], collision_shape_retract_size)
	retracted_animation.track_insert_key(3, frames[0], false)

	# finishing animation tracks
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

	extended_animation.track_set_imported(0, true)
	extended_animation.track_set_imported(1, true)
	extended_animation.track_set_imported(2, true)
	extended_animation.track_set_imported(3, true)

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

	retracted_animation.track_set_imported(0, true)
	retracted_animation.track_set_imported(1, true)
	retracted_animation.track_set_imported(2, true)
	retracted_animation.track_set_imported(3, true)

	return [extend_animation, extended_animation, retract_animation, retracted_animation]
