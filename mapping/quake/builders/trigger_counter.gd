@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").get_appearflags(map, entity):
		return null
	# trigger: counter
	var node := Marker3D.new()
	node.set_script(preload("../scripts/trigger_counter.gd"))

	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := preload("__post.gd").create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	# target, targetname base
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")
	entity.bind_string_property("targetname", "name")

	entity.bind_int_property("count", "count")
	if not entity.get_int_property("spawnflags", 0) & 1: # no message
		entity.bind_string_property("message", "message")

	return node
