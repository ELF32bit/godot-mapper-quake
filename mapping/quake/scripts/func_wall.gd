@tool
extends Node

@export var alternative_texture: int = 0:
	set(value):
		if alternative_textures <= 0:
			alternative_texture = -1
			return
		for affected_material in affected_materials:
			if affected_material:
				affected_material.set("alternative_texture", value)
		alternative_texture = clampi(value, 0, alternative_textures - 1)

@export_range(-60.0, 60.0) var alternative_speed_scale: float = 1.0:
	set(value):
		for affected_material in affected_materials:
			if affected_material:
				affected_material.set("alternative_speed_scale", value)
		alternative_speed_scale = value

@export var alternative_textures: int = 0
@export var affected_materials: Array[Material] = []


func _ready() -> void:
	alternative_texture = alternative_texture
	alternative_speed_scale = alternative_speed_scale


func _on_generic_signal() -> void:
	alternative_texture += 1
