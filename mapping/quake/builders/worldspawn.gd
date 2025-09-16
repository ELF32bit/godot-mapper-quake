extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if map.settings.options.get("_map_is_item", false):
		return build_item(map, entity)

	var node := MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D")
	if not node:
		return null
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		[])

	# creating world entity navigation region
	var navigation_region := MapperUtilities.create_navigation_region(map, node)
	MapperUtilities.add_to_navigation_region(node, navigation_region)

	# adding map entities to worldspawn navigation region
	for map_entity in map.classnames.get("func_wall", []):
		MapperUtilities.add_entity_to_navigation_region(map_entity, navigation_region)
	for map_entity in map.classnames.get("func_detail", []):
		MapperUtilities.add_entity_to_navigation_region(map_entity, navigation_region)
	for map_entity in map.classnames.get("func_detail_wall", []):
		MapperUtilities.add_entity_to_navigation_region(map_entity, navigation_region)

	# creating root node to hold liquid areas
	var root_node := Node3D.new()
	root_node.transform = node.transform
	MapperUtilities.add_global_child(node, root_node, map.settings)

	# creating world entity liquid areas excluded from the merged brush entity
	var liquids: Dictionary = {}
	for brush in entity.brushes:
		var liquid: int = brush.get_uniform_property("liquid", 0)
		if not liquid > 0:
			continue

		# creating node to hold liquid areas of certain type
		if not liquid in liquids:
			var liquid_node = Node3D.new()
			root_node.add_child(liquid_node, map.settings.readable_node_names)
			match liquid:
				1:
					liquid_node.name = "water"
				2:
					liquid_node.name = "lava"
				3:
					liquid_node.name = "slime"
				_:
					liquid_node.name = "liquid-%s" % liquid
			liquids[liquid] = liquid_node

		# creating excluded from the merged entity liquid area brush
		var area := MapperUtilities.create_brush(entity, brush, "Area3D")
		if not area:
			continue
		set_collision_layer_mask(area,
			["worldspawn-liquid-Area3D"],
			["worldspawn-liquid-PhysicsBody3D"])
		MapperUtilities.add_global_child(area, liquids[liquid], map.settings)

		# re-enabling disabled brush nodes
		for child in area.get_children():
			if child is MeshInstance3D:
				child.visible = true
			elif child is CollisionShape3D:
				child.disabled = false
			elif child is OccluderInstance3D:
				child.visible = false

		# finishing constructing liquid area
		area.set_script(map.loader.load_script("scripts/worldspawn-liquid"))
		area.body_entered.connect(Callable(area, "_on_body_entered"), CONNECT_PERSIST)
		area.body_exited.connect(Callable(area, "_on_body_exited"), CONNECT_PERSIST)
		area.set("planes", brush.get_planes(true)) # only visible planes are required
		area.set("liquid", liquid)

		# also creating camera blocking static body for third person view
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = brush.concave_shape
		collision_shape.shape.backface_collision = true

		var static_body := StaticBody3D.new()
		static_body.position = brush.center
		MapperUtilities.add_global_child(static_body, area, map.settings)
		static_body.add_child(collision_shape, map.settings.readable_node_names)
		set_collision_layer_mask(static_body,
			["worldspawn-liquid-StaticBody3D"],
			[])

	# binding worldspawn properties
	entity.bind_string_property("message", "message")
	map.settings.options["_world_type"] = entity.get_int_property("worldtype", 0)
	if entity.get_int_property("sounds", 0) > 0:
		var audio_stream_player := AudioStreamPlayer.new()
		node.add_child(audio_stream_player, map.settings.readable_node_names)
		audio_stream_player.stream = null # CD tracks 2-11 are not included
		audio_stream_player.autoplay = true

	return root_node


static func build_item(map: MapperMap, entity: MapperEntity) -> Node:
	var item_class := "Area3D"
	match map.name:
		"b_explob", "b_exbox2":
			item_class = "StaticBody3D"

	var node := MapperUtilities.create_merged_brush_entity(entity, item_class)
	if not node:
		return null
	if item_class == "StaticBody3D":
		return node
	set_collision_layer_mask(node,
		["%s-Area3D" % map.name],
		["%s-PhysicsBody3D" % map.name])

	# setting item script and connecting signals
	map.node.set_script(map.loader.load_script("scripts/item"))
	node.body_entered.connect(Callable(map.node, "_on_body_entered"), CONNECT_PERSIST)
	node.monitorable = false

	map.node.set("item_name", map.name)
	return node


static func post_build_environment(map: MapperMap, entity: MapperEntity) -> void:
	if entity.get_float_property("light", 0.0) > 0.0:
		var world_environment := WorldEnvironment.new()
		entity.node.add_child(world_environment, map.settings.readable_node_names)
		entity.node.move_child(world_environment, 0)

		var environment := Environment.new()
		world_environment.environment = environment
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = entity.get_color_property("_color", Color.WHITE)
		environment.ambient_light_energy = entity.get_float_property("light")

	if entity.get_float_property("_sunlight", 0.0) > 0.0:
		var directional_light := DirectionalLight3D.new()
		entity.node.add_child(directional_light, map.settings.readable_node_names)
		entity.node.move_child(directional_light, 0)

		var default_rotation := Quaternion(Vector3.FORWARD, Vector3.DOWN).get_euler()
		directional_light.rotation = entity.get_property("convert_mangle_YpR", "_sun_mangle", default_rotation)
		directional_light.light_energy = entity.get_unit_property("_sunlight", 0.0)
		directional_light.light_bake_mode = Light3D.BAKE_STATIC
		directional_light.shadow_enabled = true
