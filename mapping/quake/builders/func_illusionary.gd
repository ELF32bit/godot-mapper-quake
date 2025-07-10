@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# static nonsolid model
	return MapperUtilities.create_merged_brush_entity(entity, "Node3D", true, false, false)
