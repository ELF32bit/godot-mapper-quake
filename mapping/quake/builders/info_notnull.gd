@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# wildcard entity
	entity.bind_string_property("use", "_use")
	entity.bind_string_property("think", "_think")
	entity.bind_int_property("nextthink", "_next_think")
	entity.bind_string_property("noise", "_noise")
	entity.bind_string_property("touch", "_touch")
	return Node3D.new()
