@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# debug entity: continuously plays enforcer sounds
	var node := AudioStreamPlayer3D.new()
	node.set_script(preload("../scripts/misc_noisemaker.gd"))
	var enforcer_sounds: Array[AudioStream] = [
		preload("../sounds/enforcer/death1.wav"),
		preload("../sounds/enforcer/enfire.wav"),
		preload("../sounds/enforcer/enfstop.wav"),
		preload("../sounds/enforcer/idle1.wav"),
		preload("../sounds/enforcer/pain1.wav"),
		preload("../sounds/enforcer/pain2.wav"),
		preload("../sounds/enforcer/sight1.wav"),
		preload("../sounds/enforcer/sight2.wav"),
		preload("../sounds/enforcer/sight3.wav"),
		preload("../sounds/enforcer/sight4.wav"),
	]
	node.noises = enforcer_sounds
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true
	return node
