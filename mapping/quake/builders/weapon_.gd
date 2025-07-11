static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null

	var weapon: PackedScene = null
	match entity.get_classname_property():
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

	var weapon_instance := weapon.instantiate()
	weapon_instance.set_script(preload("../scripts/editor/item_rotating.gd"))

	preload("__post.gd").bind_target_base(entity)
	preload("__post.gd").bind_targetname_base(entity)
	entity.bind_string_property("message", "message")
	entity.bind_float_property("delay", "delay")

	return weapon_instance
