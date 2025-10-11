extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# continuous shooter
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
	node.set_script(map.loader.load_script("scripts/trap_shooter"))
	node.set("projectile_collision_layer", PHYSICS_LAYERS_3D["trap_shooter-Area3D"])
	node.set("projectile_collision_mask", PHYSICS_LAYERS_3D["trap_shooter-PhysicsBody3D"])
	node.set("projectile_damage", damage)
	node.set("projectile", projectile)

	var wait_time: float = 1.0
	var wait_timer := create_safe_timer(map, node, wait_time, "WaitTimer")
	wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
	node.set("_wait_timer", node.get_path_to(wait_timer))
	wait_timer.one_shot = false
	wait_timer.autostart = true

	# binding trap_shooter properties
	bind_targetname_base(entity)

	return node
