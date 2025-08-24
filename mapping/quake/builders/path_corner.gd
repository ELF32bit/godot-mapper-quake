extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# waypoint for platforms and monsters
	var node := Marker3D.new()
	node.set_script(map.loader.load_script("scripts/path_corner"))

	# binding path_corner properties
	bind_targetname_base(entity)
	entity.bind_node_path_array_property("target", "targetname", "_targets")
	entity.bind_float_property("wait", "wait_time")

	return node
