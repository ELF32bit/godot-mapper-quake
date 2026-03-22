extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# large exploding container
	var node: Node3D = null

	# loading sub-map with an additional option
	map.settings.options["_map_is_explobox"] = true
	var explobox := map.loader.load_map_raw("maps/items/b_explob")
	map.settings.options.erase("_map_is_explobox")
	if not explobox:
		return null
	node = explobox.instantiate()

	# creating misc_explobox explosion area
	var area := Area3D.new()
	node.add_child(area, map.settings.readable_node_names)
	set_collision_layer_mask(area,
		["misc_explobox-Area3D"],
		["misc_explobox-PhysicsBody3D"])
	area.monitorable = false
	node.move_child(area, 0)

	# creating misc_explobox explosion shape
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = 160.0 / map.settings.unit_size
	area.add_child(collision_shape, map.settings.readable_node_names)

	# setting misc_explobox explosion area
	var explobox_body := node.get_node("worldspawn").get_child(0)
	explobox_body.set("_area", explobox_body.get_path_to(area))
	explobox_body.set("damage", 80)

	area.position = explobox_body.position
	return node
