@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# waypoint for platforms and monsters
	var node := Marker3D.new()
	node.set_script(preload("../scripts/path_corner.gd"))

	preload("__post.gd").bind_targetname_base(entity)
	entity.bind_node_path_array_property("target", "targetname", "_targets")
	entity.bind_float_property("wait", "wait_time")

	return node
