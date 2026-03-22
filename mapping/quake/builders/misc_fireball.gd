extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# small fireball
	var projectile := map.loader.load_mdl("mdls/misc/lavaball")
	if not projectile:
		return null

	var node := Node3D.new()
	node.set_script(map.loader.load_script("scripts/misc_fireball"))
	node.set("projectile_collision_layer", PHYSICS_LAYERS_3D["misc_fireball-Area3D"])
	node.set("projectile_collision_mask", PHYSICS_LAYERS_3D["misc_fireball-PhysicsBody3D"])
	node.set("projectile_damage", 20.0)
	node.set("projectile", projectile)

	var wait_time: float = 5.0
	var wait_timer := create_safe_timer(map, node, wait_time, "WaitTimer")
	wait_timer.timeout.connect(Callable(node, "_on_wait_timer_timeout"), CONNECT_PERSIST)
	node.set("_wait_timer", node.get_path_to(wait_timer))
	wait_timer.one_shot = false
	wait_timer.autostart = true

	# binding misc_fireball properties
	entity.bind_unit_property("speed", "projectile_speed")

	return node
