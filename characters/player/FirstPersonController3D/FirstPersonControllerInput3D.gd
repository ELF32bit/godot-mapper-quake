extends CharacterBody3D

const MOUSE_SENSITIVITY: float = 0.276
const JOYPAD_SENSITIVITY: float = 5.76

@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.5
var mouse_motion_relative: Vector2 = Vector2.ZERO

@export_range(0.0, 1.0) var joypad_sensitivity: float = 0.5
@export var joypad_deadzone := Vector2(0.05, 0.05)

var move_axis_input := Vector2.ZERO
var joypad_axis_input := Vector2.ZERO
var is_sprinting_input := false
var is_jumping_input := false
var has_jumped_input := false


func _ready() -> void:
	# capturing mouse in first person mode
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion_relative += event.relative

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	move_axis_input = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var connected_joypads := Input.get_connected_joypads().size()
	joypad_axis_input = Vector2.ZERO
	if connected_joypads > 0:
		joypad_axis_input.x = Input.get_joy_axis(connected_joypads - 1, JOY_AXIS_RIGHT_X)
		if absf(joypad_axis_input.x) < joypad_deadzone.x:
			joypad_axis_input.x = 0.0
		joypad_axis_input.y = Input.get_joy_axis(connected_joypads - 1, JOY_AXIS_RIGHT_Y)
		if absf(joypad_axis_input.y) < joypad_deadzone.y:
			joypad_axis_input.y = 0.0
	is_sprinting_input = Input.is_action_pressed("move_sprint")
	is_jumping_input = Input.is_action_pressed("move_jump")
	has_jumped_input = Input.is_action_just_pressed("move_jump")

	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_pressed("debug"):
		self.get_node("CollisionShape3D").disabled = true
		self.movement_mode = 2
	elif Input.is_action_just_released("debug"):
		self.get_node("CollisionShape3D").disabled = false
		self.movement_mode = 0
