extends "__classes.gd"


static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# basic door
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		["func_door-CharacterBody3D", "func_door-Object"])

	# setting func_door script
	node.set_script(preload("../scripts/func_door-health.gd"))

	# creating func_door sound players
	var move_sound_player := AudioStreamPlayer3D.new()
	node.add_child(move_sound_player, map.settings.readable_node_names)

	var stop_sound_player := AudioStreamPlayer3D.new()
	node.add_child(stop_sound_player, map.settings.readable_node_names)

	# loading func_door default sounds
	match entity.get_int_property("sounds", 0):
		0: # silent
			move_sound_player.stream = null
			stop_sound_player.stream = null
		1: # stone
			move_sound_player.stream = preload("../sounds/doors/doormv1.wav")
			stop_sound_player.stream = preload("../sounds/doors/drclos4.wav")
		2: # machine
			move_sound_player.stream = preload("../sounds/doors/hydro1.wav")
			stop_sound_player.stream = preload("../sounds/doors/hydro2.wav")
		3: # stone chain
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		4: # screechy metal
			move_sound_player.stream = preload("../sounds/doors/ddoor1.wav")
			stop_sound_player.stream = preload("../sounds/doors/ddoor2.wav")

	# currently unused func_door sounds based on worldtype
	match map.settings.options["_world_type"]:
		0: # medieval (wizard)
			var _stream1 := preload("../sounds/doors/medtry.wav")
			var _stream2 := preload("../sounds/doors/meduse.wav")
		1: # metal (runic)
			var _stream1 := preload("../sounds/doors/runetry.wav")
			var _stream2 := preload("../sounds/doors/runeuse.wav")
		2: # base (tech)
			var _stream1 := preload("../sounds/doors/basetry.wav")
			var _stream2 := preload("../sounds/doors/baseuse.wav")

	# using custom sounds if they are loading
	var noise1: AudioStream = entity.get_sound_property("noise1", null)
	var noise2: AudioStream = entity.get_sound_property("noise2", null)
	if noise1:
		move_sound_player.stream = noise1
	if noise2:
		stop_sound_player.stream = noise2

	# removing func_door from voxelGI
	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	# binding func_door properties
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_string_property("message", "message")
	node.set("damage", entity.get_int_property("dmg", 2))
	node.set("max_health", maxi(entity.get_int_property("health", 0), 0))

	return node


