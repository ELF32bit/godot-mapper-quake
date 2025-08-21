extends Area3D

@export var push_speed: float = 1000 / 32.0
@export var push_once: bool = false


func _ready() -> void:
	set_physics_process(false)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# area must be monitoring to get overlapping bodies
	if not monitoring:
		set_physics_process(false)
		return
	# disabling physics processing for empty areas
	var overlapping_bodies := get_overlapping_bodies()
	if not overlapping_bodies.size():
		set_physics_process(false)
		if push_once: # disabling area forever
			set_deferred("monitoring", false)
		return
	# iterating over overlapping bodies and pushing them
	var forward_direction := -global_transform.basis.z.normalized()
	for overlapping_body in overlapping_bodies:
		_push(overlapping_body, forward_direction * push_speed)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	set_physics_process(true)

@warning_ignore("shadowed_variable")
func _push(body: Node3D, velocity: Vector3) -> void:
	if body.has_method("_quake_push"):
		body.call("_quake_push", velocity)
