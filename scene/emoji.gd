extends Control

@export var position_show = Vector2(100, 55)
@export var position_hide = Vector2(100, -5)

@export var position_show_bottom = Vector2(100, 230)
@export var position_hide_bottom = Vector2(100, 285)

@export var line_position = Vector2(0, -30)
@export var line_position_buttom = Vector2(0, 30)

@onready var emo_box = $emo_box
@onready var emo_box_bottom = $emo_box2

# Called when the node enters the scene tree for the first time.
func _ready():
	emo_box.position = position_hide
	pass # Replace with function body.

func show_emo_box():
	#避免同时出现两种emoji
	if emo_box_bottom.position == position_show_bottom:
		hide_button_emo_box()
	
	emo_box.position = position_hide
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(emo_box, "position", position_show, .4)


func hide_emo_box():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(emo_box, "position", position_hide, .4)


###===下面是倒计时期间出现在下方===
func show_button_emo_box():
	#emo_box_bottom.position = position_hide_bottom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(emo_box_bottom, "position", position_show_bottom, .4)


func hide_button_emo_box():
	#emo_box_bottom.position = position_show_bottom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(emo_box_bottom, "position", position_hide_bottom, .1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
