extends Node2D

@onready var session: SessionController = $SessionController
@onready var focus_timer: FocusTimer = $FocusTimer
@onready var field: OrangeField = $World/Field
@onready var camera_rig: CameraRig = $World/CameraRig
@onready var hud: OrangeHUD = $HUD

var _completion_callback: Callable

func _ready() -> void:
	hud.plant_requested.connect(session.request_plant)
	hud.plant_next_requested.connect(session.request_plant_next)
	hud.duration_selected.connect(session.request_duration)
	hud.start_requested.connect(session.request_start)
	hud.pause_requested.connect(session.request_pause)
	hud.resume_requested.connect(session.request_resume)
	hud.cancel_requested.connect(session.request_cancel)
	hud.harvest_requested.connect(session.request_harvest)
	hud.finish_requested.connect(session.request_finish)
	session.state_changed.connect(_on_state_changed)
	session.plant_next_requested.connect(_on_plant_next_requested)
	session.pause_requested.connect(focus_timer.pause)
	session.resume_requested.connect(focus_timer.resume)
	focus_timer.remaining_seconds_changed.connect(hud.set_remaining_seconds)
	focus_timer.paused_changed.connect(session.on_paused_changed)
	field.field_ready.connect(_on_field_ready)
	field.planting_completed.connect(session.on_planting_completed)
	field.harvest_completed.connect(session.on_harvest_completed)
	field.clear_completed.connect(session.on_clear_completed)
	_on_field_ready()
	_on_state_changed(session.current_state, session.current_state, session.round_id)

func _on_field_ready() -> void:
	session.set_field_ready(field.is_ready)
	hud.set_field_ready(field.is_ready)

func _on_plant_next_requested(event_round: int) -> void:
	if event_round == session.round_id:
		field.plant_next()

func _on_state_changed(state: SessionController.State, previous_state: SessionController.State, event_round: int) -> void:
	if state == SessionController.State.READY:
		hud.set_duration_seconds(session.selected_duration_seconds)
	# Presentation disables invalid input before starting component operations.
	hud.present_state(state, previous_state, event_round)
	match state:
		SessionController.State.IDLE:
			focus_timer.cancel()
			camera_rig.show_overview()
		SessionController.State.PLANTING:
			camera_rig.show_field()
			field.begin_planting(event_round)
		SessionController.State.RUNNING:
			if previous_state == SessionController.State.READY:
				if _completion_callback.is_valid() and focus_timer.completed.is_connected(_completion_callback):
					focus_timer.completed.disconnect(_completion_callback)
				_completion_callback = session.on_timer_completed.bind(event_round)
				focus_timer.completed.connect(_completion_callback)
				focus_timer.start(session.selected_duration_seconds)
				camera_rig.show_overview()
		SessionController.State.READY_TO_HARVEST:
			camera_rig.show_field()
			field.mature_all(event_round)
		SessionController.State.HARVESTING:
			field.harvest_all(event_round)
		SessionController.State.CLEARING:
			focus_timer.cancel()
			field.clear_all(event_round)