static func post_build(map: MapperMap, linking_data: Array) -> void:
	if not linking_data.size() == 3:
		return
	var linked_entities: Array[MapperEntity] = linking_data[0]
	var linked_aabb: AABB = linking_data[1]
	var link_units: float = linking_data[2]
	var linked_aabb_center := linked_aabb.get_center()
	var entity := linked_entities[0]

	# creating func_door root node
	var root_node := Node3D.new()
	root_node.position = linked_aabb_center
	MapperUtilities.add_global_child(root_node, entity.node.get_parent(), map.settings)
	root_node.set_script(preload("../scripts/func_door.gd"))

	# creating func_door activation area
	var area := Area3D.new()
	root_node.add_child(area, map.settings.readable_node_names)
	set_collision_layer_mask(area,
		["func_door-Area3D"],
		["func_door-CharacterBody3D"])
	area.body_entered.connect(Callable(root_node, "_on_body_entered"), CONNECT_PERSIST)
	root_node.set("_area", root_node.get_path_to(area))
	area.monitorable = false

	for linked_entity in linked_entities:
		# disabling area if any of the linked doors have health
		if linked_entity.get_int_property("health", 0) > 0:
			area.monitoring = false
		# disabling area if any of the linked doors declare targetname
		if not linked_entity.get_string_property("targetname", "").is_empty():
			area.monitoring = false

	# creating func_door activation area collision shape
	var collision_shape := CollisionShape3D.new()
	collision_shape.position = linked_aabb_center
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	var grow_by: float = link_units / map.settings.unit_size
	collision_shape.shape.size = linked_aabb.grow(grow_by).size

	# creating func_door animation player
	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(root_node, "_on_animation_finished"), CONNECT_PERSIST)
	root_node.add_child(animation_player, map.settings.readable_node_names)
	root_node.set("_animation_player", root_node.get_path_to(animation_player))

	# creating wait timer
	var wait_time: float = entity.get_float_property("wait", 3.0)
	if not wait_time < 0.0:
		var wait_timer := create_safe_timer(map, root_node, wait_time)
		wait_timer.timeout.connect(Callable(root_node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		root_node.set("_wait_timer", root_node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	# parenting linked doors to the root node and setting its name
	for index in range(linked_entities.size() - 1, -1, -1):
		var linked_entity := linked_entities[index]
		var node := linked_entity.node
		node.get_parent().remove_child(node)
		MapperUtilities.add_global_child(node, root_node, map.settings)
		root_node.move_child(node, 0)
	if linked_entities.size() == 1:
		var root_name: String = linked_entities[0].get_string_property("targetname", "")
		if not root_name.validate_node_name().strip_edges().is_empty():
			root_node.name = root_name

	# connecting signals from linked doors
	for linked_entity in linked_entities:
		var node := linked_entity.node
		var health: int = entity.get_int_property("health", 0)
		node.connect("crushing_object", Callable(root_node, "_on_crushing_object"), CONNECT_PERSIST)
		node.connect("crushing_character", Callable(root_node, "_on_crushing_character"), CONNECT_PERSIST)
		if health > 0:
			root_node.connect("opening", Callable(node, "_on_opening_signal"), CONNECT_PERSIST)
			root_node.connect("closing", Callable(node, "_on_closing_signal"), CONNECT_PERSIST)
		# rerouting generic signal received by any of the linked doors to the root node through unique signal
		if health > 0 or not linked_entity.get_string_property("targetname", "").is_empty():
			node.connect("activated", Callable(root_node, "_on_generic_signal"), CONNECT_PERSIST)
		# making sure that kill signals to any of the linked doors are rerouted to the root node
		node.connect("tree_exiting", Callable(root_node, "queue_free"), CONNECT_PERSIST)

	# creating animations for func_door states
	var animations := create_animations(root_node, linking_data)

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("open", animations[0])
	animation_library.add_animation("opened", animations[1])
	animation_library.add_animation("close", animations[2])
	animation_library.add_animation("closed", animations[3])
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "closed"

	# creating reset animation for the animation library
	MapperUtilities.create_reset_animation(animation_player, animation_library)

	# opening signal functions as generic signal for func_door
	entity.bind_signal_property("target", "targetname", "opening", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "opening", "queue_free")
	entity.node = root_node # rerouting binding to the root node


static func create_animations(root_node: Node3D, linking_data: Array) -> Array[Animation]:
	var linked_entities: Array[MapperEntity] = linking_data[0]
	var inverse_transform := root_node.transform.affine_inverse()

	# creating empty animations
	var open_animation := Animation.new()
	var opened_animation := Animation.new()
	var close_animation := Animation.new()
	var closed_animation := Animation.new()
	open_animation.length = 0.0
	opened_animation.length = 0.0
	close_animation.length = 0.0
	closed_animation.length = 0.0

	for index in range(linked_entities.size()):
		var entity := linked_entities[index]
		var entity_center := entity.aabb.get_center()
		var node: Node3D = entity.node

		# animation parameters per door
		var lip: float = entity.get_unit_property("lip", 8.0)
		var speed: float = entity.get_unit_property("speed", 100.0)

		# finding func_door sound players children
		var sound_players = node.find_children("*", "AudioStreamPlayer3D", false, false)
		var move_sound_player: AudioStreamPlayer3D = sound_players[0]
		var stop_sound_player: AudioStreamPlayer3D = sound_players[1]

		# creating animation track names
		var door_track := str(node.name)
		var move_sound_playing_track := node.name.path_join(move_sound_player.name) + ":playing"
		var stop_sound_playing_track := node.name.path_join(stop_sound_player.name) + ":playing"

		open_animation.add_track(Animation.TYPE_POSITION_3D)
		open_animation.track_set_path(index * 3 + 0, door_track)
		open_animation.add_track(Animation.TYPE_VALUE)
		open_animation.track_set_path(index * 3 + 1, move_sound_playing_track)
		open_animation.add_track(Animation.TYPE_VALUE)
		open_animation.track_set_path(index * 3 + 2, stop_sound_playing_track)

		opened_animation.add_track(Animation.TYPE_POSITION_3D)
		opened_animation.track_set_path(index * 2 + 0, door_track)
		opened_animation.add_track(Animation.TYPE_VALUE)
		opened_animation.track_set_path(index * 2 + 1, move_sound_playing_track)

		close_animation.add_track(Animation.TYPE_POSITION_3D)
		close_animation.track_set_path(index * 3 + 0, door_track)
		close_animation.add_track(Animation.TYPE_VALUE)
		close_animation.track_set_path(index * 3 + 1, move_sound_playing_track)
		close_animation.add_track(Animation.TYPE_VALUE)
		close_animation.track_set_path(index * 3 + 2, stop_sound_playing_track)

		closed_animation.add_track(Animation.TYPE_POSITION_3D)
		closed_animation.track_set_path(index * 2 + 0, door_track)
		closed_animation.add_track(Animation.TYPE_VALUE)
		closed_animation.track_set_path(index * 2 + 1, move_sound_playing_track)

		# preparing to create animation key frames
		var forward_axis := Vector3.ZERO
		var local_forwad_vector = -node.basis.z.normalized()
		var forward_vector := (root_node.basis * local_forwad_vector).normalized()
		var forward_axis_index := forward_vector.abs().max_axis_index()
		forward_axis[forward_axis_index] = signf(forward_vector[forward_axis_index])
		var offset := clampf(entity.aabb.size[forward_axis_index] - lip, 0.0, INF)
		offset /= forward_vector.project(forward_axis).length()

		# calculating func_door positions
		var door_close_position := inverse_transform * entity_center
		var door_open_position := inverse_transform * (entity_center + forward_axis * offset)

		# creating animation frame times
		var frames := [0.0, offset / speed]

		if entity.get_int_property("spawnflags", 0) & 1: # starts open
			var tmp := door_open_position
			door_open_position = door_close_position
			door_close_position = tmp

		# inserting keys into animations
		open_animation.length = maxf(open_animation.length, frames[1])
		open_animation.position_track_insert_key(index * 3 + 0, frames[0], door_close_position)
		open_animation.track_insert_key(index * 3 + 1, frames[0], true)
		open_animation.position_track_insert_key(index * 3 + 0, frames[1], door_open_position)
		open_animation.track_insert_key(index * 3 + 1, frames[1], false)
		open_animation.track_insert_key(index * 3 + 2, frames[1], true)

		opened_animation.position_track_insert_key(index * 2 + 0, frames[0], door_open_position)
		opened_animation.track_insert_key(index * 2 + 1, frames[0], false)

		close_animation.length = maxf(close_animation.length, frames[1])
		close_animation.position_track_insert_key(index * 3 + 0, frames[0], door_open_position)
		close_animation.track_insert_key(index * 3 + 1, frames[0], true)
		close_animation.position_track_insert_key(index * 3 + 0, frames[1], door_close_position)
		close_animation.track_insert_key(index * 3 + 1, frames[1], false)
		close_animation.track_insert_key(index * 3 + 2, frames[1], true)

		closed_animation.position_track_insert_key(index * 2 + 0, frames[0], door_close_position)
		closed_animation.track_insert_key(index * 2 + 1, frames[0], false)

		# finishing animation tracks
		open_animation.track_set_interpolation_type(index * 3 + 0, Animation.INTERPOLATION_LINEAR)
		open_animation.track_set_interpolation_loop_wrap(index * 3 + 0, false)
		open_animation.track_set_imported(index * 3 + 0, true)
		open_animation.value_track_set_update_mode(index * 3 + 1, Animation.UPDATE_DISCRETE)
		open_animation.track_set_interpolation_type(index * 3 + 1, Animation.INTERPOLATION_NEAREST)
		open_animation.track_set_interpolation_loop_wrap(index * 3 + 1, false)
		open_animation.track_set_imported(index * 3 + 1, true)
		open_animation.value_track_set_update_mode(index * 3 + 2, Animation.UPDATE_DISCRETE)
		open_animation.track_set_interpolation_type(index * 3 + 2, Animation.INTERPOLATION_NEAREST)
		open_animation.track_set_interpolation_loop_wrap(index * 3 + 2, false)
		open_animation.track_set_imported(index * 3 + 2, true)

		opened_animation.track_set_imported(index * 2 + 0, true)
		opened_animation.track_set_imported(index * 2 + 1, true)

		close_animation.track_set_interpolation_type(index * 3 + 0, Animation.INTERPOLATION_LINEAR)
		close_animation.track_set_interpolation_loop_wrap(index * 3 + 0, false)
		close_animation.track_set_imported(index * 3 + 0, true)
		close_animation.value_track_set_update_mode(index * 3 + 1, Animation.UPDATE_DISCRETE)
		close_animation.track_set_interpolation_type(index * 3 + 1, Animation.INTERPOLATION_NEAREST)
		close_animation.track_set_interpolation_loop_wrap(index * 3 + 1, false)
		close_animation.track_set_imported(index * 3 + 1, true)
		close_animation.value_track_set_update_mode(index * 3 + 2, Animation.UPDATE_DISCRETE)
		close_animation.track_set_interpolation_type(index * 3 + 2, Animation.INTERPOLATION_NEAREST)
		close_animation.track_set_interpolation_loop_wrap(index * 3 + 2, false)
		close_animation.track_set_imported(index * 3 + 2, true)

		closed_animation.track_set_imported(index * 2 + 0, true)
		closed_animation.track_set_imported(index * 2 + 1, true)

	return [open_animation, opened_animation, close_animation, closed_animation]
