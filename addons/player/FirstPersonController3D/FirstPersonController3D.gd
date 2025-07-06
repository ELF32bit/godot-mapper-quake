extends "FirstPersonControllerInput3D.gd"

enum MovementMode {GROUNDED, SWIMMING, FLYING}

@export var camera_orbit_limits := Vector2(-89.0, 89.0)
@export var camera_position_interpolation: float = 35.0
@export var camera_fov_interpolation: float = 8.0

var movement_mode: MovementMode = MovementMode.GROUNDED:
	set(value):
		match value:
			MovementMode.GROUNDED:
				floor_block_on_wall = true
				if not swim_enabled:
					collision_mask |= swim_blocking_layers
				else:
					collision_mask &= ~swim_blocking_layers
				if movement_mode == MovementMode.SWIMMING:
					# jumping out of swim area near walls
					if is_on_wall_only() and is_jumping_input:
						jump(true)
			MovementMode.SWIMMING:
				floor_block_on_wall = false
				# still allowing swimming if swimming is disabled
				collision_mask &= ~swim_blocking_layers
				if movement_mode == MovementMode.GROUNDED:
					# slightly pushing player in the swim area
					if not is_on_floor():
						push(Vector3.DOWN * sqrt(2 * gravity))
			MovementMode.FLYING:
				# entering fly mode only from ground mode
				if movement_mode != MovementMode.GROUNDED:
					return
				floor_block_on_wall = false
				collision_mask |= swim_blocking_layers
		movement_mode = value
var direction: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO

@export var walk_speed: float = 10.0
@export var swim_speed: float = 6.0
@export var fly_speed: float = 16.0

@export var swim_enabled := true:
	set(value):
		# nothing happens if currently swimming
		if movement_mode == MovementMode.GROUNDED:
			if not value:
				collision_mask |= swim_blocking_layers
			else:
				collision_mask &= ~swim_blocking_layers
		swim_enabled = value
@export var drowning_speed: float = 0.5
@export var drowning_angle: float = 45.0

var swim_area: int = 0
var camera_swim_area: int = 0
var spring_arm_camera_swim_area: int = 0
var swim_areas: Dictionary
## bodies that block player from entering swim areas while flying
@export_flags_3d_physics var swim_blocking_layers: int = 0
var swim_push_distance: float:
	get:
		# distance between character center and head with some offset
		var distance := (spring_arm.global_position - global_position).length()
		return distance + spring_arm.shape.radius / 2.0
var is_drowning: bool = false

@export var sprint_enabled: bool = true
@export var sprint_speed: float = 16.0
@export var swim_sprint_enabled: bool = true
@export var swim_sprint_speed: float = 10.0
@export var fly_sprint_enabled: bool = false
@export var fly_sprint_speed: float = 20.0

var can_sprint: bool:
	get:
		if move_axis_input.y > 0.0:
			match movement_mode:
				MovementMode.GROUNDED:
					return sprint_enabled and is_on_floor()
				MovementMode.SWIMMING:
					return swim_sprint_enabled
				MovementMode.FLYING:
					return fly_sprint_enabled
		return false

var is_sprinting: bool:
	get:
		return (is_sprinting_input and can_sprint)

@export var jump_enabled: bool = true
@export var double_jump: bool = false
@export var jump_height: float = 2.0
@export var jump_on_stairs: bool = true

var jumps_left: int = 1 + int(double_jump)
var can_jump: bool:
	get:
		if movement_mode == MovementMode.GROUNDED:
			# allowing player to jump under ceiling to slide against it
			return jump_enabled and is_on_floor() or jumps_left > 0
		return false

@export var gravity: float = 30.0
@export var air_control: float = 0.3
@export var acceleration: float = 8.0
@export var deceleration: float = 10.0

@onready var shape: CollisionShape3D = $"CollisionShape3D"
@onready var spring_arm_gimbal: Node3D = $"SpringArm3D"
@onready var spring_arm: SpringArm3D = $"SpringArm3D/SpringArm3D"
@onready var spring_arm_camera: Node3D = $"SpringArm3D/SpringArm3D/Camera3D"
@onready var camera: Camera3D = $"Camera3D"
@onready var _camera_fov: float = camera.fov
@onready var _floor_snap_length: float = floor_snap_length


func _process(delta: float) -> void:
	if camera_position_interpolation > 0.0:
		var weight := clampf(camera_position_interpolation * delta, 0.0, 1.0)
		camera.global_position = camera.global_position.lerp(spring_arm_camera.global_position, weight)
		camera.quaternion = camera.quaternion.slerp(quaternion * spring_arm_gimbal.quaternion * spring_arm.quaternion, weight)
		# for extra visual precision calculating interpolated camera swim area
		camera_swim_area = get_swim_area_at(camera.global_position)
	# interpolating camera fov if sprinting
	camera.fov = lerpf(camera.fov, _camera_fov * (1 + 0.15 * int(is_sprinting)), camera_fov_interpolation * delta)


