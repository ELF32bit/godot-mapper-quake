@tool
extends Node3D

@export var classname: String = ""
@export var rotation_speed: float = 2.5
@export_range(0, 15) var skin: int = 0:
	set(value):
		_set_skin(value)
		skin = value

var _skin_materials: Array[Material] = []


func _ready() -> void:
	_create_unique_skin_materials()
	_set_skin(skin)


func _create_unique_skin_materials() -> void:
	for mesh_instance in find_children("*", "MeshInstance3D", true, true):
		for surface_index in range(mesh_instance.get_surface_override_material_count()):
			var active_material: Material = mesh_instance.get_active_material(surface_index)
			if not active_material.has_meta("skins"):
				continue
			active_material = active_material.duplicate()
			mesh_instance.set_surface_override_material(surface_index, active_material)
			_skin_materials.append(active_material)

@warning_ignore("shadowed_variable")
func _set_skin(skin: int) -> void:
	for material in _skin_materials:
		var skins: Array = material.get_meta("skins", [])
		if not (skin >= 0 and skin < skins.size()):
			continue
		if material is BaseMaterial3D:
			material.albedo_texture = skins[skin]
		elif material is ShaderMaterial:
			material.set_shader_parameter("albedo_texture", skins[skin])


func _physics_process(delta: float) -> void:
	global_rotate(Vector3.UP, rotation_speed * delta)
