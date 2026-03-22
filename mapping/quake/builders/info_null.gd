extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# info_null (spotlight target)
	bind_targetname_base(entity)
	return null
