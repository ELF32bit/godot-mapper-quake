extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# chthon's lightning
	var node := CPUParticles3D.new()
	bind_targetname_base(entity)
	return node
