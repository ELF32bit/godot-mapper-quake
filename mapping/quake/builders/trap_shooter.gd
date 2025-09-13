extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# continuous shooter
	var trap_shooter: PackedScene = null
	match entity.get_int_property("spawnflags", 0):
		0: # spike 9 HP
			trap_shooter = map.loader.load_mdl("mdls/projectiles/s_spike.mdl")
		1: # superspike 18 HP
			trap_shooter = map.loader.load_mdl("mdls/projectiles/s_spike.mdl")
		2: # laser 15 HP
			trap_shooter = map.loader.load_mdl("mdls/projectiles/laser.mdl")
	if not trap_shooter:
		return null

	var trap_shooter_instance := trap_shooter.instantiate()

	# binding trap_shooter properties
	bind_targetname_base(entity)

	return trap_shooter_instance
