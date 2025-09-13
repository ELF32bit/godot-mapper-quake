extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# triggered shooter
	var trap_spikeshooter: PackedScene = null
	match entity.get_int_property("spawnflags", 0):
		0: # spike 9 HP
			trap_spikeshooter = map.loader.load_mdl("mdls/projectiles/s_spike.mdl")
		1: # superspike 18 HP
			trap_spikeshooter = map.loader.load_mdl("mdls/projectiles/s_spike.mdl")
		2: # laser 15 HP
			trap_spikeshooter = map.loader.load_mdl("mdls/projectiles/laser.mdl")
	if not trap_spikeshooter:
		return null

	var trap_spikeshooter_instance := trap_spikeshooter.instantiate()

	# binding trap_spikeshooter properties
	bind_targetname_base(entity)

	return trap_spikeshooter_instance
