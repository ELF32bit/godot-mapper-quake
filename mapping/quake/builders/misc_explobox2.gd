extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node = Node3D.new()
	MapperUtilities.apply_entity_transform(entity, node, true)

	var body := StaticBody3D.new()
	body.position = node.position
	MapperUtilities.add_global_child(body, node, map.settings)

	var scene := map.loader.load_map("maps/items/b_exbox2.map")
	if scene:
		var scene_instance := scene.instantiate()
		var mesh_instances := scene_instance.find_children("*", "MeshInstance3D", true)
		for mesh_instance in mesh_instances:
			var c_mesh_instance := mesh_instance.duplicate()
			c_mesh_instance.transform = node.transform * MapperUtilities.get_tree_transform(mesh_instance)
			MapperUtilities.add_global_child(c_mesh_instance, body, map.settings)
		scene_instance.free()

	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(32, 32, 32) / map.settings.unit_size
	collision_shape.position = node.position - Vector3(16, 0, 16) / map.settings.unit_size
	collision_shape.position += Vector3.UP * collision_shape.shape.size.y / 2
	MapperUtilities.add_global_child(collision_shape, body, map.settings)

	body.collision_layer = 0; body.collision_mask = 0;
	body.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)

	return node
