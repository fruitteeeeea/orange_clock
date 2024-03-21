extends Node2D

#===自定义信号===
#告诉filed_manager进入种植模式
signal enter_plant_state
#在倒计时阶段暂停计时器
signal pause_timer 
#更新作物状态
signal updata_plant_state

#每次初始化记得重设pause状态
var pause: bool = false

#===UI组件=== 
@onready var topleft_button = $CanvasLayer2/top_left_button
@onready var topleft_button_texture = $CanvasLayer2/top_left_button/topleft_button_texture

@onready var bottom_button = $CanvasLayer2/bottom_button
@onready var time_lable = $CanvasLayer2/time_lable
@onready var cancel_timer_button = $CanvasLayer2/cancel_timer_button
@onready var harvest_button = $CanvasLayer2/harvest_button

#===相机===
@onready var camera = $"../Camera2D"

@export var camera_zoom_in_scale:int = 5
@export var camera_zoom_out_scale:int = 2


#分配初始状态
var current_state : State = State.InitialState

#使用枚举罗列所有阶段
enum State{
	#初始阶段
	InitialState,
	#点击PLANT后，进入种植阶段
	PLANNING,
	#种植完毕后，等待开始
	START,
	#开始计时
	COUNTDOWN,
	#倒计时结束，等待结算
	SETTALMENT,
	#取消倒计时，直接初始化
	CANCEL,
	#结算完成，等待开始
	FINAL
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Initialize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#编写各个阶段的逻辑
#注意在这里填写的是执行按钮按下后执行的逻辑
#初始化
func Initialize():
	pause = false
	topleft_button.hide_top_left_button()
	topleft_button.show_top_left_button("plant")
	topleft_button_texture.frame = 0
	time_lable.hide_timer_lable()
	camera.do_zoom(Vector2(camera_zoom_out_scale, camera_zoom_out_scale))
	pass
	
#进入种植阶段
func EnterPlanningState():
	topleft_button.hide_top_left_button()
	emit_signal("enter_plant_state")
	bottom_button.show_bottom_button()
	camera.do_zoom(Vector2(camera_zoom_in_scale, camera_zoom_in_scale))
	pass

#等待倒计时开始
func WaittingToStart():
	topleft_button.show_top_left_button("start")
	topleft_button_texture.frame = 1
	bottom_button.hide_bottom_button()
	pass

#等待倒计时结束
func WattingCountDown():
	topleft_button.hide_top_left_button()
	topleft_button.show_top_left_button_2("pause")
	topleft_button_texture.frame = 2
	time_lable.show_timer_lable()
	#同时启动计时
	time_lable.timer.start()
	camera.do_zoom(Vector2(camera_zoom_out_scale, camera_zoom_out_scale))
	pass
	
#倒计时完成 进入结算
func EnterSettalment():
	topleft_button.hide_top_left_button()
	time_lable.hide_timer_lable()
	camera.do_zoom(Vector2(camera_zoom_in_scale, camera_zoom_in_scale))
	#更新作物状态
	emit_signal("updata_plant_state")
	#显示收获按钮
	harvest_button.show_harvest_button()
	pass

#提前结束倒计时 跳过当前阶段
func CancelTimer():
	camera.do_zoom(Vector2(camera_zoom_out_scale, camera_zoom_out_scale))
	Initialize()
	pass

#结算完成 等待初始化
func SettalmentFinished():
	topleft_button_texture.frame = 4
	topleft_button.show_top_left_button("finished")
	
	pass

#执行当前逻辑
func execute_current_state_logic():
	match current_state:
		State.InitialState:
			EnterPlanningState()
			current_state = State.PLANNING
		State.PLANNING:
			WaittingToStart()
			current_state = State.START
		State.START:
			WattingCountDown()
			current_state = State.COUNTDOWN
		State.COUNTDOWN:
			EnterSettalment()
			current_state = State.SETTALMENT
		State.SETTALMENT:
			SettalmentFinished()
			current_state = State.FINAL
		State.CANCEL:
			CancelTimer()
			current_state = State.InitialState
		State.FINAL:
			Initialize()
			current_state = State.InitialState


#操作按钮按下时的逻辑
func _on_top_left_button_pressed():
	#如果处于暂停状态中
	if current_state == State.COUNTDOWN:
		pause_and_continue()
		#否则执行普通的状态切换操作
	else:
		execute_current_state_logic()


#暂停时执行的逻辑
func pause_and_continue():
	print("pause")
	emit_signal("pause_timer")
	if pause == false:
		topleft_button.hide_top_left_button()
		topleft_button.show_top_left_button_2("continue")
		#注意看continue是第几帧
		topleft_button_texture.frame = 3
		
		#弹出取消按钮
		cancel_timer_button.show_cancel_timer_button()
		
		#切换一下当前的暂停状态
		pause = not pause
	else:
		topleft_button.hide_top_left_button()
		topleft_button.show_top_left_button_2("pause")
		#注意看pause是第几帧
		topleft_button_texture.frame = 2
		
		#隐藏取消按钮
		cancel_timer_button.hide_cancel_timer_button()
		
		#切换一下当前的暂停状态
		pause = not pause


#接受来自filed_mananger的种植完毕信号
func _on_filed_manager_plant_finished():
	execute_current_state_logic()
	print("执行当前逻辑。原因：plant_finished")


#倒计时结束后推进状态
func _on_time_lable_label_time_out():
	execute_current_state_logic()
	print("执行当前逻辑。原因：label_time_out")



func _on_filed_manager_harvest_finished():
	execute_current_state_logic()
	print("执行当前逻辑。原因：harvest_finished")


func _on_harvest_button_pressed():
	harvest_button.hide_harvest_button()


func _on_cancel_timer_button_pressed():
	time_lable.hide_timer_lable()
	topleft_button.hide_top_left_button()
	#这个时候必须正式停止时间 不然会重新激活 同时更改暂停状态
	time_lable.stop_timer_and_not_pause()
	
	current_state = State.CANCEL
	cancel_timer_button.hide_cancel_timer_button()
	pass # Replace with function body.
