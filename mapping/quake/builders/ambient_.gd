@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := AudioStreamPlayer3D.new()

	match entity.get_classname_property(""):
		"ambient_drip":
			node.stream = preload("../sounds/ambience/drip1.wav")
		"ambient_drone":
			node.stream = preload("../sounds/ambience/drone6.wav")
		"ambient_comp_hum":
			node.stream = preload("../sounds/ambience/comp1.wav")
		"ambient_flouro_buzz":
			node.stream = preload("../sounds/ambience/buzz1.wav")
		"ambient_light_buzz":
			node.stream = preload("../sounds/ambience/fl_hum1.wav")
		"ambient_suck_wind":
			node.stream = preload("../sounds/ambience/suck1.wav")
		"ambient_swamp1":
			node.stream = preload("../sounds/ambience/swamp1.wav")
		"ambient_swamp2":
			node.stream = preload("../sounds/ambience/swamp2.wav")
		"ambient_thunder":
			node.stream = preload("../sounds/ambience/thunder1.wav")
		_:
			node.stream = entity.get_sound_property("noise", null)
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true

	return node
