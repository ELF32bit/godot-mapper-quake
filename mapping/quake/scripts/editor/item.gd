@tool
extends Node3D

@export var item_name: String = ""
@export var rotation_speed: float = 2.5


func _ready() -> void:
	match item_name:
		"item_armorInv": # red armor (200%)
			_set_skin(2)
		"item_armor2": # yellow armor (150%)
			_set_skin(1)
		"item_armor1": # green armor (100%)
			_set_skin(0)


func _set_skin(skin: int) -> void:
	var affected_materials: Array[Material] = []
	for mesh_instance in find_children("*", "MeshInstance3D", true, true):
		for surface_index in range(mesh_instance.get_surface_override_material_count()):
			var active_material: Material = mesh_instance.get_active_material(surface_index)
			if not active_material.has_meta("skins"):
				continue
			active_material = active_material.duplicate()
			mesh_instance.set_surface_override_material(surface_index, active_material)
			affected_materials.append(active_material)

	for material in affected_materials:
		if material is BaseMaterial3D:
			var skins: Array = material.get_meta("skins", [])
			material.albedo_texture = skins[skin]


func _physics_process(delta: float) -> void:
	global_rotate(Vector3.UP, rotation_speed * delta)
