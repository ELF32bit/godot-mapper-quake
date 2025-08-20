extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
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
	weapon_instance.set_script(preload("../scripts/editor/item.gd"))
	weapon_instance.classname = entity.get_classname_property()

	# binding weapon properties
	bind_weapon_base(entity)

	return weapon_instance
