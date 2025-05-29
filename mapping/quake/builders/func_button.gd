extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: Node = preload("func_wall.gd").build(map, entity)
	if not node:
		return null
	node = MapperUtilities.change_node_type(node, "AnimatableBody3D")

	var root := Node3D.new()
	root.set_script(preload("../scripts/func_button.gd"))
	root.transform = node.transform
	if map.settings.brush_aabb_metadata_property_enabled: # only for size
		root.set_meta(map.settings.brush_aabb_metadata_property, entity.aabb)

	var area := Area3D.new()
	area.body_entered.connect(Callable(root, "_on_body_entered"), CONNECT_PERSIST)
	area.monitorable = false
	area.transform = node.transform
	MapperUtilities.add_global_child(area, root, map.settings)
	root._area = root.get_path_to(area)

	var collision_shape := CollisionShape3D.new()
	collision_shape.position = entity.aabb.get_center()
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	var grow_units: float = 16.0 / map.settings.unit_size
	collision_shape.shape.size = entity.aabb.grow(grow_units).size
	if map.settings.brush_aabb_metadata_property_enabled:
		area.set_meta(map.settings.brush_aabb_metadata_property, entity.aabb.grow(grow_units))

	var entity_health: int = entity.get_int_property("health", 0)
	if entity_health > 0:
		var c_alternative_texture: Variant = node.alternative_texture
		var c_alternative_texture_fps: Variant = node.alternative_texture_fps
		var c_alternative_textures: Variant = node.alternative_textures
		var c_affected_materials: Variant = node.affected_materials
		node.set_script(preload("../scripts/func_button+.gd"))
		node.alternative_texture = c_alternative_texture
		node.alternative_texture_fps = c_alternative_texture_fps
		node.alternative_textures = c_alternative_textures
		node.affected_materials = c_affected_materials
		# finishing switching button script and setting up connections
		node.connect("generic", Callable(root, "_on_health_ended"), CONNECT_PERSIST)
		node.max_health = entity_health
		area.monitoring = false

	MapperUtilities.add_global_child(node, root, map.settings)
	root._animatable_body = root.get_path_to(node)

	var press_sound_player := AudioStreamPlayer3D.new()
	node.add_child(press_sound_player, map.settings.readable_node_names)
	root._press_sound_player = root.get_path_to(press_sound_player)

	match entity.get_int_property("sounds", 0):
		0:
			press_sound_player.stream = preload("../sounds/buttons/airbut1.wav")
		1:
			press_sound_player.stream = preload("../sounds/buttons/switch21.wav")
		2:
			press_sound_player.stream = preload("../sounds/buttons/switch02.wav")
		3:
			press_sound_player.stream = preload("../sounds/buttons/switch04.wav")
	# using custom sounds if they are loading
	var noise_sound: AudioStream = entity.get_sound_property("noise", null)
	press_sound_player.stream = noise_sound if noise_sound else press_sound_player.stream

	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

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
	var press_animation := Animation.new()
	var pressed_animation := Animation.new()
	var release_animation := Animation.new()
	var released_animation := Animation.new()

	var button_track_name := str(root.get_path_to(node))
	var button_track_alternative_texture_property := button_track_name + ":alternative_texture"

	reset_animation.add_track(Animation.TYPE_POSITION_3D)
	reset_animation.track_set_path(0, button_track_name)
	reset_animation.add_track(Animation.TYPE_VALUE)
	reset_animation.track_set_path(1, button_track_alternative_texture_property)

	pressed_animation.add_track(Animation.TYPE_POSITION_3D)
	pressed_animation.track_set_path(0, button_track_name)
	pressed_animation.add_track(Animation.TYPE_VALUE)
	pressed_animation.track_set_path(1, button_track_alternative_texture_property)

	released_animation.add_track(Animation.TYPE_POSITION_3D)
	released_animation.track_set_path(0, button_track_name)

	press_animation.add_track(Animation.TYPE_POSITION_3D)
	press_animation.track_set_path(0, button_track_name)

	release_animation.add_track(Animation.TYPE_POSITION_3D)
	release_animation.track_set_path(0, button_track_name)
	release_animation.add_track(Animation.TYPE_VALUE)
	release_animation.track_set_path(1, button_track_alternative_texture_property)

	var lip: float = entity.get_unit_property("lip", 4.0)
	var speed: float = entity.get_unit_property("speed", 40.0)
	var wait: float = entity.get_float_property("wait", 1.0)

	var inverse_transform := root.transform.affine_inverse()
	var button_release_position := inverse_transform * entity.aabb.get_center()
	var forward: Vector3 = -root.basis.z.normalized()
	var local_forward: Vector3 = -node.basis.z.normalized()
	var axis_index := forward.abs().max_axis_index()
	var offset := clampf(entity.aabb.size[axis_index] - lip, 0.0, INF) # different from door
	var button_press_position := button_release_position + local_forward * offset
	var frames := [0.0, offset / speed, offset / speed + wait, 2.0 * offset / speed + wait]

	reset_animation.length = 0.0
	reset_animation.position_track_insert_key(0, frames[0], button_release_position)
	reset_animation.track_insert_key(1, frames[0], 0)

	pressed_animation.length = 0.0
	pressed_animation.position_track_insert_key(0, frames[0], button_press_position)
	pressed_animation.track_insert_key(1, frames[0], 1)

	released_animation.length = 0.0
	released_animation.position_track_insert_key(0, frames[0], button_release_position)

	press_animation.length = frames[1]
	press_animation.position_track_insert_key(0, frames[0], button_release_position)
	press_animation.position_track_insert_key(0, frames[1], button_press_position)

	release_animation.length = frames[1]
	release_animation.position_track_insert_key(0, frames[0], button_press_position)
	release_animation.position_track_insert_key(0, frames[1], button_release_position)
	release_animation.track_insert_key(1, frames[0], 0)

	reset_animation.track_set_imported(0, true)
	reset_animation.track_set_imported(1, true)
	pressed_animation.track_set_imported(0, true)
	released_animation.track_set_imported(0, true)

	press_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	press_animation.track_set_interpolation_loop_wrap(0, false)
	press_animation.track_set_imported(0, true)

	release_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	release_animation.track_set_interpolation_loop_wrap(0, false)
	release_animation.track_set_imported(0, true)
	release_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	release_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	release_animation.track_set_interpolation_loop_wrap(1, false)
	release_animation.track_set_imported(1, true)

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("RESET", reset_animation)
	animation_library.add_animation("press", press_animation)
	animation_library.add_animation("pressed", pressed_animation)
	animation_library.add_animation("release", release_animation)
	animation_library.add_animation("released", released_animation)
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "released"

	entity.bind_string_property("targetname", "name")
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_float_property("delay", "delay_time")
	entity.bind_string_property("message", "message")

	area.collision_layer = 0; area.collision_mask = 0;
	area.set_collision_layer_value(PHYSICS_LAYERS_3D["func_button-areas"], true)
	area.set_collision_mask_value(PHYSICS_LAYERS_3D["func_button-characters"], true)

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)

	return root
