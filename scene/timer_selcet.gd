extends Control

signal duration_selected(duration_seconds: int)

@export var position_show = Vector2(0, 130)
@export var position_hide = Vector2(-200, 130)

@onready var select_timer_banner = $select_timer_banner

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = position_hide
	select_timer_banner.visible = false
	pass # Replace with function body.

func show_timer_selecter():
	select_timer_banner.visible = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)


func hide_timer_selecter():
	select_timer_banner.visible = false
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)

func _on_twenty_four_min_pressed() -> void:
	duration_selected.emit(24 * 60)

func _on_fourty_five_min_pressed() -> void:
	duration_selected.emit(45 * 60)

func _on_test_pressed() -> void:
	duration_selected.emit(5)
