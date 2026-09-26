extends Node2D

@export var debug_keyboard_input: bool = false

@onready var numbuer_animation_backward: AnimatedSprite2D = $numbuer_animation_backward

var current_number: int = -1
var _update_version: int = 0

func _ready() -> void:
	set_process_input(debug_keyboard_input)
	play_animation_for_number(0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			play_animation_for_number(event.keycode - KEY_0)

func change_flip_clock_number(number: int) -> void:
	play_animation_for_number(number)

func play_animation_for_number(number: int) -> void:
	if number < 0 or number > 9:
		return
	_update_version += 1
	var version: int = _update_version
	# Preserve staggered flips while discarding superseded requests.
	await get_tree().create_timer(randf_range(0.1, 0.2)).timeout
	if version != _update_version:
		return
	current_number = number
	numbuer_animation_backward.play(str(number))
