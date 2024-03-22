extends Sprite2D

#设定动画播放器
@onready var animation_player = $AnimationPlayer
#设定果实
@onready var fruit = preload("res://scene/orange.tscn")

#在最开始时执行的操作 
func _ready():
	initialize()
	#self_show()
	flower_bounce()

func _process(delta):
	pass

#设定种初始状态
func initialize():
	self.offset = Vector2(0, -12)
	rotation_degrees = -30.0

#作物出现
func self_show():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property(self, "offset", Vector2(0, -5.0), .1)
	tween.tween_property(self, "offset", Vector2(0, -8.0), .1)
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 1), .4)
	tween.tween_property(self, "offset", Vector2(0, -16), .4)
	tween.tween_property(self, "rotation_degrees", 0, .4)

#作物消失
func self_hide():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 0), .4)
	tween.tween_property(self, "offset", Vector2(10, -30), .4)
	tween.tween_property(self, "rotation_degrees", 45, .4)
	await tween.finished
	queue_free()



#花朵弹跳
func flower_bounce():
		#var delay = randf_range(0.1, 1)
		## 等待这个随机时间
		#await get_tree().create_timer(delay).timeout
		# 延迟结束后执行的动画
		animation_player.play("bounce")
		#change_frame()

#更改帧
func change_frame():
	#这里想要获取总帧数 但是不知道为啥没有成功
	#if self.frame >= 2:
		#self.frame = 0
	#else:
		#self.frame += 1
	var frames = 9
	var random_frame = randi_range(1, frames - 1)
	self.frame = random_frame
	
	
#作物成熟之后 更改帧数
func MATURE():
	var delay = randf_range(0.1, 1)
	# 等待这个随机时间
	await get_tree().create_timer(delay).timeout
	# 延迟结束后执行的动画
	animation_player.play("bounce")
	change_frame()
	pass

#执行收获操作 当前场景生成水果并收入箱子
func HARVEST():
	#播放自身动画
	animation_player.play("being_harvest")
	
	#播放水果动画
	var fruit = fruit.instantiate()
	add_child(fruit)
	
	await get_tree().create_timer(2).timeout
	fruit.queue_free()
	destroy_flower()

func DESTROY():
	#播放自身动画
	animation_player.play("destory") 
	await get_tree().create_timer(1).timeout
	destroy_flower()

#隐藏花朵
func destroy_flower():
		self.visible = false
		self.queue_free()

#===调试相关===

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			print("我点！")



