extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# func_detail variant that doesn't split world faces
	return preload("func_wall.gd").build(map, entity)
