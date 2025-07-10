@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	entity.bind_string_property("targetname", "name")
	return null
