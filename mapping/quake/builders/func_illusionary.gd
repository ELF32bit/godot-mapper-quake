@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := MapperUtilities.create_merged_brush_entity(entity, "Node3D", true, false, false)
	if not node:
		return null

	return node
