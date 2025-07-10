static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null

	var weapon: PackedScene = null
	match entity.get_classname_property(null):
		"weapon_supershotgun": # double-barrelled shotgun
			weapon = map.loader.load_mdl("mdls/items/g_shot.mdl")
		"weapon_nailgun": # nailgun
			weapon = map.loader.load_mdl("mdls/items/g_nail.mdl")
		"weapon_supernailgun": # super nailgun
			weapon = map.loader.load_mdl("mdls/items/g_nail2.mdl")
		"weapon_grenadelauncher": # grenade launcher
			weapon = map.loader.load_mdl("mdls/items/g_rock.mdl")
		"weapon_rocketlauncher": # rocket launcher
			weapon = map.loader.load_mdl("mdls/items/g_rock2.mdl")
		"weapon_lightning": # thunderbolt
			weapon = map.loader.load_mdl("mdls/items/g_light.mdl")
	if not weapon:
		return null

	entity.bind_string_property("message", "message")
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_float_property("delay", "delay")

	var weapon_instance := weapon.instantiate()
	return weapon_instance
