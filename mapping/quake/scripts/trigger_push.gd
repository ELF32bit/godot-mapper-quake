extends Area3D

@export var push_speed: float = 20.0
@export var push_once := false


func _ready() -> void:
	set_physics_process(false)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not monitoring:
		set_physics_process(false)
		return
	var overlapping_bodies := get_overlapping_bodies()
	if not overlapping_bodies.size():
		set_physics_process(false)
		if push_once:
			monitoring = false
		return
	var forward := -global_transform.basis.z.normalized()
	for overlapping_body in overlapping_bodies:
		if overlapping_body.has_method("push"):
			overlapping_body.call("push", forward * push_speed)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	set_physics_process(true)
