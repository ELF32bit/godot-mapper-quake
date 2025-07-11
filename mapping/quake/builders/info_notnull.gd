@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# wildcard entity
	var node := Node3D.new()
	node.set_script(preload("../scripts/info_notnull.gd"))

	preload("__post.gd").bind_target_base(entity)
	preload("__post.gd").bind_targetname_base(entity)
	entity.bind_string_property("use", "use")
	entity.bind_string_property("think", "think")
	entity.bind_int_property("nextthink", "next_think")
	entity.bind_string_property("noise", "noise")
	entity.bind_string_property("touch", "touch")

	return node
