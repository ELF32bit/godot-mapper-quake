extends "../layers.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var node := MapperUtilities.create_merged_brush_entity(entity, "StaticBody3D")
	if not node:
		return null
	node.set_script(preload("../scripts/func_wall.gd"))

	# creating unique instances of animated materials and animated textures
	var m_property := map.settings.alternative_textures_metadata_property
	var animated_materials: Array[Material] = []
	var alternative_textures: int = -1
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			for surface_index in range(child.mesh.get_surface_count()):
				var base_material: Material = child.mesh.surface_get_material(surface_index)
				var override_material: Material = child.get_surface_override_material(surface_index)

				for index in range(2):
					var material: Material
					if index == 0:
						material = base_material
					elif index == 1:
						material = override_material
					if not material:
						continue

					var textures: Dictionary = material.get_meta(m_property, {})
					if not textures.size():
						continue
					material = material.duplicate()

					var unique_slot_textures := {}
					for slot in textures:
						if alternative_textures == -1:
							alternative_textures = textures[slot].size()
						elif alternative_textures != textures[slot].size():
							continue

						var unique_textures: Array[Texture2D] = []
						for texture in textures[slot]:
							var unique_texture: AnimatedTexture
							if texture is AnimatedTexture:
								unique_texture = texture.duplicate()
								unique_textures.append(unique_texture)
							else:
								unique_textures.append(texture)
								continue

							var material_texture: Texture2D
							if material is BaseMaterial3D:
								material_texture = material.get_texture(slot)
								if material_texture and material_texture == texture:
									material.set_texture(slot, unique_texture)
							elif material is ShaderMaterial:
								material_texture = material.get_shader_parameter(slot)
								if material_texture and material_texture == texture:
									material.set_shader_parameter(slot, unique_texture)
						unique_slot_textures[slot] = unique_textures

					if unique_slot_textures.size():
						if index == 0:
							material.set_meta(m_property, unique_slot_textures)
							child.mesh.surface_set_material(surface_index, material)
						elif index == 1:
							material.set_meta(m_property, unique_slot_textures)
							child.set_surface_override_material(surface_index, material)

						material.set_script(preload("../scripts/func_wall+material.gd"))
						animated_materials.append(material)
	node.alternative_textures = alternative_textures
	node.affected_materials = animated_materials

	entity.bind_string_property("targetname", "name")

	node.collision_layer = 0; node.collision_mask = 0;
	node.set_collision_layer_value(PHYSICS_LAYERS_3D["worldspawn"], true)

	return node
