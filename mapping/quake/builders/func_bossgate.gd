@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# same as func_episodegate, but with collision
	return preload("func_wall.gd").build(map, entity)
