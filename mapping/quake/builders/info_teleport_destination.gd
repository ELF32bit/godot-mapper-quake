@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# teleporter destination
	var node := Marker3D.new()
	entity.bind_string_property("targetname", "name")
	return node
