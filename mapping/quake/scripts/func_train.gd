extends "classes/PhysicsCrushingBody3D.gd"

signal path_corner_reached(path_corner: Node3D)

const NODE_PATH_UTILITIES := preload("utilities/node_paths.gd")

@export var damage_interval: float = 0.25
@export var speed: float = 64.0 / 32.0

@export var is_waiting_for_signal := false
@export var _targets: Array[NodePath] = []
@onready var target: Node3D = null

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node(_wait_timer)

@export_node_path("AudioStreamPlayer3D") var _move_sound_player: NodePath
@onready var move_sound_player: AudioStreamPlayer3D = get_node(_move_sound_player)

@export_node_path("AudioStreamPlayer3D") var _stop_sound_player: NodePath
@onready var stop_sound_player: AudioStreamPlayer3D = get_node(_stop_sound_player)

var path_offset := Vector3.ZERO


func _ready() -> void:
	if is_waiting_for_signal:
		set_physics_process(false)
	else:
		_get_first_target()


func _get_first_target() -> void:
	target = NODE_PATH_UTILITIES.get_first_valid_node(self, _targets, "Node3D")
	if target:
		path_offset = global_position - target.global_position
		set_physics_process(true)
	else:
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	var is_moving := true
	if not is_instance_valid(target) or not target.is_inside_tree():
		is_moving = false
		move_sound_player.playing = false
		set_physics_process(false)
	elif global_position.is_equal_approx(target.global_position + path_offset):
		path_corner_reached.emit(target)
		move_sound_player.playing = false
		# getting the next target from path corner
		var next_target: Variant = target.get("target")
		if next_target != null and next_target is Node3D:
			target = next_target
		else:
			target = null
		# getting wait time from path corner
		var wait_time: Variant = target.get("wait_time")
		wait_time = wait_time if wait_time != null and wait_time is float else 0.0
		if wait_time != 0.0:
			is_moving = false
			stop_sound_player.playing = true
			set_physics_process(false)
			if wait_time > 0.0:
				wait_timer.start(clampf(wait_time, 0.05, INF))
	if is_moving:
		global_position = global_position.move_toward(target.global_position + path_offset, speed * delta)
	super(delta)

@warning_ignore("unused_parameter", "shadowed_variable")
func _on_crushing(object: Object, damage: int) -> void:
	global_position = last_global_position
	last_global_position = global_position
	move_sound_player.playing = false
	stop_sound_player.playing = true
	set_physics_process(false)
	# starting damage timer shount not interfere with path_corner wait timer
	wait_timer.start(clampf(damage_interval, 0.05, INF))

@warning_ignore("shadowed_variable")
func _on_crushing_object(object: Object, damage: int) -> void:
	if is_instance_valid(object) and object.has_method("crush"):
		object.call("crush", damage, self)
	_on_crushing(object, damage)

@warning_ignore("shadowed_variable")
func _on_crushing_character(character: CharacterBody3D, damage: int) -> void:
	if is_instance_valid(character) and character.has_method("crush"):
		character.call("crush", damage, self)
	_on_crushing(character, damage)


func _on_wait_timer_timeout() -> void:
	if is_instance_valid(target) and target.is_inside_tree():
		move_sound_player.playing = true
		set_physics_process(true)


func _on_generic_signal() -> void:
	is_waiting_for_signal = false
	_get_first_target()
