extends Area3D

@export var speed: float = 200.0 / 32.0
@export var height: float = 200.0 / 32.0

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	var forward_direction := -global_transform.basis.z.normalized()
	_monsterjump(body, forward_direction * speed, height)

@warning_ignore("shadowed_variable")
func _monsterjump(body: Node3D, velocity: Vector3, height: float) -> void:
	if body.has_method("quake_monsterjump"):
		body.call("quake_monsterjump", velocity, height)
