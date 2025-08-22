@tool
extends Light3D

enum QuakeLightStyle {
	NONE,
	FLICKER_A,
	SLOW_STRONG_PULSE,
	CANDLE_A,
	FAST_STROBE,
	GENTLE_PULSE,
	FLICKER_B,
	CANDLE_B,
	CANDLE_C,
	SLOW_STROBE,
	FLUORESCENT_FLICKER,
	SLOW_PULSE,
}

@export var style := QuakeLightStyle.NONE:
	set(value):
		_set_animation_table(value)
		style = value

@export var animation_speed: float = 10.0
@export var animation_fade_speed: float = 30.0
@export var animation_time_offset: float = 0.0

@onready var _light_energy := float(light_energy)
@onready var _light_indirect_energy := float(light_indirect_energy)
@onready var _light_volumetric_fog_energy := float(light_volumetric_fog_energy)

var _animation_time: float = 0.0
var _animation_table: String = ""
var _flicker_multiplier: float = 1.0


func _ready() -> void:
	_set_animation_table(style)


func _physics_process(delta: float) -> void:
	_animation_time += delta
	var offset_animation_time := animation_time_offset + _animation_time
	var frame_index := int(offset_animation_time * animation_speed) % _animation_table.length()
	var target_multiplier := float(_animation_table.unicode_at(frame_index) - 97) * (2.0 / 25.0)
	var flicker_multiplier := lerpf(_flicker_multiplier, target_multiplier, animation_fade_speed * delta)

	# animating light properties
	light_energy = _light_energy * flicker_multiplier
	light_indirect_energy = _light_indirect_energy * flicker_multiplier
	light_volumetric_fog_energy = _light_volumetric_fog_energy * flicker_multiplier

	# saving previous flicker multiplier
	_flicker_multiplier = flicker_multiplier

@warning_ignore("shadowed_variable")
func _set_animation_table(style: int) -> void:
	# 'm' is normal light, 'a' is no light, 'z' is double bright
	match style:
		1: # flicker A
			_animation_table = "mmnmmommommnonmmonqnmmo"
		2: # slow, strong pulse
			_animation_table = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
		3: # candle A
			_animation_table = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
		4: # fast strobe
			_animation_table = "mamamamamama"
		5: # gentle pulse
			_animation_table = "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
		6: # flicker B
			_animation_table = "nmonqnmomnmomomno"
		7: # candle B
			_animation_table = "mmmaaaabcdefgmmmmaaaammmaamm"
		8: # candle C
			_animation_table = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
		9: # slow strobe
			_animation_table = "aaaaaaaazzzzzzzz"
		10: # fluorescent flicker
			_animation_table = "mmamammmmammamamaaamammma"
		11: # slow pulse, noblack
			_animation_table = "abcdefghijklmnopqrrqponmlkjihgfedcba"
		_:
			_animation_table = ""
			light_energy = _light_energy
			light_indirect_energy = _light_indirect_energy
			light_volumetric_fog_energy = _light_volumetric_fog_energy
	set_physics_process(not _animation_table.is_empty())
