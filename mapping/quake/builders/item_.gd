static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	var item: PackedScene = null
	match entity.get_classname_property(null):
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
			item = map.loader.load_mdl("mdls/keys/w_s_key.mdl")
		"item_key2": # gold key
			item = map.loader.load_mdl("mdls/keys/w_g_key")
		"item_sigil": # sigil
			if spawnflags & 8 != 0:
				item = map.loader.load_mdl("mdls/items/end4.mdl")
			elif spawnflags & 4 != 0:
				item = map.loader.load_mdl("mdls/items/end3.mdl")
			elif spawnflags & 2 != 0:
				item = map.loader.load_mdl("mdls/items/end2.mdl")
			else:
				item = map.loader.load_mdl("mdls/items/end1.mdl")
	if item:
		var item_instance := item.instantiate()
		entity.bind_string_property("message", "message")
		entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
		entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
		entity.bind_float_property("delay", "delay")
		return item_instance

	map.settings.options["__map_is_item"] = true
	match entity.get_classname_property(null):
		"item_cells": # thunderbolt ammo
			if spawnflags & 1 != 0: # large box
				item = map.loader.load_map_raw("maps/items/b_batt1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_batt0.map")
		"item_rockets": # rockets
			if spawnflags & 1 != 0: # large box
				item = map.loader.load_map_raw("maps/items/b_rock1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_rock0.map")
		"item_shells": # shells
			if spawnflags & 1 != 0: # large box
				item = map.loader.load_map_raw("maps/items/b_shell1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_shell0.map")
		"item_spikes": # nailgun/perforator ammo
			if spawnflags & 1 != 0: # large box
				item = map.loader.load_map_raw("maps/items/b_nail1.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_nail0.map")
		"item_health": # health pack
			if spawnflags & 2 != 0: # megahealth
				item = map.loader.load_map_raw("maps/items/b_bh100.map")
			elif spawnflags & 1 != 0: # rotten
				item = map.loader.load_map_raw("maps/items/b_bh10.map")
			else:
				item = map.loader.load_map_raw("maps/items/b_bh25.map")
	map.settings.options.erase("__map_is_item")
	if item:
		var item_instance := item.instantiate()
		if entity.get_classname_property("") != "item_health":
			entity.bind_string_property("message", "message")
			entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
			entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
			entity.bind_float_property("delay", "delay")
		return item_instance

	return null
