extends Control

signal select_time(select_time)
signal select_time_finished

@export var position_show = Vector2(0, 130)
@export var position_hide = Vector2(-200, 130)

@onready var select_timer_banner = $select_timer_banner
@onready var select_timer_pannel = $"../select_timer_pannel"

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

func select_timer_done(select_timer_is:int):
	print("timer select +", str(select_timer_is), "min")
	emit_signal("select_time", select_timer_is)
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#选择24分钟
func _on_twenty_four_min_pressed():
	#更改一下面板 
	select_timer_pannel.frame = 0
	#传递信号到计时器
	select_timer_done(24)
	#发送完成选择时间的信号
	emit_signal("select_time_finished")
	pass # Replace with function body.

#选择45分钟
func _on_fourty_five_min_pressed():
	select_timer_pannel.frame = 1
	select_timer_done(45)
	emit_signal("select_time_finished")
	pass # Replace with function body.


func _on_test_pressed():
	select_timer_pannel.frame = 2
	select_timer_done(5)
	emit_signal("select_time_finished")
	pass # Replace with function body.
