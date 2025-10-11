extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# triggered shooter
	var spawnflags: int = entity.get_int_property("spawnflags", 0)
	var projectile := map.loader.load_mdl("mdls/projectiles/s_spike")
	var damage: int = 9

	if spawnflags & 1: # superspike 18 HP
		projectile = map.loader.load_mdl("mdls/projectiles/s_spike")
		damage = 18
	elif spawnflags & 2: # laser 15 HP
		projectile = map.loader.load_mdl("mdls/projectiles/laser")
		damage = 15
	if not projectile:
		return null

	var node := Node3D.new()
	node.set_script(map.loader.load_script("scripts/trap_spikeshooter"))
	node.set("projectile_collision_layer", PHYSICS_LAYERS_3D["trap_spikeshooter-Area3D"])
	node.set("projectile_collision_mask", PHYSICS_LAYERS_3D["trap_spikeshooter-PhysicsBody3D"])
	node.set("projectile_damage", damage)
	node.set("projectile", projectile)

	# binding trap_spikeshooter properties
	bind_targetname_base(entity)

	return node
