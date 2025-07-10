extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: push
	var node: Area3D = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_push-areas"], ["trigger_push-objects"])

	node.set_script(preload("../scripts/trigger_push.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_push sound player
	var push_sound_player := AudioStreamPlayer3D.new()
	node.add_child(push_sound_player, map.settings.readable_node_names)
	push_sound_player.autoplay = true

	# setting default quake sound or loading custom sound
	push_sound_player.stream = preload("../sounds/ambience/windfly.wav")
	var noise: AudioStream = entity.get_sound_property("noise", null)
	if noise:
		push_sound_player.stream = noise

	# targetname base
	entity.bind_string_property("targetname", "name")

	node.set("push_speed", entity.get_float_property("speed", 1000.0) / 3.0)
	if entity.get_int_property("spawnflags", 0) & 1: # push once
		node.set("push_once", true)

	return node
