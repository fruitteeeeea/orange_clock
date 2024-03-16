extends Control

@onready var button_animation = $Panel/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func button_pressed():
	# 停止当前播放的动画（如果有的话）
	button_animation.stop()
	button_animation.frame = 0
	# 重新开始播放动画
	button_animation.play("pop_up")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
