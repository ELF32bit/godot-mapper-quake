extends Area3D

signal generic

@export var item_name: String = ""

@export_node_path("AudioStreamPlayer3D") var _pickup_sound_player: NodePath
@onready var pickup_sound_player: AudioStreamPlayer3D = get_node(_pickup_sound_player)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	generic.emit()
	print("Picked up %s" % item_name)
	if is_instance_valid(body):
		_register_item(body)
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


func _register_item(body: Node3D) -> void:
	match item_name:
		"item_key1": # used by func_door
			body.set_meta("has_silver_key", true)
		"item_key2": # used by func_door
			body.set_meta("has_gold_key", true)
