extends Label

signal label_time_out

#指定timer节点 
@export var timer = Node
@export var wait_time:int = 5

#设置显示及隐藏位置
@export var position_show = Vector2(120, 150)
@export var position_hide = Vector2(-200, 150)

#是否处于暂停状态
var timer_pause:bool = false

#===filp_clock引用相关===
@onready var flip_clock_minute_ten = $flip_clock/minute_ten
@onready var flip_clock_minute_one = $flip_clock/minue_one
@onready var flip_clock_second_ten = $flip_clock/second_ten
@onready var flip_clock_second_one = $flip_clock/second_one

@onready var time_text = $time_text

var timer_numbers = [0, 0, 0, 0]

#定义last_mt
var last_mt:int = 0
var last_mo:int = 0
var last_st:int = 0
var last_so:int = 0
#定义current_mt
var current_mt:int = 0
var current_mo:int = 0
var current_st:int = 0
var current_so:int = 0

func _ready():
	#设定timer为one_shot 否则他会自动重启
	timer.one_shot = true
	timer.wait_time = wait_time
	
	pass 

func update_timer_number():
	#格式化时间字符串
	var formatted_time = "%02d%02d" % _time_left()
	#print(formatted_time)
	#更新timer_numbers数组 
	for i in range(formatted_time.length()):
		timer_numbers[i] = int(formatted_time[i])
	
	
	change_flip_clock_number(timer_numbers)
	pass


#改变flip_clock动画
#要不在这里设立对比条件 再决定要不要更新
func change_flip_clock_number(timer_numbers):
	current_mt = timer_numbers[0]
	current_mo = timer_numbers[1]
	current_st = timer_numbers[2]
	current_so = timer_numbers[3]
	#print(timer_numbers)
	if current_mt != last_mt:
		flip_clock_minute_ten.play_animation_for_number(current_mt)
		last_mt = current_mt
	if current_mo != last_mo:
		flip_clock_minute_one.play_animation_for_number(current_mo)
		last_mo = current_mo
	if current_st != last_st:
		flip_clock_second_ten.play_animation_for_number(current_st)
		last_st = current_st
	if current_so != last_so:
		flip_clock_second_one.play_animation_for_number(current_so)
		last_so = current_so

#获取计时器剩余时间
func _time_left():
	var time_left = timer.time_left
	var minute = floor(time_left / 60)#这里的floor表示向下取整 确保取到的分钟为整数 
	var second = int(time_left - minute * 60)
	return[minute, second]

func _process(delta):
	#运行时不间断获取计时器余下时间信息
	#self.text = "%02d:%02d" % _time_left()
	#update_timer_number()
	pass

#根据运行时间来获取 不要一直获取
func _physics_process(delta):
	time_text.text = "%02d:%02d" % _time_left()
	await get_tree().create_timer(1).timeout
	update_timer_number()
	#print(timer.time_left)


#===time_lable显示与隐藏相关===
func show_timer_lable():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)
	#同时启动计时
	timer.start()

func hide_timer_lable():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)


#===计时器暂停相关===
#接受state_manager的暂停信号
func _on_state_manager_pause_timer():
	pause_timer()

#处于暂停状态时暂停计时器
func pause_timer():
	if timer_pause == false:
		timer.paused = true
		timer_pause = not timer_pause
	else:
		timer.paused = false
		timer_pause = not timer_pause


#===计时器完成===
#计时器完成时向state_manager发送信号
func _on_timer_timeout():
	emit_signal("label_time_out")
