extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: hurt
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_hurt-areas"], ["trigger_hurt-objects"])

	# setting trigger_hurt script and connecting signals
	node.set_script(preload("../scripts/trigger_hurt.gd"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# binding trigger_hurt properties
	bind_targetname_base(entity)
	entity.set("damage", entity.get_int_property("damage", 5))

	return node
