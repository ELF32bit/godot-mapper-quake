@tool
extends Material

@export var alternative_texture: int = -1:
	set(value):
		alternative_texture = -1
		var textures := get_alternative_textures()
		if is_class("BaseMaterial3D"):
			for slot in textures:
				if alternative_texture == -1:
					alternative_texture = clampi(value, 0, textures[slot].size() - 1)
				if alternative_texture < textures[slot].size():
					call("set_texture", slot, textures[slot][alternative_texture])
		elif is_class("ShaderMaterial"):
			for slot in textures:
				if alternative_texture == -1:
					alternative_texture = clampi(value, 0, textures[slot].size() - 1)
				if alternative_texture < textures[slot].size():
					call("set_shader_parameter", slot, textures[slot][alternative_texture])

@export var alternative_texture_fps: float = 10.0:
	set(value):
		var textures := get_alternative_textures()
		for slot_textures in textures.values():
				for slot_texture in slot_textures:
					if slot_texture is AnimatedTexture:
						slot_texture.speed_scale = value
		alternative_texture_fps = value


func get_alternative_textures() -> Dictionary:
	# validating alternative textures in material metadata
	var textures: Variant = get_meta("alternative_textures", {})
	if textures == null or not textures is Dictionary:
		return {}
	var is_base_material := false
	var is_shader_material := false
	for slot in textures:
		if slot is int:
			if not (slot >= 0 and slot < BaseMaterial3D.TEXTURE_MAX):
				return {}
			is_base_material = true
		elif slot is String or slot is StringName:
			is_shader_material = true
		if not is_base_material and not is_shader_material:
			return {}
		if is_base_material and is_shader_material:
			return {}
		if typeof(textures[slot]) != TYPE_ARRAY:
			return {}
		for slot_texture in textures[slot]:
			if not slot_texture is Texture2D:
				return {}
	return textures
