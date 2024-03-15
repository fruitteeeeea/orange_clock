extends Control

#===标注组件===
@onready var dock = $"../dock"
@onready var button_1 = $"../dock/Panel/HBoxContainer/Button"
@onready var button_2 = $"../dock/Panel/HBoxContainer/Button2"
@onready var button_3 = $"../dock/Panel/HBoxContainer/Button3"

@onready var button_animation = $"../dock/Panel/AnimatedSprite2D"

#下面是左上按钮
@onready var top_left_button = $"../top_letf_button"
@onready var top_left_button_lag_ver = $lag_version
@onready var chicken = $"../top_letf_button/Panel/chicken"
 #===位置相关===
var dock_show:Vector2 = Vector2(0, 650)
var dock_hide:Vector2 = Vector2(0, 844)

var top_left_button_show:Vector2 = Vector2(0, 0)
var top_left_button_hide:Vector2 = Vector2(-140, 0)

#===偏移相关===
var chicken_fly:Vector2 = Vector2(0, 10)
var chicken_land:Vector2 = Vector2(0,0)

#===状态变量===
var is_dock_show = false
var is_top_left_button_show = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self_initialize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func position_tween(obejcet, target_pos):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(obejcet, "position", target_pos, .4)

func top_left_button_tween(obejcet, target_pos, chicken_dowhat1):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(obejcet, "position", target_pos, .6)
	#等待信号结束 执行小鸡tween
	tween.finished.connect(chicken_tween)

func top_left_button_shake():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(top_left_button, "offset", chicken_land, .1)

func chicken_tween():
	if is_top_left_button_show == true:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(chicken, "pivot_offset", chicken_land, .1)
		tween.finished.connect(top_left_button_shake)
	else:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(chicken, "pivot_offset", chicken_fly, .1)


func self_initialize():
	dock.position = dock_hide
	button_animation.play("normal")
	top_left_button.position = top_left_button_hide
	top_left_button_lag_ver.play("not_show")

func _on_dock动画_pressed():
	position_tween(dock, dock_show)
	is_dock_show = true
	# 停止当前播放的动画（如果有的话）
	button_animation.stop()
	# 将动画的帧重置为第一帧
	button_animation.frame = 0
	# 重新开始播放动画
	button_animation.play("pop_up")
	pass # Replace with function body.


func _on_button动画_pressed():
	# 停止当前播放的动画（如果有的话）
	button_animation.stop()
	# 将动画的帧重置为第一帧
	button_animation.frame = 0
	# 重新开始播放动画
	button_animation.play("pressed")
	
	pass # Replace with function body.


func _on_重制所有_pressed():
	self_initialize()
	pass # Replace with function body.


func _on_左上按钮动画_pressed():
	if is_top_left_button_show == false:
		top_left_button_tween(top_left_button, top_left_button_show, chicken_land)
		top_left_button_lag_ver.play("show_up")
		is_top_left_button_show =! is_top_left_button_show
	else:
		top_left_button_tween(top_left_button, top_left_button_hide, chicken_fly)
		top_left_button_lag_ver.play_backwards("show_up")
		is_top_left_button_show =! is_top_left_button_show

	pass # Replace with function body.
