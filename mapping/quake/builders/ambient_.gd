@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null

	var node := AudioStreamPlayer3D.new()
	match entity.get_classname_property(null):
		"ambient_drip": # dripping sound
			node.stream = preload("../sounds/ambience/drip1.wav")
		"ambient_drone": # engine/machinery sound
			node.stream = preload("../sounds/ambience/drone6.wav")
		"ambient_comp_hum": # computer background sounds
			node.stream = preload("../sounds/ambience/comp1.wav")
		"ambient_flouro_buzz": # fluorescent buzzing sound
			node.stream = preload("../sounds/ambience/buzz1.wav")
		"ambient_light_buzz": # buzzing sound from light
			node.stream = preload("../sounds/ambience/fl_hum1.wav")
		"ambient_suck_wind": # wind sound
			node.stream = preload("../sounds/ambience/suck1.wav")
		"ambient_swamp1": # frogs croaking
			node.stream = preload("../sounds/ambience/swamp1.wav")
		"ambient_swamp2": # frogs croaking B
			node.stream = preload("../sounds/ambience/swamp2.wav")
		"ambient_thunder": # thunder sound
			node.stream = preload("../sounds/ambience/thunder1.wav")
		_:
			node.stream = entity.get_sound_property("noise", null)
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true

	return node
