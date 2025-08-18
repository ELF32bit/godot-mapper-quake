extends "classes/targets.gd" # Area3D

@export var push_speed: float = 15.0
@export var teleport_sounds: Array[AudioStream]

@export_node_path("AudioStreamPlayer3D") var _teleport_sound_player: NodePath
@onready var teleport_sound_player: AudioStreamPlayer3D = get_node(_teleport_sound_player)


func _on_body_entered(body: Node3D) -> void:
	var target: Node3D = get_first_target_node("Node3D")
	if target:
		body.global_position = target.global_position + Vector3.UP * 2.0
		var body_forward := -body.global_transform.basis.z.normalized()
		var target_forward := -target.global_transform.basis.z
		body.quaternion = Quaternion(body_forward, target_forward) * body.quaternion
		body.rotation = Vector3(0.0, body.rotation.y, 0.0)

		if teleport_sounds.size():
			var target_teleport_sound_player := teleport_sound_player.duplicate()
			target_teleport_sound_player.finished.connect(target_teleport_sound_player.queue_free)
			target.add_child(target_teleport_sound_player, false)

			teleport_sound_player.stream = teleport_sounds[randi() % teleport_sounds.size()]
			teleport_sound_player.play()

			target_teleport_sound_player.stream = teleport_sounds[randi() % teleport_sounds.size()]
			target_teleport_sound_player.play()

		if body.has_method("push"):
			body.call("push", target_forward * push_speed)


func _on_generic_signal() -> void:
	self.monitoring = true
