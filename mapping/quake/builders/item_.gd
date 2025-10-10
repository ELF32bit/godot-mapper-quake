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
			item = map.loader.load_mdl("mdls/items/suit.mdl")
		"item_artifact_super_damage": # quad damage
			item = map.loader.load_mdl("mdls/items/quaddama.mdl")
		"item_artifact_invulnerability": # pentagram of protection
			item = map.loader.load_mdl("mdls/items/invulner.mdl")
		"item_artifact_invisibility": # ring of shadows
			item = map.loader.load_mdl("mdls/items/invisibl.mdl")
		"item_armorInv": # red armor (200%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
			item_skin = 2
		"item_armor2": # yellow armor (150%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
			item_skin = 1
		"item_armor1": # green armor (100%)
			item = map.loader.load_mdl("mdls/items/armor.mdl")
			item_skin = 0
		"item_key1": # silver key
			match map.settings.options.get("_worldtype", 0):
				0: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_s_key.mdl")
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_s_key.mdl")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_s_key.mdl")
		"item_key2": # gold key
			match map.settings.options.get("_world_type", 0):
				0: # medieval (wizard)
					item = map.loader.load_mdl("mdls/keys/w_g_key.mdl")
				1: # metal (runic)
					item = map.loader.load_mdl("mdls/keys/m_g_key.mdl")
				2: # base (tech)
					item = map.loader.load_mdl("mdls/keys/b_g_key.mdl")
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
		# creating rotating item instance
		var item_instance := item.instantiate()
		MapperUtilities.apply_entity_transform(entity, item_instance)
		item_instance.set_script(map.loader.load_script("scripts/item-rotating"))
		item_instance.set("classname", entity.get_classname_property())
		item_instance.set("skin", item_skin)
		# creating item pickup area
		var node := build_mdl_item(map, entity)
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


static func build_mdl_item(map: MapperMap, entity: MapperEntity, size: Vector3 = Vector3(32.0, 32.0, 32.0), offset: Vector3 = Vector3(0.0, 32.0, 0.0)) -> Node:
	var node := Area3D.new()
	MapperUtilities.apply_entity_transform(entity, node, true)
	node.position += offset / map.settings.unit_size
	set_collision_layer_mask(node,
		["item_-Area3D"],
		["item_-PhysicsBody3D"])
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

	# loading item sounds TODO: load correct sounds
	pickup_sound_player.stream = map.loader.load_sound("sounds/items/health1")

	# connecting pickup sound player finished signal
	pickup_sound_player.finished.connect(
		Callable(node, "_on_pickup_sound_finished"), CONNECT_PERSIST)
	node.set("_pickup_sound_player", node.get_path_to(pickup_sound_player))

	# binding item properties
	node.set("item_name", entity.get_classname_property(""))
	return node
