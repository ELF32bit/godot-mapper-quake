extends Area3D

@export var liquid: int = 0
@export var planes: Array[Plane] = []

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not monitoring:
		set_physics_process(false)
		return
	# area must be monitoring to get overlapping bodies
	var overlapping_bodies: Array[Node3D] = get_overlapping_bodies()
	if overlapping_bodies.size():
		for body in overlapping_bodies:
			if is_point_inside(body.global_position):
				if body.has_method("set_distortion_effect"):
					body.call("set_distortion_effect", liquid)
			elif body.has_method("set_distortion_effect"):
				body.call("set_distortion_effect", 0)
	else:
		set_physics_process(false)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	set_physics_process(true)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("set_distortion_effect"):
		body.call("set_distortion_effect", 0)


func is_point_inside(point: Vector3) -> bool:
	if not planes.size():
		return false
	for plane in planes:
		if plane.is_point_over(point):
			if not is_zero_approx(plane.distance_to(point)):
				return false
	return true
