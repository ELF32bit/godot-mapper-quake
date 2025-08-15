extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# trigger: counter
	var node := Marker3D.new()
	node.set_script(preload("../scripts/trigger_counter.gd"))

	# creating trigger_counter delay timer
	var delay_time: float = entity.get_float_property("delay", 0.0)
	if not delay_time < 0.0:
		var delay_timer := create_safe_timer(map, node, delay_time)
		delay_timer.timeout.connect(Callable(node, "_on_delay_timer_timeout"), CONNECT_PERSIST)
		node.set("_delay_timer", node.get_path_to(delay_timer))
		delay_timer.one_shot = true

	# handling trigger_counter spawnflags
	if not entity.get_int_property("spawnflags", 0) & 1: # no message
		entity.bind_string_property("message", "message")

	# binding trigger_counter properties
	bind_target_base(entity)
	bind_targetname_base(entity)
	entity.bind_int_property("count", "count")

	return node
