extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: set skill
	var node := MapperUtilities.create_merged_brush_entity(entity, "Area3D", false, true, false)
	if not node:
		return null
	set_collision_layer_mask(node, ["trigger_setskill-areas"], ["trigger_setskill-objects"])

	var message: int = entity.get_int_property("message", 1)
	match message:
		0: # easy
			pass
		1: # medium
			pass
		2: # hard
			pass
		3: # nightmare
			pass

	return node
