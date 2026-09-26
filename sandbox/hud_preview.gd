extends Node

const STATES = [
	SessionController.State.IDLE, SessionController.State.PLANTING,
	SessionController.State.SELECTING_TIME, SessionController.State.READY,
	SessionController.State.RUNNING, SessionController.State.PAUSED,
	SessionController.State.RUNNING, SessionController.State.READY_TO_HARVEST,
	SessionController.State.HARVESTING, SessionController.State.RESULTS,
]
@onready var hud: OrangeHUD = $HUD
var _index: int = 0

func _ready() -> void:
	hud.plant_requested.connect(_advance)
	hud.plant_next_requested.connect(_advance)
	hud.start_requested.connect(_advance)
	hud.pause_requested.connect(_advance)
	hud.resume_requested.connect(_advance)
	hud.harvest_requested.connect(_advance)
	hud.finish_requested.connect(_reset)
	hud.cancel_requested.connect(_reset)
	hud.duration_selected.connect(_on_duration_selected)
	hud.set_duration_seconds(5)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_RIGHT:
			_advance()
		elif event.keycode == KEY_R:
			_reset()

func _advance() -> void:
	var previous: SessionController.State = STATES[_index]
	_index = (_index + 1) % STATES.size()
	hud.present_state(STATES[_index], previous, 1)

func _reset() -> void:
	_index = 0
	hud.present_state(STATES[0], STATES[0], 1)

func _on_duration_selected(seconds: int) -> void:
	hud.set_duration_seconds(seconds)
	_advance()
