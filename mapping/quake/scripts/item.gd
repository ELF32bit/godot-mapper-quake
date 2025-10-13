extends Area3D

@export var item_name: String = ""

@export_node_path("AudioStreamPlayer3D") var _pickup_sound_player: NodePath
@onready var pickup_sound_player: AudioStreamPlayer3D = get_node(_pickup_sound_player)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	print("Picked up %s" % item_name)
	if not pickup_sound_player:
		queue_free()
	if not pickup_sound_player.stream:
		queue_free()
	visible = false
	set_deferred("monitoring", false)
	pickup_sound_player.play()


func _on_pickup_sound_finished() -> void:
	if get_parent().name == "worldspawn":
		get_parent().get_parent().queue_free()
	else:
		queue_free()
