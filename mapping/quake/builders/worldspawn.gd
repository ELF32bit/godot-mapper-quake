extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D")
	if not node:
		return null

	var root := Node3D.new()
	root.transform = node.transform
	MapperUtilities.add_global_child(node, root, map.settings)

	var navigation_region := MapperUtilities.create_navigation_region(entity, node)
	MapperUtilities.add_to_navigation_region(node, navigation_region)
	node.move_child(navigation_region, 1)

	# adding map entities to worldspawn navigation region
	for map_entity in map.classnames.get("func_detail", []):
		MapperUtilities.add_entity_to_navigation_region(map_entity, navigation_region)

	# creating worldspawn liquid areas
	var liquids := {}
	for brush in entity.brushes:
		var liquid: int = brush.get_uniform_property("liquid", 0)
		if not liquid > 0:
			continue

		if not liquid in liquids:
			var liquid_node = Node3D.new()
			liquid_node.name = "liquid-%s" % liquid
			liquid_node.transform = node.transform
			MapperUtilities.add_global_child(liquid_node, root, map.settings)
			liquids[liquid] = liquid_node

		var area := MapperUtilities.create_brush(entity, brush, "Area3D")
		if not area:
			continue

		MapperUtilities.add_global_child(area, liquids[liquid], map.settings)
		for child in area.get_children():
			if child is MeshInstance3D:
				child.visible = true
			elif child is CollisionShape3D:
				child.disabled = false
			elif child is OccluderInstance3D:
				child.visible = true
		var static_body := StaticBody3D.new()
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = brush.concave_shape
		collision_shape.shape.backface_collision = true
		static_body.add_child(collision_shape, map.settings.readable_node_names)
		static_body.position = brush.center
		MapperUtilities.add_global_child(static_body, area, map.settings)

		area.set_script(preload("../scripts/worldspawn+liquid.gd"))
		area.body_entered.connect(Callable(area, "_on_body_entered"), CONNECT_PERSIST)
		area.body_exited.connect(Callable(area, "_on_body_exited"), CONNECT_PERSIST)
		area.planes = brush.get_planes(true) # only visible planes are required
		area.liquid = liquid

		area.collision_layer = 0; area.collision_mask = 0;
		area.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn-liquid-areas"], true)
		area.set_collision_mask_value(PHYSICS_LAYERS_3D["worldspawn-liquid-characters"], true)

		static_body.collision_layer = 0; static_body.collision_mask = 0;
		static_body.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn-liquid-bodies"], true)

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)

	return root
