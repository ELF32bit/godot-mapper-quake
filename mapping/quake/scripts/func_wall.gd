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

@export var alternative_texture_fps: float = 10.0:
	set(value):
		for affected_material in affected_materials:
			if affected_material:
				affected_material.set("alternative_texture_fps", value)
		alternative_texture_fps = value

@export var alternative_textures: int = 0
@export var affected_materials: Array[Material] = []


func _ready() -> void:
	alternative_texture_fps = alternative_texture_fps
	alternative_texture = alternative_texture


func _on_generic_signal() -> void:
	alternative_texture += 1
