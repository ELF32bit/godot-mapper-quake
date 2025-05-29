@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := Marker3D.new()

	entity.bind_string_property("targetname", "name")

	return node
