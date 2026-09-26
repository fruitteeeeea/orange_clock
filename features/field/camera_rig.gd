class_name CameraRig
extends Node2D

@export var field_zoom: float = 5.0
@export var overview_zoom: float = 2.5
@onready var _camera: Camera2D = $Camera2D
var _zoom_tween: Tween

func show_field() -> void:
	_zoom_to(field_zoom)

func show_overview() -> void:
	_zoom_to(overview_zoom)

func _zoom_to(scale_value: float) -> void:
	if _zoom_tween and _zoom_tween.is_valid():
		_zoom_tween.kill()
	_zoom_tween = create_tween()
	_zoom_tween.set_ease(Tween.EASE_OUT)
	_zoom_tween.set_trans(Tween.TRANS_EXPO)
	_zoom_tween.tween_property(_camera, "zoom", Vector2.ONE * scale_value, 0.1)
