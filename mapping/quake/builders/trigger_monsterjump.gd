extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: monster jump
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node,
		["trigger_monsterjump-Area3D"],
		["trigger_monsterjump-PhysicsBody3D"])

	# setting trigger_monsterjump script and connecting signals
	node.set_script(preload("../scripts/trigger_monsterjump.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# binding trigger_monsterjump properties
	bind_targetname_base(entity)
	node.set("speed", entity.get_unit_property("speed", 200.0))
	node.set("height", entity.get_unit_property("height", 200.0))

	return node
