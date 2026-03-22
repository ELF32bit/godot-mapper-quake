extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	# wall, starts animation when triggered (if supporting texture)
	var node := MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D")
	if not node:
		return null
	set_collision_layer_mask(node,
		["worldspawn-StaticBody3D"],
		[])

	# func_wall does not cast shadow
	for mesh_instance in node.find_children("*", "MeshInstance3D", false, false):
		mesh_instance.cast_shadow = false

	# creating unique instances of materials with alternative textures
	var alternative_textures_size: int = -1
	var animated_materials: Array[Material] = []
	for mesh_instance in node.find_children("*", "MeshInstance3D", false, false):
		if not mesh_instance.mesh:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var base_material: Material = null
			var override_material: Material = null
			base_material = mesh_instance.mesh.surface_get_material(surface_index)
			override_material = mesh_instance.get_surface_override_material(surface_index)

			# obtaining alternative textures size from the first non-empty base material texture slot
			var base_size := get_material_alternative_textures_size(map, base_material)
			if alternative_textures_size == -1 and base_size > 0:
				alternative_textures_size = base_size
			if alternative_textures_size == -1:
				continue

			# creating unique base material if alternative textures have the same size per slot
			var unique_base_material := create_unique_material(map, base_material, alternative_textures_size)
			if unique_base_material and unique_base_material != base_material:
				mesh_instance.mesh.surface_set_material(surface_index, unique_base_material)
				unique_base_material.set_script(map.loader.load_script("scripts/func_wall-material"))
				animated_materials.append(unique_base_material)

			# creating unique override material if alternative textures have the same size per slot
			var unique_override_material := create_unique_material(map, override_material, alternative_textures_size)
			if unique_override_material and unique_override_material != override_material:
				mesh_instance.set_surface_override_material(surface_index, unique_override_material)
				unique_override_material.set_script(map.loader.load_script("scripts/func_wall-material"))
				animated_materials.append(unique_override_material)

	# setting func_wall script
	node.set_script(map.loader.load_script("scripts/func_wall"))
	node.set("alternative_textures", alternative_textures_size)
	node.set("affected_materials", animated_materials)

	# binding func_wall properties
	bind_targetname_base(entity)

	return node


static func get_material_alternative_textures_size(map: MapperMap, material: Material) -> int:
	var property := map.settings.alternative_textures_metadata_property
	var alternative_textures: Dictionary = material.get_meta(property, {})
	for slot in alternative_textures:
		if alternative_textures[slot].size() > 0:
			return alternative_textures[slot].size()
	return 0


static func create_unique_material(map: MapperMap, material: Material, alternative_textures_size: int) -> Material:
	if not material:
		return null

	var property := map.settings.alternative_textures_metadata_property
	var alternative_textures: Dictionary = material.get_meta(property, {})
	if not alternative_textures.size() or not alternative_textures_size > 0:
		return material

	# ignoring materials with texture slots of different sizes
	for slot in alternative_textures:
		if alternative_textures[slot].size() > 0:
			if alternative_textures[slot].size() != alternative_textures_size:
				return material

	# creating unique material instance with unique animated textures
	var unique_material := material.duplicate()
	var unique_slot_textures: Dictionary = {}
	for slot in alternative_textures:
		var unique_textures: Array[Texture2D] = []
		for alternative_texture in alternative_textures[slot]:
			# duplicating animated textures in material metadata
			if alternative_texture is AnimatedTexture:
				unique_textures.append(alternative_texture.duplicate())
			else:
				unique_textures.append(alternative_texture)
				continue

			# also replacing material animated texture for the current slot
			var material_texture: Texture2D
			if unique_material is BaseMaterial3D:
				material_texture = unique_material.get_texture(slot)
				if material_texture and material_texture == alternative_texture:
					unique_material.set_texture(slot, unique_textures[-1])
			elif unique_material is ShaderMaterial:
				material_texture = unique_material.get_shader_parameter(slot)
				if material_texture and material_texture == alternative_texture:
					unique_material.set_shader_parameter(slot, unique_textures[-1])
		unique_slot_textures[slot] = unique_textures

	if unique_slot_textures.size():
		unique_material.set_meta(property, unique_slot_textures)
		return unique_material
	return material
