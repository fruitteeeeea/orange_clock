class_name SessionController
extends Node

signal state_changed(state: State, previous_state: State, round_id: int)
signal plant_next_requested(round_id: int)
signal pause_requested
signal resume_requested

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

var current_state: State = State.IDLE
var round_id: int = 0
var selected_duration_seconds: int = 5
var _field_ready: bool = false

func set_field_ready(value: bool) -> void:
	_field_ready = value

func transition_to(next_state: State) -> bool:
	if next_state not in LEGAL_TRANSITIONS[current_state]:
		return false
	var previous_state: State = current_state
	current_state = next_state
	state_changed.emit(current_state, previous_state, round_id)
	return true

func request_plant() -> void:
	if current_state != State.IDLE or not _field_ready:
		return
	round_id += 1
	selected_duration_seconds = 5
	transition_to(State.PLANTING)

func request_plant_next() -> void:
	if current_state == State.PLANTING:
		plant_next_requested.emit(round_id)

func request_duration(duration_seconds: int) -> void:
	if current_state != State.SELECTING_TIME or duration_seconds not in [1440, 2700, 5]:
		return
	selected_duration_seconds = duration_seconds
	transition_to(State.READY)

func request_start() -> void:
	if current_state == State.READY:
		transition_to(State.RUNNING)

func request_pause() -> void:
	if current_state == State.RUNNING:
		pause_requested.emit()

func request_resume() -> void:
	if current_state == State.PAUSED:
		resume_requested.emit()

func request_cancel() -> void:
	if current_state == State.PAUSED:
		transition_to(State.CLEARING)

func request_harvest() -> void:
	if current_state == State.READY_TO_HARVEST:
		transition_to(State.HARVESTING)

func request_finish() -> void:
	if current_state == State.RESULTS:
		transition_to(State.IDLE)

func on_paused_changed(is_paused: bool) -> void:
	if current_state == State.RUNNING and is_paused:
		transition_to(State.PAUSED)
	elif current_state == State.PAUSED and not is_paused:
		transition_to(State.RUNNING)

func on_planting_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.PLANTING:
		transition_to(State.SELECTING_TIME)

func on_timer_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.RUNNING:
		transition_to(State.READY_TO_HARVEST)

func on_harvest_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.HARVESTING:
		transition_to(State.RESULTS)

func on_clear_completed(event_round: int) -> void:
	if event_round == round_id and current_state == State.CLEARING:
		transition_to(State.IDLE)
