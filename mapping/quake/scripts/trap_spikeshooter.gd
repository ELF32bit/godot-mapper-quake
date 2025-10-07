extends Node3D

@export var projectile: PackedScene = null
@export var projectile_speed: float = 500.0 / 32.0
@export var projectile_radius: float = 0.15
@export var projectile_damage: int = 9

@export_flags_3d_physics var projectile_collision_layer: int = 1
@export_flags_3d_physics var projectile_collision_mask: int = 1


func _on_generic_signal() -> void:
	if projectile != null:
		_create_projectile()


func _create_projectile() -> void:
	var area := Area3D.new()
	area.collision_layer = projectile_collision_layer
	area.collision_mask = projectile_collision_mask
	area.monitorable = false
	add_child(area, false)

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

		child.global_position += -child.global_basis.z * projectile_speed * delta


func _hurt(body: Node3D, damage: int) -> void:
	if body.has_method("_quake_hurt"):
		body.call("_quake_hurt", damage)
