class_name FocusTimer
extends Node

signal remaining_seconds_changed(seconds: int)
signal paused_changed(is_paused: bool)
signal completed

var is_paused: bool:
	get:
		return _timer.paused

@onready var _timer: Timer = $Timer

var _running: bool = false
var _last_seconds: int = -1

func _ready() -> void:
	_timer.timeout.connect(_on_timeout)
	set_process(false)

func start(duration_seconds: int) -> void:
	if duration_seconds <= 0:
		push_error("FocusTimer duration must be positive seconds.")
		return
	_timer.stop()
	_set_paused(false)
	_running = true
	_timer.start(float(duration_seconds))
	_publish_seconds(duration_seconds, true)
	set_process(true)

func pause() -> void:
	if _running:
		_set_paused(true)

func resume() -> void:
	if _running:
		_set_paused(false)

func cancel() -> void:
	_running = false
	_timer.stop()
	set_process(false)
	_set_paused(false)
	_publish_seconds(0)

func _process(_delta: float) -> void:
	_publish_seconds(maxi(0, ceili(_timer.time_left)))

func _set_paused(value: bool) -> void:
	if _timer.paused == value:
		return
	_timer.paused = value
	paused_changed.emit(value)

func _publish_seconds(seconds: int, force: bool = false) -> void:
	if not force and seconds == _last_seconds:
		return
	_last_seconds = seconds
	remaining_seconds_changed.emit(seconds)

func _on_timeout() -> void:
	if not _running:
		return
	_running = false
	set_process(false)
	_publish_seconds(0)
	completed.emit()
