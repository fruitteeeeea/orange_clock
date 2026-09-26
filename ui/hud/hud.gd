class_name OrangeHUD
extends CanvasLayer

signal plant_requested
signal plant_next_requested
signal duration_selected(seconds: int)
signal start_requested
signal pause_requested
signal resume_requested
signal cancel_requested
signal harvest_requested
signal finish_requested

@onready var topleft_button: Button = $top_left_button
@onready var topleft_button_texture: Sprite2D = $top_left_button/topleft_button_texture
@onready var bottom_button: Button = $bottom_button
@onready var time_lable: FlipClock = $time_lable
@onready var cancel_timer_button: Button = $cancel_timer_button
@onready var harvest_button: Button = $harvest_button
@onready var settalment_box: PanelContainer = $settalment_box
@onready var emoji: Control = $emoji
@onready var timer_selecter: Control = $timer_selceter
@onready var select_timer_pannel: Sprite2D = $select_timer_pannel

var _state: SessionController.State = SessionController.State.IDLE
var _round_id: int = 0
var _presentation_version: int = 0
var _field_ready: bool = true

func _ready() -> void:
	present_state(SessionController.State.IDLE, SessionController.State.IDLE, 0)

func set_field_ready(value: bool) -> void:
	_field_ready = value
	_update_input_availability()

func set_remaining_seconds(seconds: int) -> void:
	time_lable.set_remaining_seconds(seconds)

func set_duration_seconds(seconds: int) -> void:
	select_timer_pannel.frame = {1440: 0, 2700: 1, 5: 2}.get(seconds, 2)
	set_remaining_seconds(seconds)

func _update_input_availability() -> void:
	topleft_button.disabled = _state not in [SessionController.State.IDLE, SessionController.State.READY, SessionController.State.RUNNING, SessionController.State.PAUSED, SessionController.State.RESULTS]
	if _state == SessionController.State.IDLE:
		topleft_button.disabled = not _field_ready
	bottom_button.disabled = _state != SessionController.State.PLANTING
	harvest_button.disabled = _state != SessionController.State.READY_TO_HARVEST
	cancel_timer_button.disabled = _state != SessionController.State.PAUSED
	for button in timer_selecter.get_node("select_timer_button").get_children():
		if button is Button:
			button.disabled = _state != SessionController.State.SELECTING_TIME

func present_state(state: SessionController.State, previous_state: SessionController.State, event_round: int) -> void:
	_state = state
	_round_id = event_round
	_presentation_version += 1
	_update_input_availability()
	match state:
		SessionController.State.IDLE:
			settalment_box.hide_settalment_box()
			topleft_button.show_top_left_button("plant")
			topleft_button_texture.frame = 0
			time_lable.hide_timer_lable()
			bottom_button.hide_bottom_button()
			harvest_button.hide_harvest_button()
			cancel_timer_button.hide_cancel_timer_button()
			timer_selecter.hide_timer_selecter()
			select_timer_pannel.hide_select_timer_pannel()
			emoji.hide_emo_box()
			emoji.hide_button_emo_box()
		SessionController.State.PLANTING:
			topleft_button.hide_top_left_button()
			bottom_button.show_bottom_button()
			emoji.show_emo_box()
		SessionController.State.SELECTING_TIME:
			bottom_button.hide_bottom_button()
			timer_selecter.show_timer_selecter()
		SessionController.State.READY:
			select_timer_pannel.show_select_timer_pannel()
			timer_selecter.hide_timer_selecter()
			topleft_button.show_top_left_button("start")
			topleft_button_texture.frame = 1
		SessionController.State.RUNNING:
			topleft_button.show_top_left_button_2("pause")
			topleft_button_texture.frame = 2
			cancel_timer_button.hide_cancel_timer_button()
			if previous_state == SessionController.State.READY:
				select_timer_pannel.hide_select_timer_pannel()
				time_lable.show_timer_lable()
				emoji.hide_emo_box()
				_show_emoji_after_delay(false)
			else:
				emoji.show_button_emo_box()
		SessionController.State.PAUSED:
			topleft_button.show_top_left_button_2("continue")
			topleft_button_texture.frame = 3
			cancel_timer_button.show_cancel_timer_button()
			emoji.hide_button_emo_box()
		SessionController.State.READY_TO_HARVEST:
			topleft_button.hide_top_left_button()
			time_lable.hide_timer_lable()
			harvest_button.show_harvest_button()
			emoji.hide_button_emo_box()
			_show_emoji_after_delay(true)
		SessionController.State.HARVESTING:
			harvest_button.hide_harvest_button()
		SessionController.State.CLEARING:
			time_lable.hide_timer_lable()
			topleft_button.hide_top_left_button()
			cancel_timer_button.hide_cancel_timer_button()
		SessionController.State.RESULTS:
			topleft_button_texture.frame = 4
			topleft_button.show_top_left_button("finished")
			settalment_box.show_settalment_box()
			emoji.hide_emo_box()

func _show_emoji_after_delay(show_top: bool) -> void:
	var version: int = _presentation_version
	var expected_round: int = _round_id
	await get_tree().create_timer(0.4).timeout
	if version != _presentation_version or expected_round != _round_id:
		return
	if show_top:
		emoji.show_emo_box()
	else:
		emoji.show_button_emo_box()

func _on_primary_pressed() -> void:
	if topleft_button.disabled:
		return
	match _state:
		SessionController.State.IDLE:
			plant_requested.emit()
		SessionController.State.READY:
			start_requested.emit()
		SessionController.State.RUNNING:
			time_lable.apply_shake()
			pause_requested.emit()
		SessionController.State.PAUSED:
			time_lable.apply_shake()
			resume_requested.emit()
		SessionController.State.RESULTS:
			finish_requested.emit()

func _on_plant_next_pressed() -> void:
	if bottom_button.disabled:
		return
	$bottom_button/AnimatedSprite2D.button_pressed()
	plant_next_requested.emit()

func _on_cancel_pressed() -> void:
	if not cancel_timer_button.disabled:
		cancel_requested.emit()

func _on_harvest_pressed() -> void:
	if not harvest_button.disabled:
		harvest_button._on_pressed()
		harvest_requested.emit()

func _on_duration_selected(seconds: int) -> void:
	if _state == SessionController.State.SELECTING_TIME:
		duration_selected.emit(seconds)
