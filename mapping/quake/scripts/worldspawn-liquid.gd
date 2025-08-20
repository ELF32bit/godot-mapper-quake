extends Area3D

@export var liquid: int = 0
@export var planes: Array[Plane] = []

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# area must be monitoring to get overlapping bodies
	if not monitoring:
		set_physics_process(false)
		return
	# iterating over overlapping bodies and submerging them
	var overlapping_bodies := get_overlapping_bodies()
	if overlapping_bodies.size():
		for overlapping_body in overlapping_bodies:
			_submerge(overlapping_body, liquid)
	else:
		set_physics_process(false)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	set_physics_process(true)


func _on_body_exited(body: Node3D) -> void:
	_submerge(body, 0)


func is_point_inside(point: Vector3) -> bool:
	if not planes.size():
		return false
	for plane in planes:
		if plane.is_point_over(point):
			if not is_zero_approx(plane.distance_to(point)):
				return false
	return true

@warning_ignore("shadowed_variable")
func _submerge(body: Node3D, liquid: int) -> void:
	if body.has_method("quake_submerge"):
		body.call("quake_submerge", self, liquid)
