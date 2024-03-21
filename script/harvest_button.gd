extends Button

#设置显示及隐藏位置
@export var position_show = Vector2(144, 630)
@export var position_hide = Vector2(144, 900)

@onready var harvest_button = $harvest_button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_harvest_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)


func hide_harvest_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	# 停止当前播放的动画（如果有的话）
	harvest_button.stop()
	# 将动画的帧重置为第一帧
	harvest_button.frame = 0
	# 重新开始播放动画
	harvest_button.play("pressed")
	pass # Replace with function body.
