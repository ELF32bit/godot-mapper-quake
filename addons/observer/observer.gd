extends CharacterBody3D

@export var radius: float = 0.5:
	set(value):
		radius = clampf(value, 0.05, 5.0)
		mesh_instance.mesh.radius = radius
		mesh_instance.mesh.height = 2.0 * radius
		collision_shape.shape.radius = radius

@export var speed_normal: float = 10.0
@export var speed_fast: float = 16.0
@export var speed_slow: float = 6.0
@export var speed_teleport: float = 30.0
@export var orbit_limit_min := deg_to_rad(-89.0)
@export var orbit_limit_max := deg_to_rad(89.0)
@export_flags_3d_physics var spring_arm_collision_mask: int = 1

@onready var input: Node = $"Input"
@onready var camera: Camera3D = $"Camera3D"
@onready var mesh_instance: MeshInstance3D = $"MeshInstance3D"
@onready var collision_shape: CollisionShape3D = $"CollisionShape3D"
@onready var spring_arm: SpringArm3D = $"SpringArm3D"
@onready var ray_cast: RayCast3D = $"RayCast3D"

var _push_velocity := Vector3.ZERO


func _ready() -> void:
	spring_arm.add_excluded_object(get_rid())


func _physics_process(delta: float) -> void:
	var free_look: Vector2 = input.get_free_look()
	var scroll_number: int = input.get_scroll_number()

	if input.is_modifier_pressed:
		if input.is_reset_pressed:
			radius = 0.5
		else:
			radius += scroll_number * 0.15
	else:
		spring_arm.spring_length -= scroll_number * 0.15
		spring_arm.spring_length = clampf(spring_arm.spring_length, 0.0, 10.0)
	spring_arm.collision_mask = spring_arm_collision_mask * int(not input.is_noclip_pressed)

	if input.is_orbit_pressed:
		_apply_free_look(spring_arm, free_look, delta)
	else:
		var target_orbit := Quaternion.from_euler(Vector3.ZERO)
		spring_arm.quaternion = spring_arm.quaternion.slerp(target_orbit, delta * 8.0)
		_apply_free_look(self, free_look, delta)

	var camera_up := camera.global_transform.basis.y.normalized()
	var camera_forward := -camera.global_transform.basis.z.normalized()
	var camera_right := camera.global_transform.basis.x.normalized()

	velocity = Vector3.ZERO
	velocity += camera_right * input.move_vector.x
	velocity += camera_forward * input.move_vector.y
	velocity = velocity.normalized()

	if input.is_up_pressed:
		velocity.y += 1.0
	elif input.is_down_pressed:
		velocity.y -= 1.0
	elif input.is_local_up_pressed:
		velocity += camera_up
	elif input.is_local_down_pressed:
		velocity -= camera_up

	if input.is_fast_pressed:
		velocity *= speed_fast
	elif input.is_slow_pressed:
		velocity *= speed_slow
	else:
		velocity *= speed_normal

	if input.is_teleport_pressed:
		var direction := camera.global_position + camera_forward * camera.far
		ray_cast.target_position = ray_cast.to_local(direction)
		ray_cast.force_raycast_update()
		if input.is_modifier_pressed and ray_cast.is_colliding():
			var teleport_position := ray_cast.get_collision_point()
			var teleport_direction := teleport_position - global_position
			if teleport_direction.length_squared() > radius * radius:
				velocity += teleport_direction.normalized() * speed_teleport
		elif ray_cast.is_colliding():
			var teleport_object := ray_cast.get_collider()
			if "quake_health" in teleport_object:
				teleport_object.quake_health -= 1
		ray_cast.target_position = Vector3.ZERO

	if input.is_noclip_pressed:
		if not collision_shape.disabled:
			collision_shape.disabled = true
	elif collision_shape.disabled:
		collision_shape.disabled = false

	velocity += _push_velocity
	_push_velocity = Vector3.ZERO
	move_and_slide()


func _apply_free_look(node: Node3D, free_look: Vector2, delta: float) -> void:
	node.rotation.x += free_look.y * delta
	node.rotation.x = clampf(node.rotation.x, orbit_limit_min, orbit_limit_max)
	node.rotate_y(free_look.x * delta)


func _set_distortion_effect(liquid: int) -> void:
	var distortion: ColorRect = $"ScreenEffects/Distortion"
	match liquid:
		1:
			distortion.material.set_shader_parameter("tint", Color.LIGHT_SKY_BLUE)
			distortion.visible = true
		2:
			distortion.material.set_shader_parameter("tint", Color.DARK_ORANGE)
			distortion.visible = true
		3:
			distortion.material.set_shader_parameter("tint", Color.TAN)
			distortion.visible = true
		_:
			distortion.visible = false


func _quake_submerge(area: Area3D, liquid: int) -> void:
	if area.is_point_inside(global_position):
		_set_distortion_effect(liquid)
	else:
		_set_distortion_effect(0)


func _quake_push(push_velocity: Vector3) -> void:
	_push_velocity = push_velocity * 10.0


func _quake_hurt(damage: int) -> void:
	print("Received %s damage" % damage)
