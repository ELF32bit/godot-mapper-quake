extends "../layers.gd"


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


static func bind_targetname_base(entity: MapperEntity) -> void:
	entity.bind_string_property("targetname", "name")


static func bind_target_base(entity: MapperEntity, classname: String = "*") -> void:
	entity.bind_node_path_property("target", "targetname", "_target", classname)
	entity.bind_node_path_property("killtarget", "targetname", "_kill_target", classname)
	entity.bind_node_path_array_property("target", "targetname", "_targets", classname)
	entity.bind_node_path_array_property("killtarget", "targetname", "_kill_targets", classname)
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal", classname)
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free", classname)


static func bind_item_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_string_property("message", "message")
	entity.bind_float_property("delay", "delay")


static func bind_weapon_base(entity: MapperEntity) -> void:
	bind_item_base(entity)


static func bind_ammo_base(entity: MapperEntity) -> void:
	bind_item_base(entity)
	match entity.get_int_property("spawnflags", 0):
		1: # large box
			pass
		_:
			pass


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


static func bind_monster_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	match entity.get_int_property("spawnflags", 0):
		1: # ambush
			pass
		_:
			pass
