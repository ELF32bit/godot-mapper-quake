extends "classes/targets.gd" # Area3D

const PUSH_SPEED: float = 15.0

@export var player_only: bool = false
@export var teleport_sounds: Array[AudioStream] = []

@export_node_path("AudioStreamPlayer3D") var _teleport_sound_player: NodePath
@onready var teleport_sound_player: AudioStreamPlayer3D = get_node(_teleport_sound_player)


func _on_body_entered(body: Node3D) -> void:
	if player_only: # checking if player entered
		if not body is CharacterBody3D:
			return
	# obtaining the first info_teleport_destination
	var target: Node3D = get_first_target_node("Node3D")
	if not target:
		return
	# teleporting body to the target and playing sounds
	var target_forward_direction := -target.global_transform.basis.z
	_teleport(body, target.global_position, target_forward_direction)
	_push(body, target_forward_direction * PUSH_SPEED)
	_play_sounds(target)


func _teleport(body: Node3D, target_position: Vector3, target_forward_direction: Vector3) -> void:
	body.global_position = target_position + Vector3.UP * 2.0
	var forward_direction := -body.global_transform.basis.z.normalized()
	if forward_direction.is_equal_approx(-target_forward_direction):
		var up_direction := body.global_transform.basis.y.normalized()
		body.quaternion = Quaternion(up_direction, PI)
	else:
		var forward_rotation := Quaternion(forward_direction, target_forward_direction)
		body.quaternion = forward_rotation * body.quaternion
	body.rotation = Vector3(0.0, body.rotation.y, 0.0)


func _play_sounds(target: Node3D) -> void:
	if not teleport_sounds.size():
		return
	# duplicating teleport sound player at target
	var target_sound_player := teleport_sound_player.duplicate()
	target_sound_player.finished.connect(target_sound_player.queue_free)
	target.add_child(target_sound_player, false)
	# rolling random audio streams for both sound players
	teleport_sound_player.stream = teleport_sounds[randi() % teleport_sounds.size()]
	target_sound_player.stream = teleport_sounds[randi() % teleport_sounds.size()]
	# playing trigger sounds
	teleport_sound_player.play()
	target_sound_player.play()


func _on_generic_signal() -> void:
	set_deferred("monitoring", true)


func _push(body: Node3D, velocity: Vector3) -> void:
	if body.has_method("_quake_push"):
		body.call("_quake_push", velocity)
