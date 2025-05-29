extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node: Area3D = MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	node.set_script(preload("../scripts/trigger_push.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	var push_sound_player := AudioStreamPlayer3D.new()
	node.add_child(push_sound_player, map.settings.readable_node_names)
	push_sound_player.autoplay = true

	push_sound_player.stream = preload("../sounds/ambience/windfly.wav")
	var noise_sound: AudioStream = entity.get_sound_property("noise", null)
	push_sound_player.stream = noise_sound if noise_sound else push_sound_player.stream

	entity.bind_string_property("targetname", "name")
	node.set("push_speed", entity.get_float_property("speed", 1000.0) / 3.0)
	if entity.get_int_property("spawnflags", 0) & 1 != 0:
		node.set("push_once", true)

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["trigger_push-areas"], true)
	node.set_collision_mask_value(PHYSICS_LAYERS_3D["trigger_push-bodies"], true)

	return node