func _physics_process(delta: float) -> void:
	super(delta) # polling player input
	# rotating character and camera and consuming input events
	var relative_motion := Vector2.ZERO
	relative_motion = -mouse_motion_relative * lerpf(0.0, MOUSE_SENSITIVITY, mouse_sensitivity)
	relative_motion += -joypad_axis_input * lerpf(0.0, JOYPAD_SENSITIVITY, joypad_sensitivity)
	rotate_y(relative_motion.x * delta)
	spring_arm.rotate_x(relative_motion.y * delta)
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, deg_to_rad(camera_orbit_limits.x), deg_to_rad(camera_orbit_limits.y))
	mouse_motion_relative = Vector2.ZERO

	# changing movement mode if inside swim area
	swim_area = get_swim_area_at(global_position)
	# adding small offset to spring arm camera global position to avoid some precision issues
	spring_arm_camera_swim_area = get_swim_area_at(spring_arm_camera.global_position + Vector3.DOWN * 0.02)
	if swim_area != 0 and movement_mode != MovementMode.SWIMMING:
		movement_mode = MovementMode.SWIMMING
	elif swim_area == 0 and movement_mode == MovementMode.SWIMMING:
		movement_mode = MovementMode.GROUNDED

	# setting camera transform in physics process if interpolation is disabled
	if not camera_position_interpolation > 0.0:
		camera.global_position = spring_arm_camera.global_position
		camera.quaternion = quaternion * spring_arm_gimbal.quaternion * spring_arm.quaternion
		camera_swim_area = spring_arm_camera_swim_area

	# checking if drowning on a current frame
	match movement_mode:
		MovementMode.GROUNDED, MovementMode.FLYING:
			is_drowning = false
		MovementMode.SWIMMING:
			# pushing player in or out of the swim area depending on camera angle
			var forward := -spring_arm_camera.global_transform.basis.z.normalized()
			var projection := (forward * Vector3(1.0, 0.0, 1.0)).normalized()
			var current_frame_is_drowning = true
			if spring_arm_camera_swim_area == 0:
				current_frame_is_drowning = false
				if is_drowning and not is_on_floor() and not is_on_ceiling():
					var collision := move_and_collide(Vector3.UP * swim_push_distance, true)
					if not (collision and collision.get_travel().length() < swim_push_distance):
						move_and_collide(Vector3.UP * swim_push_distance)
				if (move_axis_input.y != 0.0) and projection.angle_to(forward) > deg_to_rad(drowning_angle):
					if signf((forward * move_axis_input.y).y) < 0.0:
						if not is_on_floor():
							var collision := move_and_collide(Vector3.DOWN * swim_push_distance, true)
							if not (collision and collision.get_travel().length() < swim_push_distance):
								move_and_collide(Vector3.DOWN * swim_push_distance)
								current_frame_is_drowning = true
			is_drowning = current_frame_is_drowning

	# getting player direction
	direction = Vector3.ZERO
	match movement_mode:
		MovementMode.GROUNDED:
			direction = global_transform.basis.x * move_axis_input.x
			direction -= global_transform.basis.z * move_axis_input.y
		MovementMode.SWIMMING:
			# using player direction if camera is above swim area surface
			if not is_drowning:
				direction = global_transform.basis.x * move_axis_input.x
				direction -= global_transform.basis.z * move_axis_input.y
			else:
				direction = spring_arm_camera.global_transform.basis.x * move_axis_input.x
				direction -= spring_arm_camera.global_transform.basis.z * move_axis_input.y
			# using player direction if player is swimming into floor
			if is_on_floor():
				if get_floor_normal().dot(direction.normalized()) < 0.0:
					direction = global_transform.basis.x * move_axis_input.x
					direction -= global_transform.basis.z * move_axis_input.y
		MovementMode.FLYING:
			direction = spring_arm_camera.global_transform.basis.x * move_axis_input.x
			direction -= spring_arm_camera.global_transform.basis.z * move_axis_input.y
	direction = direction.normalized()

	# setting player velocity
	target_velocity = Vector3.ZERO
	match movement_mode:
		MovementMode.GROUNDED:
			target_velocity.x = direction.x * (sprint_speed if is_sprinting else walk_speed)
			target_velocity.z = direction.z * (sprint_speed if is_sprinting else walk_speed)
		MovementMode.SWIMMING:
			target_velocity = direction * (swim_sprint_speed if is_sprinting else swim_speed)
		MovementMode.FLYING:
			target_velocity = direction * (fly_sprint_speed if is_sprinting else fly_speed)

	# applying gravity if player not on floor
	if not is_on_floor():
		match movement_mode:
			MovementMode.GROUNDED:
				# gravity should not be interpolated
				velocity.y -= gravity * delta
				target_velocity.y = velocity.y
			MovementMode.SWIMMING:
				# applying constant drowning velocity
				target_velocity.y -= drowning_speed
			MovementMode.FLYING:
				pass

	# keeping player above swim area surface and also disabling floor snap
	if movement_mode == MovementMode.SWIMMING and not is_drowning:
		if spring_arm_camera_swim_area == 0 and not is_jumping_input:
			target_velocity.y = 0
			velocity.y = 0.0
		floor_snap_length = 0.0
	elif floor_snap_length != _floor_snap_length:
		floor_snap_length = _floor_snap_length

	# clearing accumulated vertical speed and resetting jump
	if is_on_floor() and movement_mode == MovementMode.GROUNDED:
		jumps_left = 1 + int(double_jump)
		target_velocity.y = 0.0
		velocity.y = 0.0

	# jumping over stairs before jumping
	if jump_on_stairs and movement_mode == MovementMode.GROUNDED:
		# also disabling stair jumps when player is under ceiling
		if is_on_floor() and is_on_wall() and not is_on_ceiling():
			var collision := get_last_slide_collision()
			if collision:
				var g_scale := global_transform.basis.get_scale()
				var shape_height: float = shape.shape.height * g_scale.y
				var shape_max_step_height: float = shape.shape.radius * maxf(g_scale.x, g_scale.z)
				var stair_margin := shape_max_step_height * 0.02
				var stair_height: float = -INF

				# finding highest stair in the direction of a player
				for collision_index in range(collision.get_collision_count()):
					var collision_position := collision.get_position(collision_index)
					var collision_direction := collision_position - global_position
					var collision_height := collision_direction.y + shape_height / 2.0
					var stair_direction := (collision_direction * Vector3(1.0, 0.0, 1.0))
					# discarding collisions unrelated to player movement direction
					if direction.dot(stair_direction.normalized()) <= 0.0:
						continue
					if collision_height > stair_margin:
						if collision_height < shape_max_step_height - stair_margin:
							stair_height = maxf(collision_height, stair_height)
				# jumping over highest stair
				if not is_inf(stair_height):
					jump(true, stair_height + stair_margin)

	# jumping logic
	match movement_mode:
		MovementMode.GROUNDED:
			if has_jumped_input:
				jump()
		MovementMode.SWIMMING:
			if is_jumping_input:
				# not accurate, but gives input response
				target_velocity.y = swim_speed
		MovementMode.FLYING:
			if is_jumping_input:
				# not accurate, but gives input response
				target_velocity.y = fly_speed

	# deciding if player should accelerate or decelerate
	var weight := acceleration if direction.dot(velocity) > 0.0 else deceleration
	# applying air control if player is grounded and not on floor
	if movement_mode == MovementMode.GROUNDED:
		if not is_on_floor():
			weight *= air_control
	# interpolating real velocity to target velocity
	velocity = velocity.lerp(target_velocity, weight * delta)
	# clearing interpolation jitter
	if direction.dot(velocity) == 0:
		velocity.x *= int(absf(velocity.x) >= 0.01)
		velocity.y *= int(absf(velocity.y) >= 0.01)
		velocity.z *= int(absf(velocity.z) >= 0.01)
	# applying character movement
	move_and_slide()


