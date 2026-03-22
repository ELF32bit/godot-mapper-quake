extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# static nonsolid model
	var node := MapperUtilities.create_merged_brush_entity(entity, "Node3D", true, false, false)
	if not node:
		return null

	# func_illusionary does not cast shadow
	for mesh_instance in node.find_children("*", "MeshInstance3D", false, false):
		mesh_instance.cast_shadow = false

	return node
