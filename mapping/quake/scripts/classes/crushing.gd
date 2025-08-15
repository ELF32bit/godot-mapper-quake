extends PhysicsBody3D

signal crushing_character(character: CharacterBody3D, damage: int)
signal crushing_object(object: Object, damage: int) # other than character

@export var damage: int = 0

@onready var last_global_position: Vector3 = global_position


func _physics_process(_delta: float) -> void:
	# obtaining current move direction
	if global_position.is_equal_approx(last_global_position):
		return
	var move_direction := (global_position - last_global_position).normalized()
	if move_direction == Vector3.ZERO:
		last_global_position = global_position
		return

	# only single nearest collider is reliably returned by this method
	# increasing max_collisions does not return more unique colliders
	# consider putting crushable objects on a separate sparse physics layer
	# only 1 object is crushed per frame, other objects will not be reported
	# many objects require many frames to be reported, consider slowing the body
	# collisions between two concave shapes will not be reported
	var collision := move_and_collide(Vector3.ZERO, true, 0.001, true, 1)
	if not collision:
		last_global_position = global_position
		return

	for collision_index in range(collision.get_collision_count()):
		var collider := collision.get_collider(collision_index)
		if collider is CharacterBody3D: # crushing characters based on slide collisions
			for slide_index in range(collider.get_slide_collision_count()):
				var slide_collision = collider.get_slide_collision(slide_index)
				# only processing slide collisions with other nearby colliders
				if slide_collision.get_collider() != self:
					# crush angle is higher than 60 degrees
					if slide_collision.get_normal().dot(move_direction) < -0.9:
						crushing_character.emit(collider, damage)
		else: # crushing objects (not reliable for characters)
			if collision.get_normal(collision_index).dot(move_direction) < -0.9:
				crushing_object.emit(collider, damage)

	# updating last global position after firing signals
	last_global_position = global_position