func get_swim_area_at(point: Vector3) -> int:
	var current_swim_area: int = 0
	if not swim_areas.size():
		return current_swim_area
	var invalid_areas: Array[Variant] = []
	const SWIM_AREA_METHOD := "is_point_inside"
	for swim_area_node in swim_areas:
		if is_instance_valid(swim_area_node) and swim_area_node.has_method(SWIM_AREA_METHOD):
			if bool(swim_area_node.call(SWIM_AREA_METHOD, point)):
				current_swim_area = swim_areas[swim_area_node]
				break
		else:
			invalid_areas.append(swim_area_node)
	# erasing deleted areas from dictionary
	for invalid_area in invalid_areas:
		swim_areas.erase(invalid_area)
	return current_swim_area


func jump(force: bool = false, height: float = jump_height) -> void:
	# removing ability to make initial jump on falls
	if not is_on_floor():
		jumps_left = clampi(jumps_left, 0, int(double_jump))
	if can_jump or force:
		# jump velocity should not be interpolated
		velocity.y = sqrt(2 * gravity * height)
		target_velocity.y = velocity.y
		# not counting force jumps
		if not force:
			jumps_left -= 1

@warning_ignore("shadowed_variable_base_class")
func push(velocity: Vector3) -> void:
	self.velocity = velocity
	target_velocity = velocity
