extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null

	var node := AudioStreamPlayer3D.new()
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true

	match entity.get_classname_property():
		"ambient_drip": # dripping sound
			node.stream = map.loader.load_sound("sounds/ambience/drip1")
		"ambient_drone": # engine/machinery sound
			node.stream = map.loader.load_sound("sounds/ambience/drone6")
		"ambient_comp_hum": # computer background sounds
			node.stream = map.loader.load_sound("sounds/ambience/comp1")
		"ambient_flouro_buzz": # fluorescent buzzing sound
			node.stream = map.loader.load_sound("sounds/ambience/buzz1")
		"ambient_light_buzz": # buzzing sound from light
			node.stream = map.loader.load_sound("sounds/ambience/fl_hum1")
		"ambient_suck_wind": # wind sound
			node.stream = map.loader.load_sound("sounds/ambience/suck1")
		"ambient_swamp1": # frogs croaking
			node.stream = map.loader.load_sound("sounds/ambience/swamp1")
		"ambient_swamp2": # frogs croaking B
			node.stream = map.loader.load_sound("sounds/ambience/swamp2")
		"ambient_thunder": # thunder sound
			node.stream = map.loader.load_sound("sounds/ambience/thunder1")
		_:
			node.stream = entity.get_sound_property("noise", null)

	return node
