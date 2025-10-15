extends Node3D

signal opening # also generic signal for this entity
signal closing

@export_node_path("Area3D") var _area: NodePath
@onready var area: Area3D = get_node(_area)

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@export var gold_key_required := false # TODO: not implemented
@export var silver_key_required := false # TODO: not implemented
@export var toggle := false

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
	if toggle and animation_player.assigned_animation == "opened":
		animation_player.play("close")
		closing.emit()
	elif animation_player.assigned_animation == "closed":
		animation_player.play("open")
		opening.emit()
	elif animation_player.assigned_animation == "close":
		var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		animation_player.play("open")
		animation_player.seek(progress * animation_player.current_animation_length, true)
		opening.emit()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "open":
		# checking if timer exists and disabling area forever otherwise
		if is_instance_valid(wait_timer):
			set_physics_process(true)
		elif not toggle:
			area.monitoring = false
		animation_player.play("opened")
	elif animation_name == "close":
		animation_player.play("closed")
	# waiting for animation to finish before allowing to crush objects again
	has_crushed = false

@warning_ignore("unused_parameter")
func _on_crushing(object: Object, damage: int) -> void:
	if not has_crushed and (animation_player.assigned_animation == "open" or animation_player.assigned_animation == "close"):
		var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		animation_player.play("close" if animation_player.assigned_animation == "open" else "open")
		animation_player.seek(progress * animation_player.current_animation_length, true)
	# reversing animation if crushed object
	has_crushed = true


func _on_crushing_object(object: Object, damage: int) -> void:
	if not has_crushed:
		if is_instance_valid(object):
			_crush(object, damage)
	_on_crushing(object, damage)


func _on_crushing_character(character: CharacterBody3D, damage: int) -> void:
	if not has_crushed:
		if is_instance_valid(character):
			_crush(character, damage)
	_on_crushing(character, damage)


func _on_wait_timer_timeout() -> void:
	set_physics_process(false)
	animation_player.play("close")
	closing.emit()


func _on_generic_signal() -> void:
	_on_body_entered(null)

@warning_ignore("shadowed_variable")
func _crush(object: Object, damage: int) -> void:
	if object.has_method("_quake_crush"):
		object.call("_quake_crush", self, damage)
