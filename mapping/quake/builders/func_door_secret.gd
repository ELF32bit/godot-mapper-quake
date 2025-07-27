extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# secret door
	var node := MapperUtilities.create_merged_brush_entity(entity, "AnimatableBody3D")
	if not node:
		return null
	set_collision_layer_mask(node, ["worldspawn"], ["func_door-characters", "func_door-objects"])

	# setting func_door_secret script
	node.set_script(preload("../scripts/func_door-health.gd"))

	# creating func_door_secret sound players
	var move_sound_player := AudioStreamPlayer3D.new()
	node.add_child(move_sound_player, map.settings.readable_node_names)

	var stop_sound_player := AudioStreamPlayer3D.new()
	node.add_child(stop_sound_player, map.settings.readable_node_names)

	# loading func_door_secret default sounds
	match entity.get_int_property("sounds", 0):
		0: # silent
			move_sound_player.stream = null
			stop_sound_player.stream = null
		1: # stone
			move_sound_player.stream = preload("../sounds/doors/doormv1.wav")
			stop_sound_player.stream = preload("../sounds/doors/drclos4.wav")
		2: # machine
			move_sound_player.stream = preload("../sounds/doors/basesec1.wav")
			stop_sound_player.stream = preload("../sounds/doors/basesec2.wav")
		3: # stone chain
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")

	# using custom sounds if they are loading
	var noise1: AudioStream = entity.get_sound_property("noise1", null)
	var noise2: AudioStream = entity.get_sound_property("noise2", null)
	if noise1:
		move_sound_player.stream = noise1
	if noise2:
		stop_sound_player.stream = noise2

	# removing func_door_secret from voxelGI
	if not map.settings.prefer_static_lighting:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.gi_mode = MeshInstance3D.GI_MODE_DISABLED

	# creating func_door animation player
	var animation_player := AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(node, "_on_animation_finished"), CONNECT_PERSIST)
	node.add_child(animation_player, map.settings.readable_node_names)
	node.set("_animation_player", node.get_path_to(animation_player))

	# creating wait timer
	var wait_time: float = entity.get_float_property("wait", 2.0)
	if not wait_time < 0.0:
		var wait_timer := preload("__post.gd").create_safe_timer(map, node, wait_time)
		wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
		node.set("_wait_timer", node.get_path_to(wait_timer))
		wait_timer.one_shot = true

	# creating animations for func_door_secret states
	var animations := create_animations(entity,
		[node, move_sound_player, stop_sound_player])

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("open", animations[0])
	animation_library.add_animation("opened", animations[1])
	animation_library.add_animation("close", animations[2])
	animation_library.add_animation("closed", animations[3])
	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "closed"

	# creating reset animation for the animation library
	MapperUtilities.create_reset_animation(animation_player, animation_library)

	# binding func_door_secret properties
	bind_target_base(entity)
	bind_targetname_base(entity)
	node.set("damage", entity.get_int_property("dmg", 2))
	entity.bind_string_property("message", "message")

	return node


static func create_animations(entity: MapperEntity, nodes: Array[Node]) -> Array[Animation]:
	var node: AnimatableBody3D = nodes[0]
	var move_sound_player: AudioStreamPlayer3D = nodes[1]
	var stop_sound_player: AudioStreamPlayer3D = nodes[1]

	# animation parameters
	var t_width: float = entity.get_unit_property("t_width", 8.0)
	var t_length: float = entity.get_unit_property("t_length", 8.0)
	var wait: float = entity.get_float_property("wait", 2.0)
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	#1 : "Open once" : 0
	#2 : "Move left first" : 0
	#4 : "Move down first" : 0
	#8 : "Not shootable" : 0
	#16 : "Always shootable" : 0

	# creating empty animations
	var open_animation := Animation.new()
	var opened_animation := Animation.new()
	var close_animation := Animation.new()
	var closed_animation := Animation.new()

	# creating animation track names
	var door_track := "." + str(node.name)
	var move_sound_playing_track := node.name.path_join(move_sound_player.name) + ":playing"
	var stop_sound_playing_track := node.name.path_join(stop_sound_player.name) + ":playing"

	# creating animation tracks
	open_animation.add_track(Animation.TYPE_POSITION_3D)
	open_animation.track_set_path(0, door_track)
	open_animation.add_track(Animation.TYPE_VALUE)
	open_animation.track_set_path(1, move_sound_playing_track)
	open_animation.add_track(Animation.TYPE_VALUE)
	open_animation.track_set_path(2, stop_sound_playing_track)

	opened_animation.add_track(Animation.TYPE_POSITION_3D)
	opened_animation.track_set_path(0, door_track)
	opened_animation.add_track(Animation.TYPE_VALUE)
	opened_animation.track_set_path(1, move_sound_playing_track)

	close_animation.add_track(Animation.TYPE_POSITION_3D)
	close_animation.track_set_path(0, door_track)
	close_animation.add_track(Animation.TYPE_VALUE)
	close_animation.track_set_path(1, move_sound_playing_track)
	close_animation.add_track(Animation.TYPE_VALUE)
	close_animation.track_set_path(2, stop_sound_playing_track)

	closed_animation.add_track(Animation.TYPE_POSITION_3D)
	closed_animation.track_set_path(0, door_track)
	closed_animation.add_track(Animation.TYPE_VALUE)
	closed_animation.track_set_path(1, move_sound_playing_track)

	# preparing to create animation key frames
	# calculating func_door_secret positions
	# creating animation frame times
	# inserting keys into animations

	open_animation.length = 0.0
	opened_animation.length = 0.0
	close_animation.length = 0.0
	closed_animation.length = 0.0

	# finishing animation tracks
	open_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	open_animation.track_set_interpolation_loop_wrap(0, false)
	open_animation.track_set_imported(0, true)
	open_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	open_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	open_animation.track_set_interpolation_loop_wrap(1, false)
	open_animation.track_set_imported(1, true)
	open_animation.value_track_set_update_mode(2, Animation.UPDATE_DISCRETE)
	open_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_NEAREST)
	open_animation.track_set_interpolation_loop_wrap(2, false)
	open_animation.track_set_imported(2, true)

	opened_animation.track_set_imported(0, true)
	opened_animation.track_set_imported(1, true)

	close_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	close_animation.track_set_interpolation_loop_wrap(0, false)
	close_animation.track_set_imported(0, true)
	close_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	close_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	close_animation.track_set_interpolation_loop_wrap(1, false)
	close_animation.track_set_imported(1, true)
	close_animation.value_track_set_update_mode(2, Animation.UPDATE_DISCRETE)
	close_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_NEAREST)
	close_animation.track_set_interpolation_loop_wrap(2, false)
	close_animation.track_set_imported(2, true)

	closed_animation.track_set_imported(0, true)
	closed_animation.track_set_imported(1, true)

	return [open_animation, opened_animation, close_animation, closed_animation]
