extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var light: Light3D = null
	var light_prefix: String = "spot_"
	light = build_spot_light(map, entity)
	if not light:
		light = OmniLight3D.new()
		light_prefix = "omni_"

	if light is OmniLight3D:
		light.omni_range = entity.get_unit_property("light", 300)
	elif entity.get_mangle_property(null) != null:
		light.spot_range = entity.get_unit_property("light", 300)

	light.light_energy = entity.get_unit_property("light", 300)
	light.light_color = entity.get_color_property("_color", Color.WHITE)
	light.light_bake_mode = Light3D.BAKE_STATIC

	# handling light delay property
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

	# handling light wait property
	if light is SpotLight3D:
		light.spot_attenuation *= entity.get_float_property("wait", 1.0)
	else:
		light.omni_attenuation *= entity.get_float_property("wait", 1.0)

	# handling light flickering styles
	var light_style: int = entity.get_int_property("style", 0)
	if light_style > 0 and light_style <= 11:
		light.set_script(map.loader.load_script("scripts/light-style"))
		light.set("style", light_style)

	if entity.get_int_property("spawnflags", 0) & 1: # start off
		light.visible = false

	# optimizing lights for large scenes
	light.distance_fade_enabled = true
	light.distance_fade_begin = 40.0
	light.distance_fade_length = 10.0

	# binding light properties
	bind_target_base(entity)
	bind_targetname_base(entity)

	# loading light model instance
	var light_model_instance := load_model(map, entity)
	if light_model_instance:
		light_model_instance.add_child(light, map.settings.readable_node_names)
		return light_model_instance
	return light


static func build_spot_light(map: MapperMap, entity: MapperEntity) -> SpotLight3D:
	# lights with mangle property are spot lights
	if entity.get_mangle_property(null) != null:
		entity.bind_mangle_property("rotation", "YpR")
		return SpotLight3D.new()

	# lights that target info_null are spot lights
	var target := map.get_first_entity_target(entity, "target", "targetname", "info_null")
	if not target:
		return null

	var light := SpotLight3D.new()
	var origin: Vector3 = entity.get_origin_property(entity.center)
	var target_origin: Vector3 = target.get_origin_property(target.center)

	# obtating target direction and rotation
	var direction := Vector3(target_origin - origin)
	var direction_normalized := direction.normalized()
	var entity_rotation: Vector3 = entity.node_properties.get("rotation", Vector3.ZERO)
	var entity_basis := Basis.from_euler(entity_rotation)
	var entity_forward := -entity_basis.z
	var entity_up := entity_basis.y

	var light_rotation := Quaternion()
	if not direction_normalized.is_equal_approx(-entity_forward):
		light_rotation = Quaternion(entity_forward, direction_normalized)
	else:
		light_rotation = Quaternion(entity_up, PI)

	# creating spot light with slightly increased spot range
	light.spot_range = direction.length() + 32.0 / map.settings.unit_size
	light.rotation = light_rotation.get_euler()
	entity.node_properties.erase("rotation")

	return light


static func load_model(map: MapperMap, entity: MapperEntity) -> Node3D:
	var model: PackedScene = null
	var model_animation: String = ""
	match entity.get_classname_property():
		"light": # invisible light source
			pass
		"light_fluoro": # fluorescent light
			pass
		"light_fluorospark": # sparking fluorescent light
			pass
		"light_globe": # globe light
			model = map.loader.load_mdl("mdls/lights/s_light")
			model_animation = "frame"
		"light_flame_large_yellow": # large yellow flame
			model = map.loader.load_mdl("mdls/lights/flame2")
			model_animation = "flameb"
		"light_flame_small_yellow": # small yellow flame
			model = map.loader.load_mdl("mdls/lights/flame2")
			model_animation = "flame"
		"light_flame_small_white": # small white flame
			model = map.loader.load_mdl("mdls/lights/flame2")
			model_animation = "flame"
		"light_torch_small_walltorch": # small walltorch
			model = map.loader.load_mdl("mdls/lights/flame")
			model_animation = "flame"
	if model:
		var model_instance := model.instantiate()
		model_instance.set_script(map.loader.load_script("scripts/light"))
		model_instance.set("classname", entity.get_classname_property())
		model_instance.set("animation_name", model_animation)
		return model_instance

	return null
