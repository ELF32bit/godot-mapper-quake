extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var light: Light3D = null
	var light_prefix := "omni_"

	var target := map.get_first_entity_target(entity, "target", "targetname", "info_null")
	if target:
		light = SpotLight3D.new()
		var origin = entity.get_origin_property(entity.center)
		var target_origin = target.get_origin_property(target.center)
		var direction := Vector3(target_origin - origin).normalized()
		var basis := Basis.from_euler(entity.node_properties.get("rotation", Vector3.ZERO))
		entity.node_properties["rotation"] = Quaternion(-basis.z, direction).get_euler()
		light_prefix = "spot_"
	else:
		light = OmniLight3D.new()

	var model: PackedScene = null
	var model_instance: Node = null
	match entity.get_classname_property():
		"light": # invisible light source
			pass
		"light_fluoro": # fluorescent light
			pass
		"light_fluorospark": # sparking fluorescent light
			pass
		"light_globe": # globe light
			model = map.loader.load_mdl("mdls/misc/s_light")
		"light_flame_large_yellow": # large yellow flame
			model = map.loader.load_mdl("mdls/misc/flame2")
		"light_flame_small_yellow": # small yellow flame
			model = map.loader.load_mdl("mdls/misc/flame2")
		"light_flame_small_white": # small white flame
			model = map.loader.load_mdl("mdls/misc/flame2")
		"light_torch_small_walltorch": # small walltorch
			model = map.loader.load_mdl("mdls/misc/flame")
	if model:
		model_instance = model.instantiate()

	light.set(light_prefix + "range", entity.get_unit_property("light", 300))
	light.light_energy = entity.get_unit_property("light", 300)
	light.light_color = entity.get_color_property("_color", Color.WHITE)

	match entity.get_int_property("delay", 0):
		0: # linear falloff (default)
			light.set(light_prefix + "attenuation", 1.0)
		1: # inverse distance falloff
			light.set(light_prefix + "attenuation", 0.5)
		2: # inverse distance squared
			light.set(light_prefix + "attenuation", 0.25)
		3: # no falloff
			light.set(light_prefix + "attenuation", 0.01)
		4: # local minlight
			light.set(light_prefix + "attenuation", 0.01)
		5: # inverse distance squared B
			light.set(light_prefix + "attenuation", 2.0)
		_:
			light.set(light_prefix + "attenuation", 1.0)

	if target:
		light.spot_attenuation *= entity.get_float_property("wait", 1.0)
	else:
		light.omni_attenuation *= entity.get_float_property("wait", 1.0)

	match entity.get_int_property("style", 0):
		0: # normal
			pass
		10: # fluorescent flicker
			pass
		2 : # slow, strong pulse
			pass
		11: # slow pulse, noblack
			pass
		5 : # gentle pulse
			pass
		1 : # flicker A
			pass
		6 : # flicker B
			pass
		3 : # candle A
			pass
		7 : # candle B
			pass
		8 : # candle C
			pass
		4 : # fast strobe
			pass
		9 : # slow strobe
			pass
		_:
			pass

	if entity.get_int_property("spawnflags", 0) & 1: # start off
		pass

	#if map.settings.prefer_static_lighting:
	#	light.visible = false
	light.light_bake_mode = Light3D.BAKE_STATIC
	light.distance_fade_enabled = true
	light.distance_fade_begin = 40.0
	light.distance_fade_length = 10.0

	# binding light properties
	bind_target_base(entity)
	bind_targetname_base(entity)

	if model_instance:
		model_instance.add_child(light, map.settings.readable_node_names)
		return model_instance
	return light
