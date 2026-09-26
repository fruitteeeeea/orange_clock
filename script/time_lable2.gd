class_name FlipClock
extends Label

@export var position_show: Vector2 = Vector2(194.5, 144)
@export var position_hide: Vector2 = Vector2(194.5, 0)

@onready var _digits: Array[Node2D] = [
	$flip_clock/minute_ten,
	$flip_clock/minue_one,
	$flip_clock/second_ten,
	$flip_clock/second_one,
]
@onready var time_text: Label = $time_text

var _last_digits: Array[int] = [-1, -1, -1, -1]
var _position_tween: Tween
var _shake_tween: Tween

func _ready() -> void:
	set_remaining_seconds(0)

func set_remaining_seconds(seconds: int) -> void:
	var display_seconds: int = clampi(seconds, 0, 99 * 60 + 59)
	var minutes: int = display_seconds / 60
	var remainder: int = display_seconds % 60
	time_text.text = "%02d:%02d" % [minutes, remainder]
	var digits: Array[int] = [minutes / 10, minutes % 10, remainder / 10, remainder % 10]
	for index in range(_digits.size()):
		if digits[index] != _last_digits[index]:
			_digits[index].play_animation_for_number(digits[index])
			_last_digits[index] = digits[index]

func show_timer_lable() -> void:
	_move_to(position_show)

func hide_timer_lable() -> void:
	_move_to(position_hide)

func _move_to(target: Vector2) -> void:
	if _position_tween and _position_tween.is_valid():
		_position_tween.kill()
	_position_tween = create_tween()
	_position_tween.set_ease(Tween.EASE_OUT)
	_position_tween.set_trans(Tween.TRANS_EXPO)
	_position_tween.tween_property(self, "position", target, 0.4)

func apply_shake() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	_shake_tween.set_ease(Tween.EASE_OUT)
	_shake_tween.set_trans(Tween.TRANS_EXPO)
	_shake_tween.tween_property(self, "pivot_offset", Vector2(0, -25), 0.1)
	_shake_tween.set_trans(Tween.TRANS_BOUNCE)
	_shake_tween.tween_property(self, "pivot_offset", Vector2.ZERO, 0.4)
