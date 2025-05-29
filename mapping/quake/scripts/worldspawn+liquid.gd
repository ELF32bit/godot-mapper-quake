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
			var swim_areas: Variant = body.get("swim_areas")
			if swim_areas != null and swim_areas is Dictionary:
				swim_areas[self] = liquid
	else:
		set_physics_process(false)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	set_physics_process(true)


func _on_body_exited(body: Node3D) -> void:
	var swim_areas: Variant = body.get("swim_areas")
	if swim_areas != null and swim_areas is Dictionary:
		swim_areas.erase(self)


func is_point_inside(point: Vector3) -> bool:
	if not planes.size():
		return false
	for plane in planes:
		if plane.is_point_over(point):
			if not is_zero_approx(plane.distance_to(point)):
				return false
	return true


func intersects_segment(from: Vector3, to: Vector3) -> Variant:
	var closest_point: Variant = null
	var closest_point_distance := INF
	for plane in planes:
		var point: Variant = plane.intersects_segment(from, to)
		if point != null:
			var distance := from.distance_squared_to(point)
			if distance < closest_point_distance:
				closest_point_distance = distance
				closest_point = point
	return closest_point
