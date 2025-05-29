@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := OmniLight3D.new()

	node.omni_range = entity.get_unit_property("light", 300)
	node.light_energy = 2.0 * entity.get_unit_property("light", 300)
	node.light_color = entity.get_color_property("_color", Color.WHITE)
	node.light_bake_mode = Light3D.BAKE_DISABLED

	if map.settings.prefer_static_lighting:
		node.light_bake_mode = Light3D.BAKE_STATIC

	node.distance_fade_enabled = true
	node.distance_fade_begin = 40.0
	node.distance_fade_length = 10.0

	return node
