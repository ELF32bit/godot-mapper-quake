@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# flying teleporter destination
	var teleport_train := map.loader.load_mdl("mdls/misc/teleport.mdl")
	if not teleport_train:
		return null

	var teleport_train_instance := teleport_train.instantiate()
	return teleport_train_instance
