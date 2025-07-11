@warning_ignore("unused_parameter")
static func build(map: MapperMap) -> void:
	if  map.settings.options.get("_map_is_item", false):
		return

	var lightmap_gi := MapperUtilities.create_lightmap_gi(map, map.node)
	lightmap_gi.set_script(preload("../scripts/editor/lightmap.gd"))

	var first_world_entity: MapperEntity = null
	first_world_entity = map.classnames.get("worldspawn", [null])[0]
	if first_world_entity != null:
		preload("worldspawn.gd").post_build_environment(map, first_world_entity)

	for entity in map.classnames.get("func_door", []):
		var linking_data := link_entities(map, entity, 32.0, true)
		preload("func_door.gd").post_build(map, linking_data)


static func bind_appearflags_base(map: MapperMap, entity: MapperEntity) -> bool:
	entity.bind_int_property("spawnflags", "spawnflags")
	match map.settings.options.get("game_mode"):
		"easy":
			if entity.get_int_property("spawnflags", 0) & 256:
				return true
		"normal":
			if entity.get_int_property("spawnflags", 0) & 512:
				return true
		"hard":
			if entity.get_int_property("spawnflags", 0) & 1024:
				return true
		"deathmatch":
			if entity.get_int_property("spawnflags", 0) & 2048:
				return true
	return false


static func bind_target_base(entity: MapperEntity, classname: String = "*") -> void:
	entity.bind_node_path_property("target", "targetname", "_target", classname)
	entity.bind_node_path_property("killtarget", "targetname", "_kill_target", classname)
	entity.bind_node_path_array_property("target", "targetname", "_targets", classname)
	entity.bind_node_path_array_property("killtarget", "targetname", "_kill_targets", classname)
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal", classname)
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free", classname)


static func bind_targetname_base(entity: MapperEntity) -> void:
	entity.bind_string_property("targetname", "name")


static func bind_trigger_base(map: MapperMap, entity: MapperEntity, node: Node, trigger_sound_player: AudioStreamPlayer3D, classname: String = "*") -> void:
	bind_target_base(entity, classname)
	bind_targetname_base(entity)

	match entity.get_int_property("sounds", 0):
		0: # none
			trigger_sound_player.stream = null
		1: # secret sound
			trigger_sound_player.stream = null
		2: # beep beep
			trigger_sound_player.stream = null
		3: # large switch
			trigger_sound_player.stream = null
		_:
			trigger_sound_player.stream = null

	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := preload("__post.gd").create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	entity.bind_string_property("message", "message")


static func create_safe_timer(map: MapperMap, parent: Node, wait_time: float = 1.0) -> Timer:
	var timer := Timer.new()
	parent.add_child(timer, map.settings.readable_node_names)
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = clampf(wait_time, 0.05, INF)
	return timer


static func link_entities(map: MapperMap, entity: MapperEntity, link_units: float = 32.0, use_door_spawnflags: bool = false) -> Array:
	if not entity.node:
		return []
	if not entity.aabb.has_surface():
		return []
	if entity.metadata.get("__is_linked", false):
		return []

	var linked_aabb := entity.aabb
	var linked_entities: Array[MapperEntity] = [entity]
	if use_door_spawnflags:
		if entity.get_int_property("spawnflags", 0) & 4: # don't link
			return [linked_entities, linked_aabb, link_units]

	entity.metadata["__is_linked"] = true
	var grow_by: float = link_units / map.settings.unit_size
	var classname: Variant = entity.get_classname_property()
	var entites: Array = map.classnames.get(classname, [])

	for another_entity in entites:
		if not another_entity.node:
			continue
		if not another_entity.aabb.has_surface():
			continue
		if another_entity.metadata.get("__is_linked", false):
			continue
		if use_door_spawnflags:
			if another_entity.get_int_property("spawnflags", 0) & 4: # don't link
				continue

		if linked_aabb.grow(grow_by).intersects(another_entity.aabb.grow(grow_by)):
			another_entity.metadata["__is_linked"] = true
			linked_entities.append(another_entity)
			linked_aabb = linked_aabb.merge(another_entity.aabb)

	return [linked_entities, linked_aabb, link_units]
