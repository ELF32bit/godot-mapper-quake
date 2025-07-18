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
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
		2: # machine
			move_sound_player.stream = preload("../sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("../sounds/doors/stndr2.wav")
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

	# binding func_door_secret properties
	bind_target_base(entity)
	bind_targetname_base(entity)
	node.set("damage", entity.get_int_property("dmg", 2))
	entity.bind_string_property("message", "message")
	node.set("max_health", maxi(entity.get_int_property("health", 0), 0))

	return node
