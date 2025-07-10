extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# large exploding container
	var node := StaticBody3D.new()
	MapperUtilities.apply_entity_transform(entity, node, true)
	set_collision_layer_mask(node, ["worldspawn"], [])

	map.settings.options["__map_is_item"] = true
	var explobox := map.loader.load_map_raw("maps/items/b_explob.map")
	map.settings.options.erase("__map_is_item")
	if explobox:
		var explobox_instance := explobox.instantiate()
		node.add_child(explobox_instance, map.settings.readable_node_names)

	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(32, 64, 32) / map.settings.unit_size
	collision_shape.position = node.position - Vector3(16, 0, 16) / map.settings.unit_size
	collision_shape.position += Vector3.UP * collision_shape.shape.size.y / 2
	MapperUtilities.add_global_child(collision_shape, node, map.settings)

	return node
