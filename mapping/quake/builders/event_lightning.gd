@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# chthon's lightning
	var node := Node3D.new()
	entity.bind_string_property("targetname", "name")
	return node
