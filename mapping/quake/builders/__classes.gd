extends "__utilities.gd"


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
	entity.bind_float_property("delay", "delay_time")


static func bind_weapon_base(entity: MapperEntity) -> void:
	bind_item_base(entity)


static func bind_ammo_base(entity: MapperEntity) -> void:
	bind_item_base(entity)
	match entity.get_int_property("spawnflags", 0):
		1: # large box
			pass


static func bind_trigger_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_int_property("sounds", "sounds")
	match entity.get_int_property("sounds", 0):
		0: # none
			pass
		1: # secret sound
			pass
		2: # beep beep
			pass
		3: # large switch
			pass
	entity.bind_float_property("delay", "delay_time")
	entity.bind_string_property("message", "message")


static func bind_monster_base(entity: MapperEntity) -> void:
	bind_target_base(entity)
	bind_targetname_base(entity)
	match entity.get_int_property("spawnflags", 0):
		1: # ambush
			pass
