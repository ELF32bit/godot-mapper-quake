extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# button
	var node: Node = preload("func_wall.gd").build(map, entity)
	if not node:
		return null
	node = MapperUtilities.change_node_type(node, "AnimatableBody3D")
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		[])

	# creating func_button root node
	var root_node := Node3D.new()
	root_node.set_script(map.loader.load_script("scripts/func_button"))
	root_node.transform = node.transform

	# parenting func_button node to root node
	MapperUtilities.add_global_child(node, root_node, map.settings)
	root_node.set("_animatable_body", root_node.get_path_to(node))

	# creating func_button area
	var area := Area3D.new()
	root_node.add_child(area, map.settings.readable_node_names)
	set_collision_layer_mask(area,
		["func_button-Area3D"],
		["func_button-CharacterBody3D"])
	root_node.set("_area", root_node.get_path_to(area))

	# connecting func_button area signals
	area.body_entered.connect(Callable(root_node, "_on_body_entered"), CONNECT_PERSIST)
	area.monitorable = false

	# creating func_button area collision shape
	var collision_shape := CollisionShape3D.new()
	collision_shape.position = entity.aabb.get_center()
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	var grow_units: float = 16.0 / map.settings.unit_size
	collision_shape.shape.size = entity.aabb.grow(grow_units).size

	# handling func_button variant with health
	var entity_health: int = maxi(entity.get_int_property("health", 0), 0)
	if entity_health > 0:
		var alternative_texture: Variant = node.get("alternative_texture")
		var alternative_speed_scale: Variant = node.get("alternative_speed_scale")
		var alternative_textures: Variant = node.get("alternative_textures")
		var affected_materials: Variant = node.get("affected_materials")
		node.set_script(map.loader.load_script("scripts/func_button-health"))
		node.set("alternative_texture", alternative_texture)
		node.set("alternative_speed_scale", alternative_speed_scale)
		node.set("alternative_textures", alternative_textures)
		node.set("affected_materials", affected_materials)

		# finishing switching button script and setting up connections
		node.connect("generic", Callable(root_node, "_on_health_ended"), CONNECT_PERSIST)
		node.set("max_health", entity_health)
		area.monitoring = false

	# creating func_button sound player
	var press_sound_player := AudioStreamPlayer3D.new()
	press_sound_player.name = "PressSoundPlayer3D"
	node.add_child(press_sound_player, map.settings.readable_node_names)
	root_node.set("_press_sound_player", root_node.get_path_to(press_sound_player))

	# loading func_button default sounds
	match entity.get_int_property("sounds", 0):
		0: # steam metal
			press_sound_player.stream = map.loader.load_sound("sounds/buttons/airbut1")
		1: # wooden clunk
			press_sound_player.stream = map.loader.load_sound("sounds/buttons/switch21")
		2: # metallic clink
			press_sound_player.stream = map.loader.load_sound("sounds/buttons/switch02")
		3: # in-out
			press_sound_player.stream = map.loader.load_sound("sounds/buttons/switch04")

	# using custom func_button sounds if they are loading
	var noise: AudioStream = entity.get_sound_property("noise", null)
	if noise:
		press_sound_player.stream = noise

	# removing func_button from voxelGI
	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	# creating func_button animation player
	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(root_node, "_on_animation_finished"), CONNECT_PERSIST)
	root_node.add_child(animation_player, map.settings.readable_node_names)
	root_node.set("_animation_player", root_node.get_path_to(animation_player))

	# creating func_button wait timer
	var wait_time: float = entity.get_float_property("wait", 1.0)
	if not wait_time < 0.0:
		var wait_timer := create_safe_timer(map, root_node, wait_time, "WaitTimer")
		wait_timer.timeout.connect(Callable(root_node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		root_node.set("_wait_timer", root_node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	# creating animations for func_button states
	var animations := create_animations(entity, [root_node, node])

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("press", animations[0])
	animation_library.add_animation("pressed", animations[1])
	animation_library.add_animation("release", animations[2])
	animation_library.add_animation("released", animations[3])
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "released"

	# creating reset animation for the animation library
	MapperUtilities.create_reset_animation(animation_player, animation_library)

	# binding func_button properties
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_float_property("delay", "delay_time")
	entity.bind_string_property("message", "message")

	return root_node


static func create_animations(entity: MapperEntity, nodes: Array[Node]) -> Array[Animation]:
	var root_node: Node3D = nodes[0]
	var node: AnimatableBody3D = nodes[1]

	# animation parameters
	var lip: float = entity.get_unit_property("lip", 4.0)
	var speed: float = entity.get_unit_property("speed", 40.0)

	# creating empty animations
	var press_animation := Animation.new()
	var pressed_animation := Animation.new()
	var release_animation := Animation.new()
	var released_animation := Animation.new()

	# creating animation track names
	var button_track := str(root_node.get_path_to(node))
	var button_alternative_texture_track := button_track + ":alternative_texture"

	# creating animation tracks
	press_animation.add_track(Animation.TYPE_POSITION_3D)
	press_animation.track_set_path(0, button_track)

	pressed_animation.add_track(Animation.TYPE_POSITION_3D)
	pressed_animation.track_set_path(0, button_track)
	pressed_animation.add_track(Animation.TYPE_VALUE)
	pressed_animation.track_set_path(1, button_alternative_texture_track)

	release_animation.add_track(Animation.TYPE_POSITION_3D)
	release_animation.track_set_path(0, button_track)
	release_animation.add_track(Animation.TYPE_VALUE)
	release_animation.track_set_path(1, button_alternative_texture_track)

	released_animation.add_track(Animation.TYPE_POSITION_3D)
	released_animation.track_set_path(0, button_track)

	# preparing to create animation key frames
	var inverse_transform := root_node.transform.affine_inverse()
	var forward_vector := -root_node.basis.z.normalized()
	var forward_axis_index := forward_vector.abs().max_axis_index()
	var local_forward_vector := -node.basis.z.normalized()

	# calculating func_button positions
	var offset := clampf(entity.aabb.size[forward_axis_index] - lip, 0.0, INF)
	var button_release_position := inverse_transform * entity.aabb.get_center()
	var button_press_position := button_release_position + local_forward_vector * offset

	# creating animation frame times
	var frames := [0.0, offset / speed]

	# inserting keys into animations
	press_animation.length = frames[1]
	press_animation.position_track_insert_key(0, frames[0], button_release_position)
	press_animation.position_track_insert_key(0, frames[1], button_press_position)

	pressed_animation.length = 0.0
	pressed_animation.position_track_insert_key(0, frames[0], button_press_position)
	pressed_animation.track_insert_key(1, frames[0], 1)

	release_animation.length = frames[1]
	release_animation.position_track_insert_key(0, frames[0], button_press_position)
	release_animation.position_track_insert_key(0, frames[1], button_release_position)
	release_animation.track_insert_key(1, frames[0], 0)

	released_animation.length = 0.0
	released_animation.position_track_insert_key(0, frames[0], button_release_position)

	# finishing animation tracks
	press_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	press_animation.track_set_interpolation_loop_wrap(0, false)
	press_animation.track_set_imported(0, true)

	pressed_animation.track_set_imported(0, true)

	release_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	release_animation.track_set_interpolation_loop_wrap(0, false)
	release_animation.track_set_imported(0, true)
	release_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	release_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	release_animation.track_set_interpolation_loop_wrap(1, false)
	release_animation.track_set_imported(1, true)

	released_animation.track_set_imported(0, true)

	return [press_animation, pressed_animation, release_animation, released_animation]
