@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# small fireball
	var fireball := map.loader.load_mdl("mdls/misc/lavaball.mdl")
	if not fireball:
		return null

	var fireball_instance := fireball.instantiate()
	fireball_instance.set_script(preload("../scripts/misc_fireball.gd"))

	entity.bind_unit_property("speed", "speed")

	return fireball_instance
