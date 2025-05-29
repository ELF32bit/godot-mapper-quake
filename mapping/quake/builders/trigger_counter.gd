@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := Marker3D.new()
	node.set_script(preload("../scripts/trigger_counter.gd"))

	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := Timer.new()
		delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.add_child(delay_timer, map.settings.readable_node_names)
		node._delay_timer = node.get_path_to(delay_timer)
		delay_timer.wait_time = clampf(delay_time, 0.05, INF)
		delay_timer.one_shot = true

	entity.bind_string_property("targetname", "name")
	entity.bind_int_property("count", "count")
	entity.bind_string_property("message", "message")
	entity.bind_signal_property("target", "targetname", "generic", "_on_generic_signal")
	entity.bind_signal_property("killtarget", "targetname", "generic", "queue_free")

	return node
