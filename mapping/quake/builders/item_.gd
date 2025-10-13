extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	var item_skin: int = 0
	var item: PackedScene = null
	match entity.get_classname_property():
		"item_artifact_envirosuit": # environmental protection
			item = map.loader.load_mdl("mdls/items/suit")
		"item_artifact_super_damage": # quad damage
			item = map.loader.load_mdl("mdls/items/quaddama")
		"item_artifact_invulnerability": # pentagram of protection
			item = map.loader.load_mdl("mdls/items/invulner")
		"item_artifact_invisibility": # ring of shadows
			item = map.loader.load_mdl("mdls/items/invisibl")
		"item_armorInv": # red armor (200%)
			item = map.loader.load_mdl("mdls/items/armor")
			item_skin = 2
		"item_armor2": # yellow armor (150%)
			item = map.loader.load_mdl("mdls/items/armor")
			item_skin = 1
		"item_armor1": # green armor (100%)
			item = map.loader.load_mdl("mdls/items/armor")
			item_skin = 0
		"item_key1": # silver key
			match map.settings.options.get("_worldtype", 0):
				0: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_s_key")
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_s_key")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_s_key")
		"item_key2": # gold key
			match map.settings.options.get("_world_type", 0):
				0: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_g_key")
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_g_key")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_g_key")
		"item_sigil": # sigil
			if spawnflags & 8:
				item = map.loader.load_mdl("mdls/items/end4")
			elif spawnflags & 4:
				item = map.loader.load_mdl("mdls/items/end3")
			elif spawnflags & 2:
				item = map.loader.load_mdl("mdls/items/end2")
			else:
				item = map.loader.load_mdl("mdls/items/end1")
	if item:
		# creating rotating item instance
		var item_instance := item.instantiate()
		MapperUtilities.apply_entity_transform(entity, item_instance)
		item_instance.set_script(map.loader.load_script("scripts/item-rotating"))
		item_instance.set("classname", entity.get_classname_property())
		item_instance.set("skin", item_skin)

		# creating item pickup area
		var offset := Vector3.ZERO
		match entity.get_classname_property():
			"item_armor1", "item_armor2", "item_armorInv":
				offset = Vector3(0.0, 28.0, 0.0)
			_:
				offset = Vector3(0.0, 4.0, 0.0)
		var node := build_mdl_item(map, entity, Vector3(32.0, 56.0, 32.0), offset)
		MapperUtilities.add_global_child(item_instance, node, map.settings)
		node.move_child(item_instance, 0)

		# binding item properties
		bind_item_base(entity)
		return node

	# loading sub-map with an additional option
	map.settings.options["_map_is_item"] = true
	match entity.get_classname_property():
		"item_cells": # thunderbolt ammo
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_batt1")
			else:
				item = map.loader.load_map_raw("maps/items/b_batt0")
		"item_rockets": # rockets
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_rock1")
			else:
				item = map.loader.load_map_raw("maps/items/b_rock0")
		"item_shells": # shells
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_shell1")
			else:
				item = map.loader.load_map_raw("maps/items/b_shell0")
		"item_spikes": # nailgun/perforator ammo
			if spawnflags & 1: # large box
				item = map.loader.load_map_raw("maps/items/b_nail1")
			else:
				item = map.loader.load_map_raw("maps/items/b_nail0")
		"item_health": # health pack
			if spawnflags & 2: # megahealth
				item = map.loader.load_map_raw("maps/items/b_bh100")
			elif spawnflags & 1: # rotten
				item = map.loader.load_map_raw("maps/items/b_bh10")
			else:
				item = map.loader.load_map_raw("maps/items/b_bh25")
	map.settings.options.erase("_map_is_item")
	if item:
		var item_instance := item.instantiate()
		if entity.get_classname_property() != "item_health":
			# binding item properties
			bind_item_base(entity)
		return item_instance

	return null


static func build_mdl_item(map: MapperMap, entity: MapperEntity, size: Vector3, offset: Vector3) -> Node3D:
	var node := Area3D.new()
	MapperUtilities.apply_entity_transform(entity, node, true)
	node.position += offset / map.settings.unit_size
	set_collision_layer_mask(node,
		["item-Area3D"],
		["item-PhysicsBody3D"])
	node.monitorable = false

	# creating item area
	node.set_script(map.loader.load_script("scripts/item"))
	node.body_entered.connect(Callable(node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	# creating item area collision shape
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = size / map.settings.unit_size
	node.add_child(collision_shape, map.settings.readable_node_names)

	# creating item pickup sound player
	var pickup_sound_player := AudioStreamPlayer3D.new()
	node.add_child(pickup_sound_player, map.settings.readable_node_names)
	pickup_sound_player.name = "PickupSoundPlayer3D"

	# loading item sounds
	pickup_sound_player.stream = load_item_sounds(map, entity)

	# connecting pickup sound player finished signal
	pickup_sound_player.finished.connect(
		Callable(node, "_on_pickup_sound_finished"), CONNECT_PERSIST)
	node.set("_pickup_sound_player", node.get_path_to(pickup_sound_player))

	# binding item properties
	node.set("item_name", entity.get_classname_property(""))
	return node


static func load_item_sounds(map: MapperMap, entity: MapperEntity) -> AudioStream:
	match entity.get_classname_property():
		"item_armor1", "item_armor2", "item_armorInv":
			return map.loader.load_sound("sounds/items/armor1")
		"item_key1", "item_key2":
			match map.settings.options.get("_worldtype", 0):
				0: # medieval (wizard)
					return map.loader.load_sound("sounds/misc/medkey")
				1: # metal (runic)
					return map.loader.load_sound("sounds/misc/runekey")
				2: # base (tech)
					return map.loader.load_sound("sounds/misc/basekey")
		"item_sigil":
			return map.loader.load_sound("sounds/misc/runekey")
		"item_artifact_invulnerability":
			return map.loader.load_sound("sounds/items/protect")
		"item_artifact_envirosuit":
			return map.loader.load_sound("sounds/items/suit")
		"item_artifact_invisibility":
			return map.loader.load_sound("sounds/items/inv1")
		"item_artifact_super_damage":
			return map.loader.load_sound("sounds/items/damage")
		"worldspawn": # loaded as map prefabs
			match map.name:
				"b_bh10":
					return map.loader.load_sound("sounds/items/r_item1")
				"b_bh25":
					return map.loader.load_sound("sounds/items/health1")
				"b_bh100":
					return map.loader.load_sound("sounds/items/r_item2")
				_: # ammo
					return map.loader.load_sound("sounds/weapons/lock4")
		_: # weapons
			if entity.get_classname_property("").begins_with("weapon"):
				return map.loader.load_sound("sounds/weapons/pkup")
	return null
