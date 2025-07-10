extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# basic door
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	set_collision_layer_mask(node, ["worldspawn"], ["func_door-characters", "func_door-objects"])

	node.set_script(preload("../scripts/func_door+.gd"))
	node.damage = entity.get_int_property("dmg", 2)
	node.message = entity.get_string_property("message", "")
	var entity_health: int = entity.get_int_property("health", 0)
	node.max_health = maxi(entity_health, 0)

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
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		2: # machine
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		3: # stone chain
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		4: # screechy metal
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")

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

	# because first door entity is a node with its own script
	# and all other linked doors are different nodes with another script
	# convoluted and safe signal rerouting to the area script is required
	if entity.parent:
		node.connect("crushing_object", Callable(entity.parent.node, "_on_crushing_object"), CONNECT_PERSIST)
		node.connect("crushing_character", Callable(entity.parent.node, "_on_crushing_character"), CONNECT_PERSIST)
		if entity_health > 0:
			entity.parent.node.connect("opening", Callable(node, "_on_opening_signal"), CONNECT_PERSIST)
			entity.parent.node.connect("closing", Callable(node, "_on_closing_signal"), CONNECT_PERSIST)

		# rerouting generic signal received by any of the linked doors to the area through unique signal
		if entity_health > 0 or not entity.get_string_property("targetname", "").is_empty():
			node.connect("activated", Callable(entity.parent.node, "_on_generic_signal"), CONNECT_PERSIST)
		# making sure that kill signals to any of the linked doors are rerouted to the area
		node.connect("tree_exiting", Callable(entity.parent.node, "queue_free"), CONNECT_PERSIST)

		# binding common signals for linked doors, strange connections between linked doors are safe
		entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
		entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")

		return node

	var root_node := Node3D.new()
	root_node.set_script(preload("../scripts/func_door.gd"))

	var area := Area3D.new()
	area.body_entered.connect(Callable(root_node, "_on_body_entered"), CONNECT_PERSIST)
	node.connect("crushing_object", Callable(root_node, "_on_crushing_object"), CONNECT_PERSIST)
	node.connect("crushing_character", Callable(root_node, "_on_crushing_character"), CONNECT_PERSIST)
	if entity_health > 0:
		root_node.connect("opening", Callable(node, "_on_opening_signal"), CONNECT_PERSIST)
		root_node.connect("closing", Callable(node, "_on_closing_signal"), CONNECT_PERSIST)
		node.connect("activated", Callable(root_node, "_on_generic_signal"), CONNECT_PERSIST)
	area.monitorable = false

	var area_aabb := entity.aabb
	var grow_units: float = 32.0 / map.settings.unit_size
	var linked_doors: Array[MapperEntity] = [entity]
	for another_entity in map.classnames.get("func_door", []):
		# disabling door linking based on spawnflag for quake compatibility
		if entity.get_int_property("spawnflags", 0) & 4:
			break
		if another_entity.get_int_property("spawnflags", 0) & 4:
			continue

		# ignoring already linked door entities and self
		if entity == another_entity or another_entity.parent:
			continue
		var another_entity_aabb: AABB = another_entity.aabb
		if not another_entity_aabb.has_surface():
			continue
		if area_aabb.grow(grow_units).intersects(another_entity_aabb.grow(grow_units)):
			area_aabb = area_aabb.merge(another_entity_aabb)
			linked_doors.append(another_entity)
			another_entity.parent = entity
	area.position = area_aabb.get_center()
	root_node.position = area.position

	MapperUtilities.add_global_child(area, root_node, map.settings)
	root_node._area = root_node.get_path_to(area)

	var collision_shape := CollisionShape3D.new()
	collision_shape.position = area_aabb.get_center()
	MapperUtilities.add_global_child(collision_shape, area, map.settings)

	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = area_aabb.grow(grow_units).size

	# creating func_door animation player
	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(root_node, "_on_animation_finished"), CONNECT_PERSIST)
	root_node.add_child(animation_player, map.settings.readable_node_names)
	root_node._animation_player = root_node.get_path_to(animation_player)

	# creating generic wait timer
	var wait_time: float = entity.get_float_property("wait", 3.0)
	if not wait_time < 0.0:
		var wait_timer := preload("__post.gd").create_safe_timer(map, root_node, wait_time)
		wait_timer.timeout.connect(Callable(root_node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		root_node._wait_timer = root_node.get_path_to(wait_timer)
		wait_timer.one_shot = true

	MapperUtilities.add_global_child(node, root_node, map.settings)

	var open_animation := Animation.new()
	open_animation.length = 0.0
	var opened_animation := Animation.new()
	opened_animation.length = 0.0
	var close_animation := Animation.new()
	close_animation.length = 0.0
	var closed_animation := Animation.new()
	closed_animation.length = 0.0

	var suffix_digits := str(linked_doors.size()).length()
	var inverse_transform := root_node.transform.affine_inverse()
	for door_index in range(linked_doors.size()):
		var door_name: String = linked_doors[door_index].get_string_property("targetname", "")
		if door_name.is_empty():
			door_name = "door"
		# making sure door track names are unique for each door
		var door_track_name := "%s-%s" % [door_name, str(door_index).pad_zeros(suffix_digits)]
		if door_index == 0:
			node.name = door_track_name
		else:
			linked_doors[door_index].node_properties["name"] = door_track_name
		var move_sound_playing_track_name := door_track_name.path_join(move_sound_player.name) + ":playing"
		var stop_sound_playing_track_name := door_track_name.path_join(stop_sound_player.name) + ":playing"

		opened_animation.add_track(Animation.TYPE_POSITION_3D)
		opened_animation.track_set_path(door_index * 2 + 0, door_track_name)
		opened_animation.add_track(Animation.TYPE_VALUE)
		opened_animation.track_set_path(door_index * 2 + 1, move_sound_playing_track_name)

		closed_animation.add_track(Animation.TYPE_POSITION_3D)
		closed_animation.track_set_path(door_index * 2 + 0, door_track_name)
		closed_animation.add_track(Animation.TYPE_VALUE)
		closed_animation.track_set_path(door_index * 2 + 1, move_sound_playing_track_name)

		open_animation.add_track(Animation.TYPE_POSITION_3D)
		open_animation.track_set_path(door_index * 3 + 0, door_track_name)
		open_animation.add_track(Animation.TYPE_VALUE)
		open_animation.track_set_path(door_index * 3 + 1, move_sound_playing_track_name)
		open_animation.add_track(Animation.TYPE_VALUE)
		open_animation.track_set_path(door_index * 3 + 2, stop_sound_playing_track_name)

		close_animation.add_track(Animation.TYPE_POSITION_3D)
		close_animation.track_set_path(door_index * 3 + 0, door_track_name)
		close_animation.add_track(Animation.TYPE_VALUE)
		close_animation.track_set_path(door_index * 3 + 1, move_sound_playing_track_name)
		close_animation.add_track(Animation.TYPE_VALUE)
		close_animation.track_set_path(door_index * 3 + 2, stop_sound_playing_track_name)

		var lip: float = linked_doors[door_index].get_unit_property("lip", 8.0)
		var speed: float = linked_doors[door_index].get_unit_property("speed", 100.0)
		var wait: float = linked_doors[door_index].get_float_property("wait", 3.0)

		var door_close_position := inverse_transform * linked_doors[door_index].aabb.get_center()
		var quaternion := Quaternion.from_euler(linked_doors[door_index].node_properties.get("rotation", Vector3.ZERO))
		var forward := -Basis(quaternion).z.normalized() if door_index != 0 else -node.basis.z.normalized()
		var axis_index := forward.abs().max_axis_index()
		var axis: Vector3 = [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD][axis_index]
		var offset := clampf(linked_doors[door_index].aabb.size[axis_index] - lip, 0.0, INF) / forward.project(axis).length()
		var door_open_position := door_close_position + forward * offset
		var frames := [0.0, offset / speed, offset / speed + wait, 2.0 * offset / speed + wait]

		# reversing open and close position for better quake compatibility
		if linked_doors[door_index].get_int_property("spawnflags", 0) & 1:
			var tmp := door_open_position
			door_open_position = door_close_position
			door_close_position = tmp

		opened_animation.position_track_insert_key(door_index * 2 + 0, frames[0], door_open_position)
		opened_animation.track_insert_key(door_index * 2 + 1, frames[0], false)

		closed_animation.position_track_insert_key(door_index * 2 + 0, frames[0], door_close_position)
		closed_animation.track_insert_key(door_index * 2 + 1, frames[0], false)

		open_animation.length = maxf(open_animation.length, frames[1])
		open_animation.position_track_insert_key(door_index * 3 + 0, frames[0], door_close_position)
		open_animation.track_insert_key(door_index * 3 + 1, frames[0], true)
		open_animation.position_track_insert_key(door_index * 3 + 0, frames[1], door_open_position)
		open_animation.track_insert_key(door_index * 3 + 1, frames[1], false)
		open_animation.track_insert_key(door_index * 3 + 2, frames[1], true)

		close_animation.length = maxf(close_animation.length, frames[1])
		close_animation.position_track_insert_key(door_index * 3 + 0, frames[0], door_open_position)
		close_animation.track_insert_key(door_index * 3 + 1, frames[0], true)
		close_animation.position_track_insert_key(door_index * 3 + 0, frames[1], door_close_position)
		close_animation.track_insert_key(door_index * 3 + 1, frames[1], false)
		close_animation.track_insert_key(door_index * 3 + 2, frames[1], true)

		opened_animation.track_set_imported(door_index * 2 + 0, true)
		opened_animation.track_set_imported(door_index * 2 + 1, true)

		closed_animation.track_set_imported(door_index * 2 + 0, true)
		closed_animation.track_set_imported(door_index * 2 + 1, true)

		open_animation.track_set_interpolation_type(door_index * 3 + 0, Animation.INTERPOLATION_LINEAR)
		open_animation.track_set_interpolation_loop_wrap(door_index * 3 + 0, false)
		open_animation.track_set_imported(door_index * 3 + 0, true)
		open_animation.value_track_set_update_mode(door_index * 3 + 1, Animation.UPDATE_DISCRETE)
		open_animation.track_set_interpolation_type(door_index * 3 + 1, Animation.INTERPOLATION_NEAREST)
		open_animation.track_set_interpolation_loop_wrap(door_index * 3 + 1, false)
		open_animation.track_set_imported(door_index * 3 + 1, true)
		open_animation.value_track_set_update_mode(door_index * 3 + 2, Animation.UPDATE_DISCRETE)
		open_animation.track_set_interpolation_type(door_index * 3 + 2, Animation.INTERPOLATION_NEAREST)
		open_animation.track_set_interpolation_loop_wrap(door_index * 3 + 2, false)
		open_animation.track_set_imported(door_index * 3 + 2, true)

		close_animation.track_set_interpolation_type(door_index * 3 + 0, Animation.INTERPOLATION_LINEAR)
		close_animation.track_set_interpolation_loop_wrap(door_index * 3 + 0, false)
		close_animation.track_set_imported(door_index * 3 + 0, true)
		close_animation.value_track_set_update_mode(door_index * 3 + 1, Animation.UPDATE_DISCRETE)
		close_animation.track_set_interpolation_type(door_index * 3 + 1, Animation.INTERPOLATION_NEAREST)
		close_animation.track_set_interpolation_loop_wrap(door_index * 3 + 1, false)
		close_animation.track_set_imported(door_index * 3 + 1, true)
		close_animation.value_track_set_update_mode(door_index * 3 + 2, Animation.UPDATE_DISCRETE)
		close_animation.track_set_interpolation_type(door_index * 3 + 2, Animation.INTERPOLATION_NEAREST)
		close_animation.track_set_interpolation_loop_wrap(door_index * 3 + 2, false)
		close_animation.track_set_imported(door_index * 3 + 2, true)

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("open", open_animation)
	animation_library.add_animation("opened", opened_animation)
	animation_library.add_animation("close", close_animation)
	animation_library.add_animation("closed", closed_animation)
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "closed"

	# creating reset animation for the animation library
	MapperUtilities.create_reset_animation(animation_player, animation_library)

	for linked_door in linked_doors:
		# disabling door area if any of the linked doors declare health
		if linked_door.get_int_property("health", 0) > 0:
			area.monitoring = false
		# disabling door area if any of the linked doors declare targetname
		if not linked_door.get_string_property("targetname", "").is_empty():
			area.monitoring = false

	# also renaming root node if there is only one door
	if linked_doors.size() == 1:
		entity.bind_string_property("targetname", "name")

	# for door entity opening signal functions as generic signal
	entity.bind_signal_property("target", "targetname", "opening", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "opening", "queue_free")

	area.collision_layer = 0; area.collision_mask = 0;
	area.set_collision_layer_value(PHYSICS_LAYERS_3D["func_door-areas"], true)
	area.set_collision_mask_value(PHYSICS_LAYERS_3D["func_door-characters"], true)

	return root_node


static func create_animations(entity: MapperEntity, nodes: Array[Node]) -> Array[Animation]:
	return []
