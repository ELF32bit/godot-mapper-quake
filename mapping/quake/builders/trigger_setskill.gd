extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: set skill
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node,
		["trigger_setskill-Area3D"],
		["trigger_setskill-PhysicsBody3D"])

	# setting trigger_setskill script and connecting signals
	node.set_script(map.loader.load_script("scripts/trigger_setskill"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# binding trigger_setskill properties
	match entity.get_int_property("message", 1):
		0: # easy
			node.set("skill", 0)
		1: # medium
			node.set("skill", 1)
		2: # hard
			node.set("skill", 2)
		3: # nightmare
			node.set("skill", 3)

	return node
