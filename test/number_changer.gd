extends Node2D

#预载animatedSprite2D节点
@onready var numbuer_animation_forward = $number_animation_forward
@onready var numbuer_animation_backward = $numbuer_animation_backward

var current_number = 0 # 当前动画编号
var target_number = -1 # 目标动画编号
var is_animating = false # 是否正在播放动画

@export var speed_up_scale:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation_for_number(str(0))
	pass # Replace with function body.

#取得需要播放的数值
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and not is_animating:
		# 检查按键是否为数字键，KEY_0到KEY_9对应的Key常量
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			target_number = int(event.as_text())
			print("target_number:", event.as_text())
			#print("current_number:", current_number)
			if current_number == -1: # 如果当前没有播放动画
				play_animation_for_number(target_number)
			elif target_number != current_number: # 如果目标数字与当前数字不同
				is_animating = true
				update_animation()


func change_flip_clock_number(target_number):
	#直接执行数字变更动画
	play_animation_for_number(target_number)


#从current_number至target_number
func update_animation():
	if is_animating:
		#正序播放
		if current_number < target_number:
			current_number += 1

		
		#倒序播放
		elif current_number > target_number:
			current_number -= 1

			
		#curent和target之间播放速度增加
		numbuer_animation_backward.speed_scale = speed_up_scale
		#播放动画
		play_animation_for_number(current_number)
		
		
		if current_number == target_number:
			is_animating = false
		else:
			# 使用Godot 4中的新方式来延迟调用
			await get_tree().create_timer(0.1).timeout
			update_animation()

#播放动画
func play_animation_for_number(number):
	#获取一个随机时间
	var delay = randf_range(0.1, 0.2)
	#等待这个随机时间
	await get_tree().create_timer(delay).timeout
	#执行倒序播放动画
	numbuer_animation_backward.play(str(number))

#反向播放

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
