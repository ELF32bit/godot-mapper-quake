extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# boss gate
	return preload("func_wall.gd").build(map, entity)
