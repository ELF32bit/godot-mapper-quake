@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# air bubbles
	return Node3D.new()
