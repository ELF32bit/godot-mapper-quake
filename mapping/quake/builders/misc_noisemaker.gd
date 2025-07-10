@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# debug entity: continuously plays enforcer sounds
	var node := AudioStreamPlayer3D.new()
	node.set_script(preload("../scripts/misc_noisemaker.gd"))
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true

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
	node.set("noises", enforcer_sounds)

	var timer := preload("__post.gd").create_safe_timer(map, node, 0.1)
	timer.timeout.connect(Callable(node, "_on_timer_timeout"), CONNECT_PERSIST)
	timer.autostart = true

	return node
