extends "classes/crushing.gd"

signal generic # only used for linked doors and not the main door
signal activated # emitted when health ended or generic signal received by linked door

@export var max_health: int = 0
@onready var health: int = max_health:
	set(value):
		var previous_health := health
		health = clampi(value, 0, max_health)
		if health != previous_health:
			# health has changed here
			if health == 0:
				activated.emit()
@export var message: String = ""

@export_node_path("Area3D") var _area: NodePath
@onready var area: Area3D = get_node(_area)

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

var has_crushed := false


func _ready() -> void:
	set_physics_process(false)
