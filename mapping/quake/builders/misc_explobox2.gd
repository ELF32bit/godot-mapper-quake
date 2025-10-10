extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# small exploding container
	var node := Area3D.new()
	MapperUtilities.apply_entity_transform(entity, node, true)
	set_collision_layer_mask(node,
		["misc_explobox-Area3D"],
		["misc_explobox-PhysicsBody3D"])
	node.monitorable = false

	# loading sub-map with an additional option
	map.settings.options["_map_is_explobox"] = true
	var explobox := map.loader.load_map_raw("maps/items/b_exbox2.map")
	map.settings.options.erase("_map_is_explobox")

	if explobox:
		var explobox_instance := explobox.instantiate()
		node.add_child(explobox_instance, map.settings.readable_node_names)
	else:
		node.free()
		return null

	# removing unnecessary map node
	var map_node := node.get_child(0)
	for child in map_node.get_children():
		child.owner = null
		map_node.remove_child(child)
		node.add_child(child, map.settings.readable_node_names)
	map_node.free()

	# creating misc_explobox2 explosion shape
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 160 / map.settings.unit_size

	var collision_shape := CollisionShape3D.new()
	node.add_child(collision_shape, map.settings.readable_node_names)
	collision_shape.shape = sphere_shape

	# setting misc_explobox2 explosion area
	var explobox_body := node.get_child(0).get_child(0)
	explobox_body.set("_area", explobox_body.get_path_to(node))
	explobox_body.set("damage", 40)

	return node
