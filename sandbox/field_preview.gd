extends Node2D

@onready var field: OrangeField = $Field
@onready var camera_rig: CameraRig = $CameraRig
var _round_id: int = 0

func _ready() -> void:
	camera_rig.show_field()
	field.field_ready.connect(_begin_round)
	field.harvest_completed.connect(_on_operation_completed)
	field.clear_completed.connect(_on_operation_completed)
	if field.is_ready:
		_begin_round()

func _begin_round() -> void:
	_round_id += 1
	field.begin_planting(_round_id)

func _on_operation_completed(_event_round: int) -> void:
	_begin_round()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P:
				field.plant_next()
			KEY_M:
				field.mature_all(_round_id)
			KEY_H:
				field.harvest_all(_round_id)
			KEY_C:
				field.clear_all(_round_id)
