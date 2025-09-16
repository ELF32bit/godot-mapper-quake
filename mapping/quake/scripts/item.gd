extends Node3D

@export var item_name: String = ""


func _on_body_entered(body: Node3D) -> void:
	queue_free()
