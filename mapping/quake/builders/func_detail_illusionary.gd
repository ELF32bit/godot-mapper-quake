extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# func_detail variant with no collision (players / monsters / gunfire)
	return preload("func_illusionary.gd").build(map, entity)
