extends Node3D

@export var projectile: PackedScene = null
@export var projectile_speed: float = 40.0 / 32.0
@export var projectile_radius: float = 0.25
@export var projectile_damage: int = 20

@export_flags_3d_physics var projectile_collision_layer: int = 1
@export_flags_3d_physics var projectile_collision_mask: int = 1


func _on_wait_timer_timeout() -> void:
	if projectile != null:
		_create_projectile()


func _create_projectile() -> void:
	var area := Area3D.new()
	area.collision_layer = projectile_collision_layer
	area.collision_mask = projectile_collision_mask
	area.monitorable = false
	add_child(area, false)

	var velocity := Vector3(0.0, projectile_speed, 0.0)
	velocity.x += (randf() - 0.5) * 100.0 / 32.0
	velocity.z += (randf() - 0.5) * 100.0 / 32.0
	velocity.y += randf() * 200.0 / 32.0
	area.set_meta("velocity", velocity)

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = projectile_radius
	area.add_child(collision_shape, false)

	var projectile_instance := projectile.instantiate()
	area.add_child(projectile_instance, false)


func _physics_process(delta: float) -> void:
	for child in find_children("*", "Area3D", false, false):
		var overlapping_bodies = child.get_overlapping_bodies()
		for body in overlapping_bodies:
			_hurt(body, projectile_damage)

		if overlapping_bodies.size():
			child.queue_free()
		elif global_position.distance_to(child.global_position) > 256.0:
			child.queue_free()

		var velocity: Vector3 = child.get_meta("velocity", Vector3.ZERO)
		child.global_position += velocity * delta
		velocity.y -= 32.0 * delta
		child.set_meta("velocity", velocity)


func _hurt(body: Node3D, damage: int) -> void:
	if body.has_method("_quake_hurt"):
		body.call("_quake_hurt", damage)
