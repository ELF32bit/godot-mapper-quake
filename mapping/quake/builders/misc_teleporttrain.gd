extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# flying teleporter destination
	var teleport_train := map.loader.load_mdl("mdls/misc/teleport")
	if not teleport_train:
		return null
	var teleport_train_instance := teleport_train.instantiate()

	# hacking entity to output func_train
	entity.mesh = ArrayMesh.new()
	entity.aabb = AABB(Vector3.ZERO, Vector3.ONE)
	var node := preload("func_train.gd").build(map, entity)
	node.add_child(teleport_train_instance, map.settings.readable_node_names)
	node.get_child(0).free()
	node.move_child(teleport_train_instance, 0)

	return node
