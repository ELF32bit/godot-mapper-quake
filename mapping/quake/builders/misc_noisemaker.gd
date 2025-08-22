extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# debug entity: continuously plays enforcer sounds
	var node := AudioStreamPlayer3D.new()
	node.set_script(preload("../scripts/misc_noisemaker.gd"))
	node.max_distance = 320.0 / map.settings.unit_size
	node.autoplay = true

	var enforcer_sounds: Array[AudioStream] = [
		map.loader.load_sound("sounds/enforcer/enfire"),
		map.loader.load_sound("sounds/enforcer/enfstop"),
		map.loader.load_sound("sounds/enforcer/sight1"),
		map.loader.load_sound("sounds/enforcer/sight2"),
		map.loader.load_sound("sounds/enforcer/sight3"),
		map.loader.load_sound("sounds/enforcer/sight4"),
		map.loader.load_sound("sounds/enforcer/pain1"),
		map.loader.load_sound("sounds/enforcer/pain2"),
		map.loader.load_sound("sounds/enforcer/death1"),
		map.loader.load_sound("sounds/enforcer/idle1"),
	]
	node.set("noises", enforcer_sounds)

	var timer := create_safe_timer(map, node, 0.1)
	timer.timeout.connect(Callable(node, "_on_timer_timeout"), CONNECT_PERSIST)
	timer.autostart = true

	return node
