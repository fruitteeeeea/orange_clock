class_name SessionController
extends Node2D

# Keep the existing scene and UI while making every transition event-specific.
enum State {
	IDLE,
	PLANTING,
	SELECTING_TIME,
	READY,
	RUNNING,
	PAUSED,
	READY_TO_HARVEST,
	HARVESTING,
	CLEARING,
	RESULTS,
}

const LEGAL_TRANSITIONS = {
	State.IDLE: [State.PLANTING],
	State.PLANTING: [State.SELECTING_TIME],
	State.SELECTING_TIME: [State.READY],
	State.READY: [State.RUNNING],
	State.RUNNING: [State.PAUSED, State.READY_TO_HARVEST],
	State.PAUSED: [State.RUNNING, State.CLEARING],
	State.READY_TO_HARVEST: [State.HARVESTING],
	State.HARVESTING: [State.RESULTS],
	State.CLEARING: [State.IDLE],
	State.RESULTS: [State.IDLE],
}

@export var camera_zoom_in_scale: int = 5
@export var camera_zoom_out_scale: float = 2

var current_state: State = State.IDLE
var round_id: int = 0
var selected_duration_seconds: int = 5
var _state_version: int = 0
var _completion_callback: Callable

@onready var focus_timer: FocusTimer = $FocusTimer
@onready var field: Node2D = $"../filed_manager"
@onready var camera: Camera2D = $"../Camera2D"
@onready var topleft_button: Button = $CanvasLayer2/top_left_button
@onready var topleft_button_texture: Sprite2D = $CanvasLayer2/top_left_button/topleft_button_texture
@onready var bottom_button: Button = $CanvasLayer2/bottom_button
@onready var time_lable: FlipClock = $CanvasLayer2/time_lable
@onready var cancel_timer_button: Button = $CanvasLayer2/cancel_timer_button
@onready var harvest_button: Button = $CanvasLayer2/harvest_button
@onready var settalment_box: PanelContainer = $CanvasLayer2/settalment_box
@onready var emoji: Control = $CanvasLayer2/emoji
@onready var timer_selecter: Control = $CanvasLayer2/timer_selceter
@onready var select_timer_pannel: Sprite2D = $CanvasLayer2/select_timer_pannel

func _ready() -> void:
	focus_timer.remaining_seconds_changed.connect(time_lable.set_remaining_seconds)
	focus_timer.paused_changed.connect(_on_focus_timer_paused_changed)
	field.plant_finished.connect(_on_filed_manager_plant_finished)
	field.harvest_completed.connect(_on_filed_manager_harvest_completed)
	field.clear_completed.connect(_on_filed_manager_clear_completed)
	field.field_ready.connect(_on_field_ready)
	_enter_state(State.IDLE)

func transition_to(next_state: State) -> bool:
	if next_state not in LEGAL_TRANSITIONS[current_state]:
		return false
	var previous_state: State = current_state
	current_state = next_state
	_state_version += 1
	# Set state and disable invalid inputs before launching any asynchronous work.
	_update_input_availability()
	_enter_state(previous_state)
	return true

func _update_input_availability() -> void:
	topleft_button.disabled = current_state not in [State.IDLE, State.READY, State.RUNNING, State.PAUSED, State.RESULTS]
	if current_state == State.IDLE:
		topleft_button.disabled = not field.is_ready
	bottom_button.disabled = current_state != State.PLANTING
	harvest_button.disabled = current_state != State.READY_TO_HARVEST
	cancel_timer_button.disabled = current_state != State.PAUSED
	for button in timer_selecter.get_node("select_timer_button").get_children():
		if button is Button:
			button.disabled = current_state != State.SELECTING_TIME

