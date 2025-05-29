extends Node3D

signal generic

@export var delay_time: float = 0.0
@export var message: String = ""

@export_node_path("Area3D") var _area: NodePath
@onready var area: Area3D = get_node(_area)

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@export_node_path("AnimatableBody3D") var _animatable_body: NodePath
@onready var animatable_body: AnimatableBody3D = get_node(_animatable_body)

@export_node_path("AudioStreamPlayer3D") var _press_sound_player: NodePath
@onready var press_sound_player: AudioStreamPlayer3D = get_node(_press_sound_player)


func _ready() -> void:
	set_physics_process(false)
	# making sure area is disabled if button has health
	if "health" in animatable_body and area.monitoring:
		area.monitoring = false

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not area.monitoring:
		set_physics_process(false)
		return
	# area must be monitoring to get overlapping bodies
	var overlapping_bodies := area.get_overlapping_bodies()
	if not overlapping_bodies.size():
		set_physics_process(false)
		return

	var has_character_slided := false
	for overlapping_body in overlapping_bodies:
		if not overlapping_body is CharacterBody3D:
			continue
		for slide_collision_index in overlapping_body.get_slide_collision_count():
			var slide_collision: KinematicCollision3D = overlapping_body.get_slide_collision(slide_collision_index)
			var slide_collision_collider := slide_collision.get_collider()
			if slide_collision_collider == animatable_body:
				has_character_slided = true
				break
		if has_character_slided:
			break

	if has_character_slided:
		if animation_player.assigned_animation == "release":
			var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
			animation_player.play("press")
			animation_player.seek(progress * animation_player.current_animation_length, true)
		elif animation_player.assigned_animation == "released":
			animation_player.play("press")
		press_sound_player.play()
		set_physics_process(false)
		area.monitoring = false


func _on_health_ended() -> void:
	if animation_player.assigned_animation == "release":
		var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		animation_player.play("press")
		animation_player.seek(progress * animation_player.current_animation_length, true)
		press_sound_player.play()
	elif animation_player.assigned_animation == "released":
		animation_player.play("press")
		press_sound_player.play()

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	match animation_player.assigned_animation:
		"release", "released":
			set_physics_process(true)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "press":
		if is_instance_valid(wait_timer):
			wait_timer.start()
		# creating possibly multiple delay timers at runtime
		if not delay_time < 0.0:
			var delay_timer := Timer.new()
			delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
			delay_timer.timeout.connect(_on_delay_timer_timeout)
			delay_timer.timeout.connect(delay_timer.queue_free)
			delay_timer.wait_time = clampf(delay_time, 0.05, INF)
			delay_timer.one_shot = true
			add_child(delay_timer, false)
			delay_timer.start()
		# finishing press animation
		animation_player.play("pressed")
	elif animation_name == "release":
		animation_player.play("released")


func _on_wait_timer_timeout() -> void:
	animation_player.play("release")
	# resetting button health or re-enabling area
	if "health" in animatable_body:
		if "max_health" in animatable_body:
			animatable_body.health = animatable_body.max_health
	else:
		area.monitoring = true


func _on_delay_timer_timeout() -> void:
	generic.emit()
