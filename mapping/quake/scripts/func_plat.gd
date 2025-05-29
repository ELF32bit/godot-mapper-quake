extends Node3D

@export_node_path("Area3D") var _area: NodePath
@onready var area: Area3D = get_node(_area)

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

var has_crushed := false


func _ready() -> void:
	set_physics_process(false)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if area.monitoring and area.get_overlapping_bodies().size():
		wait_timer.start()
	elif wait_timer.is_stopped():
		wait_timer.start()
	if not area.monitoring:
		set_physics_process(false)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	if animation_player.assigned_animation == "retracted":
		animation_player.play("extend")
	elif animation_player.assigned_animation == "retract":
		var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		animation_player.play("extend")
		animation_player.seek(progress * animation_player.current_animation_length, true)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "extend":
		# checking if wait_timer exists and disabling area forever otherwise
		if is_instance_valid(wait_timer):
			set_physics_process(true)
		else:
			area.monitoring = false
		animation_player.play("extended")
	elif animation_name == "retract":
		animation_player.play("retracted")
	# waiting for animation to finish before allowing to crush objects again
	has_crushed = false

@warning_ignore("unused_parameter")
func _on_crushing(object: Object, damage: int) -> void:
	if not has_crushed and (animation_player.assigned_animation == "extend" or animation_player.assigned_animation == "retract"):
		var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		animation_player.play("retract" if animation_player.assigned_animation == "extend" else "extend")
		animation_player.seek(progress * animation_player.current_animation_length, true)
	# reversing animation if crushed object
	has_crushed = true


func _on_crushing_object(object: Object, damage: int) -> void:
	if not has_crushed:
		if is_instance_valid(object) and object.has_method("crush"):
			object.call("crush", damage, self)
	_on_crushing(object, damage)


func _on_crushing_character(character: CharacterBody3D, damage: int) -> void:
	if not has_crushed:
		if is_instance_valid(character) and character.has_method("crush"):
			character.call("crush", damage, self)
	_on_crushing(character, damage)


func _on_wait_timer_timeout() -> void:
	set_physics_process(false)
	animation_player.play("retract")


func _on_generic_signal() -> void:
	if not area.monitoring:
		if animation_player.assigned_animation == "extended":
			animation_player.play("retract")
			area.monitoring = true