func _enter_state(previous_state: State) -> void:
	_update_input_availability()
	match current_state:
		State.IDLE:
			focus_timer.cancel()
			settalment_box.hide_settalment_box()
			topleft_button.show_top_left_button("plant")
			topleft_button_texture.frame = 0
			time_lable.hide_timer_lable()
			bottom_button.hide_bottom_button()
			harvest_button.hide_harvest_button()
			cancel_timer_button.hide_cancel_timer_button()
			timer_selecter.hide_timer_selecter()
			select_timer_pannel.hide_select_timer_pannel()
			camera.do_zoom(Vector2.ONE * camera_zoom_out_scale)
			emoji.hide_emo_box()
			emoji.hide_button_emo_box()
		State.PLANTING:
			topleft_button.hide_top_left_button()
			bottom_button.show_bottom_button()
			camera.do_zoom(Vector2.ONE * camera_zoom_in_scale)
			emoji.show_emo_box()
			field.enter_plant_state(round_id)
		State.SELECTING_TIME:
			bottom_button.hide_bottom_button()
			timer_selecter.show_timer_selecter()
		State.READY:
			select_timer_pannel.show_select_timer_pannel()
			timer_selecter.hide_timer_selecter()
			topleft_button.show_top_left_button("start")
			topleft_button_texture.frame = 1
		State.RUNNING:
			topleft_button.show_top_left_button_2("pause")
			topleft_button_texture.frame = 2
			cancel_timer_button.hide_cancel_timer_button()
			if previous_state == State.READY:
				select_timer_pannel.hide_select_timer_pannel()
				time_lable.show_timer_lable()
				_connect_timer_completion()
				focus_timer.start(selected_duration_seconds)
				camera.do_zoom(Vector2.ONE * camera_zoom_out_scale)
				emoji.hide_emo_box()
				_show_emoji_after_delay(false)
			else:
				emoji.show_button_emo_box()
		State.PAUSED:
			topleft_button.show_top_left_button_2("continue")
			topleft_button_texture.frame = 3
			cancel_timer_button.show_cancel_timer_button()
			emoji.hide_button_emo_box()
		State.READY_TO_HARVEST:
			topleft_button.hide_top_left_button()
			time_lable.hide_timer_lable()
			camera.do_zoom(Vector2.ONE * camera_zoom_in_scale)
			field.change_sprite(round_id)
			harvest_button.show_harvest_button()
			emoji.hide_button_emo_box()
			_show_emoji_after_delay(true)
		State.HARVESTING:
			harvest_button.hide_harvest_button()
			field.do_harvest(round_id)
		State.CLEARING:
			time_lable.hide_timer_lable()
			topleft_button.hide_top_left_button()
			cancel_timer_button.hide_cancel_timer_button()
			focus_timer.cancel()
			field.do_destroy(round_id)
		State.RESULTS:
			topleft_button_texture.frame = 4
			topleft_button.show_top_left_button("finished")
			settalment_box.show_settalment_box()
			emoji.hide_emo_box()

func _show_emoji_after_delay(show_top: bool) -> void:
	var expected_state: State = current_state
	var version: int = _state_version
	var expected_round: int = round_id
	await get_tree().create_timer(0.4).timeout
	if version != _state_version or expected_round != round_id or current_state != expected_state:
		return
	if show_top:
		emoji.show_emo_box()
	else:
		emoji.show_button_emo_box()

func _connect_timer_completion() -> void:
	if _completion_callback.is_valid() and focus_timer.completed.is_connected(_completion_callback):
		focus_timer.completed.disconnect(_completion_callback)
	_completion_callback = _on_focus_timer_completed.bind(round_id)
	focus_timer.completed.connect(_completion_callback)

func _on_field_ready() -> void:
	_update_input_availability()

func _on_top_left_button_pressed() -> void:
	match current_state:
		State.IDLE:
			if not field.is_ready:
				return
			round_id += 1
			selected_duration_seconds = 5
			transition_to(State.PLANTING)
		State.READY:
			transition_to(State.RUNNING)
		State.RUNNING:
			focus_timer.pause()
			time_lable.apply_shake()
		State.PAUSED:
			focus_timer.resume()
			time_lable.apply_shake()
		State.RESULTS:
			transition_to(State.IDLE)

func _on_bottom_button_pressed() -> void:
	if current_state == State.PLANTING:
		field._on_bottom_button_pressed()

func _on_focus_timer_paused_changed(is_paused: bool) -> void:
	if current_state == State.RUNNING and is_paused:
		transition_to(State.PAUSED)
	elif current_state == State.PAUSED and not is_paused:
		transition_to(State.RUNNING)

func _on_filed_manager_plant_finished(event_round: int) -> void:
	if event_round == round_id and current_state == State.PLANTING:
		transition_to(State.SELECTING_TIME)

func _on_duration_selected(duration_seconds: int) -> void:
	if current_state != State.SELECTING_TIME or duration_seconds not in [1440, 2700, 5]:
		return
	selected_duration_seconds = duration_seconds
	select_timer_pannel.frame = {1440: 0, 2700: 1, 5: 2}[duration_seconds]
	time_lable.set_remaining_seconds(duration_seconds)
	transition_to(State.READY)

func _on_focus_timer_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.RUNNING:
		transition_to(State.READY_TO_HARVEST)

func _on_harvest_button_pressed() -> void:
	if current_state == State.READY_TO_HARVEST:
		transition_to(State.HARVESTING)

func _on_filed_manager_harvest_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.HARVESTING:
		transition_to(State.RESULTS)

func _on_cancel_timer_button_pressed() -> void:
	if current_state == State.PAUSED:
		transition_to(State.CLEARING)

func _on_filed_manager_clear_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.CLEARING:
		transition_to(State.IDLE)
