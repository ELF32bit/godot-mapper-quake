extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	var item: PackedScene = null
	match entity.get_classname_property():
		"item_artifact_envirosuit": # environmental protection
			item = map.loader.load_mdl("mdls/items/suit.mdl")
		"item_artifact_super_damage": # quad damage
			item = map.loader.load_mdl("mdls/items/quaddama.mdl")
		"item_artifact_invulnerability": # pentagram of protection
			item = map.loader.load_mdl("mdls/items/invulner.mdl")
		"item_artifact_invisibility": # ring of shadows
			item = map.loader.load_mdl("mdls/items/invisibl.mdl")
		"item_armorInv": # red armor (200%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
		"item_armor2": # yellow armor (150%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
		"item_armor1": # green armor (100%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
		"item_key1": # silver key
			match map.settings.options.get("_worldtype", 0):
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_s_key.mdl")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_s_key.mdl")
				_: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_s_key.mdl")
		"item_key2": # gold key
			match map.settings.options.get("_world_type", 0):
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_g_key.mdl")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_g_key.mdl")
				_: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_g_key.mdl")
		"item_sigil": # sigil
			if spawnflags & 8:
				item = map.loader.load_mdl("mdls/items/end4.mdl")
			elif spawnflags & 4:
				item = map.loader.load_mdl("mdls/items/end3.mdl")
			elif spawnflags & 2:
				item = map.loader.load_mdl("mdls/items/end2.mdl")
			else:
				item = map.loader.load_mdl("mdls/items/end1.mdl")
	if item:
		var item_instance := item.instantiate()
		item_instance.set_script(preload("../scripts/editor/item.gd"))
		item_instance.set("item_name", entity.get_classname_property(""))
		# binding item properties
		bind_item_base(entity)
		return item_instance

	map.settings.options["_map_is_item"] = true
	match entity.get_classname_property():
		"item_cells": # thunderbolt ammo
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_batt1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_batt0.map")
		"item_rockets": # rockets
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_rock1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_rock0.map")
		"item_shells": # shells
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_shell1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_shell0.map")
		"item_spikes": # nailgun/perforator ammo
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_nail1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_nail0.map")
		"item_health": # health pack
			if spawnflags & 2: # megahealth
				item = map.loader.load_map_raw("maps/items/b_bh100.map")
			elif spawnflags & 1: # rotten
				item = map.loader.load_map_raw("maps/items/b_bh10.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_bh25.map")
	map.settings.options.erase("_map_is_item")
	if item:
		var item_instance := item.instantiate()
		if entity.get_classname_property() != "item_health":
			# binding item properties
			bind_item_base(entity)
		return item_instance

	return null
