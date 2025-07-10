@tool
extends Node3D

var rotation_speed: float = 2.5
var up_vector: Vector3 = Vector3.UP


func _ready() -> void:
	up_vector = global_basis.y.normalized()


func _physics_process(delta: float) -> void:
	global_rotate(up_vector, rotation_speed * delta)
