extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# intermission camera
	var node := Camera3D.new()
	node.add_to_group("info_intermission", true)
	return node
