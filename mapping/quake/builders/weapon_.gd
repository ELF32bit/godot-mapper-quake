extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null

	var weapon: PackedScene = null
	match entity.get_classname_property():
		"weapon_supershotgun": # double-barrelled shotgun
			weapon = map.loader.load_mdl("mdls/items/g_shot")
		"weapon_nailgun": # nailgun
			weapon = map.loader.load_mdl("mdls/items/g_nail")
		"weapon_supernailgun": # super nailgun
			weapon = map.loader.load_mdl("mdls/items/g_nail2")
		"weapon_grenadelauncher": # grenade launcher
			weapon = map.loader.load_mdl("mdls/items/g_rock")
		"weapon_rocketlauncher": # rocket launcher
			weapon = map.loader.load_mdl("mdls/items/g_rock2")
		"weapon_lightning": # thunderbolt
			weapon = map.loader.load_mdl("mdls/items/g_light")
	if not weapon:
		return null

	# creating rotating weapon instance
	var weapon_instance := weapon.instantiate()
	MapperUtilities.apply_entity_transform(entity, weapon_instance)
	weapon_instance.set_script(map.loader.load_script("scripts/item-rotating"))
	weapon_instance.set("classname", entity.get_classname_property())

	# creating weapon pickup area
	var node := preload("item_.gd").build_mdl_item(map, entity)
	MapperUtilities.add_global_child(weapon_instance, node, map.settings)
	node.move_child(weapon_instance, 0)

	# binding weapon properties
	bind_weapon_base(entity)

	return node
