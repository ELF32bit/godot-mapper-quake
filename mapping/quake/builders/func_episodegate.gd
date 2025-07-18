extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# episode gate
	var node := preload("func_wall.gd").build(map, entity)
	if not node:
		return null

	# same as func_bossgate, but without collision
	for collision_shape in node.find_children("*", "CollisionShape3D", false, false):
		collision_shape.disabled = true

	return node
