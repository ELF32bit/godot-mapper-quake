@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := preload("func_wall.gd").build(map, entity)
	if not node:
		return null
	# same as func_bossgate, but without collision
	for child in node.get_children():
		if child is CollisionShape3D:
			child.disabled = true

	return node
