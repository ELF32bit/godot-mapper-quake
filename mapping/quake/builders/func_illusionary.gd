@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# static nonsolid model
	var node := MapperUtilities.create_merged_brush_entity(entity, "Node3D", true, false, false)
	if not node:
		return null

	# func_illusionary does not cast shadow
	for child in node.get_children():
		if child is MeshInstance3D:
			child.cast_shadow = false

	return node
