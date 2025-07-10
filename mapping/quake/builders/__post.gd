@warning_ignore("unused_parameter")
static func build(map: MapperMap) -> void:
	if not map.settings.options.get("_map_is_item", false):
		var lightmap_gi := MapperUtilities.create_lightmap_gi(map, map.node)
		lightmap_gi.set_script(preload("../scripts/editor/lightmap.gd"))

		var first_world_entity: MapperEntity = null
		first_world_entity = map.classnames.get("worldspawn", [null])[0]
		if first_world_entity != null:
			preload("worldspawn.gd").post_build_environment(map, first_world_entity)


static func get_appearflags(map: MapperMap, entity: MapperEntity) -> bool:
	match map.settings.options.get("game_mode"):
		"easy":
			if entity.get_int_property("spawnflags", 0) % 256:
				return true
		"normal":
			if entity.get_int_property("spawnflags", 0) % 512:
				return true
		"hard":
			if entity.get_int_property("spawnflags", 0) % 1024:
				return true
		"deathmatch":
			if entity.get_int_property("spawnflags", 0) % 2048:
				return true
	return false


static func create_safe_timer(map: MapperMap, parent: Node, wait_time: float = 1.0) -> Timer:
	var timer := Timer.new()
	parent.add_child(timer, map.settings.readable_node_names)
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = clampf(wait_time, 0.05, INF)
	return timer
