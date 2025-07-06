extends Node

@export var liquid: int = 0:
	set(value):
		match value:
			1:
				set_underwater_screen_effect(true, Color.LIGHT_SKY_BLUE)
			2:
				set_underwater_screen_effect(true, Color.DARK_ORANGE)
			3:
				set_underwater_screen_effect(true, Color.TAN)
			_:
				set_underwater_screen_effect(false)
		liquid = value

@onready var player := get_owner()


func _process(_delta: float):
	liquid = player.camera_swim_area


func set_underwater_screen_effect(enabled: bool, color: Color = Color.WHITE) -> void:
	$Distortion.visible = enabled
	$Distortion.material.set_shader_parameter("tint", color)
	#Singleton.environment.fog_density *= 40.0 if enabled else 1.0 / 40.0
