extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: push
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node,
		["trigger_push-Area3D"],
		["trigger_push-PhysicsBody3D"])

	# setting trigger_push script and connecting signals
	node.set_script(map.loader.load_script("scripts/trigger_push"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating trigger_push sound player
	var push_sound_player := AudioStreamPlayer3D.new()
	node.add_child(push_sound_player, map.settings.readable_node_names)
	push_sound_player.name = "PushSoundPlayer3D"
	push_sound_player.autoplay = true

	# loading trigger_push default sounds
	push_sound_player.stream = map.loader.load_sound("sounds/ambience/windfly")
	var noise: AudioStream = entity.get_sound_property("noise", null)
	if noise:
		push_sound_player.stream = noise

	# binding trigger_push properties
	bind_targetname_base(entity)
	node.set("push_speed", entity.get_unit_property("speed", 1000.0))
	if entity.get_int_property("spawnflags", 0) & 1: # push once
		node.set("push_once", true)

	return node
