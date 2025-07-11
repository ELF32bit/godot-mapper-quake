@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# info_null (spotlight target)
	entity.bind_string_property("targetname", "name")
	return null
