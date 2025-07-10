@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# wildcard entity
	var node := Node3D.new()
	node.set_script(preload("../scripts/info_notnull.gd"))

	# target, targetname base
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_string_property("targetname", "name")

	entity.bind_string_property("use", "use")
	entity.bind_string_property("think", "think")
	entity.bind_int_property("nextthink", "next_think")
	entity.bind_string_property("noise", "noise")
	entity.bind_string_property("touch", "touch")

	return node
