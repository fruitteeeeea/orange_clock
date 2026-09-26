extends Node2D

#===自定义信号===
#告诉filed_manager进入种植模式
signal enter_plant_state
#更新作物状态
signal updata_plant_state

# 本轮时间统一使用秒；暂停状态由 FocusTimer 管理。
var selected_duration_seconds: int = 5
@onready var focus_timer: FocusTimer = $FocusTimer

#===UI组件=== 
@onready var topleft_button = $CanvasLayer2/top_left_button
@onready var topleft_button_texture = $CanvasLayer2/top_left_button/topleft_button_texture

@onready var bottom_button = $CanvasLayer2/bottom_button
@onready var time_lable: FlipClock = $CanvasLayer2/time_lable
@onready var cancel_timer_button = $CanvasLayer2/cancel_timer_button
@onready var harvest_button = $CanvasLayer2/harvest_button

@onready var settalment_box = $CanvasLayer2/settalment_box
@onready var emoji = $CanvasLayer2/emoji
@onready var timer_selecter = $CanvasLayer2/timer_selceter
@onready var select_timer_pannel = $CanvasLayer2/select_timer_pannel

#===相机===
@onready var camera = $"../Camera2D"

@export var camera_zoom_in_scale:int = 5
@export var camera_zoom_out_scale:float = 2


#分配初始状态
var current_state : State = State.InitialState

#使用枚举罗列所有阶段
enum State{
	#初始阶段
	InitialState,
	#点击PLANT后，进入种植阶段
	PLANNING,
	#种植完毕后，选择时间
	SELECTTIMER,
	#选择时间完毕后，等待开始
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
	focus_timer.remaining_seconds_changed.connect(time_lable.set_remaining_seconds)
	focus_timer.paused_changed.connect(_on_focus_timer_paused_changed)
	focus_timer.completed.connect(_on_focus_timer_completed)
	Initialize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#编写各个阶段的逻辑
#注意在这里填写的是执行按钮按下后执行的逻辑
#初始化
func Initialize():
	focus_timer.cancel()
	settalment_box.hide_settalment_box()
	topleft_button.hide_top_left_button()
	topleft_button.show_top_left_button("plant")
	topleft_button_texture.frame = 0
	time_lable.hide_timer_lable()
	camera.do_zoom(Vector2(camera_zoom_out_scale, camera_zoom_out_scale))
	
	#隐藏所有emoji
	emoji.hide_emo_box()
	emoji.hide_button_emo_box()
	pass
	
#进入种植阶段
func EnterPlanningState():
	topleft_button.hide_top_left_button()
	emit_signal("enter_plant_state")
	bottom_button.show_bottom_button()
	camera.do_zoom(Vector2(camera_zoom_in_scale, camera_zoom_in_scale))
	emoji.show_emo_box()
	pass

#选择计时器
func SelectTimer():
	timer_selecter.show_timer_selecter()
	bottom_button.hide_bottom_button()

#等待倒计时开始
func WaittingToStart():
	select_timer_pannel.show_select_timer_pannel()
	timer_selecter.hide_timer_selecter()
	topleft_button.show_top_left_button("start")
	topleft_button_texture.frame = 1
	pass

#等待倒计时结束
func WattingCountDown():
	select_timer_pannel.hide_select_timer_pannel()
	topleft_button.hide_top_left_button()
	timer_selecter.hide_timer_selecter()
	topleft_button.show_top_left_button_2("pause")
	topleft_button_texture.frame = 2
	time_lable.show_timer_lable()
	focus_timer.start(selected_duration_seconds)
	camera.do_zoom(Vector2(camera_zoom_out_scale, camera_zoom_out_scale))
	
	#将表情包转移到下方
	emoji.hide_emo_box()
	await get_tree().create_timer(.4).timeout
	if current_state == State.COUNTDOWN and not focus_timer.is_paused:
		emoji.show_button_emo_box()
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
	emoji.hide_button_emo_box()
	await get_tree().create_timer(.4).timeout
	emoji.show_emo_box()
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
	settalment_box.show_settalment_box()
	emoji.hide_emo_box()
	pass

#执行当前逻辑
func execute_current_state_logic():
	match current_state:
		State.InitialState:
			EnterPlanningState()
			current_state = State.PLANNING
		State.PLANNING:
			SelectTimer()
			current_state = State.SELECTTIMER
		State.SELECTTIMER:
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
	if focus_timer.is_paused:
		focus_timer.resume()
	else:
		focus_timer.pause()
	time_lable.apply_shake()


func _on_focus_timer_paused_changed(is_paused: bool) -> void:
	if current_state != State.COUNTDOWN:
		return
	topleft_button.hide_top_left_button()
	if is_paused:
		topleft_button.show_top_left_button_2("continue")
		topleft_button_texture.frame = 3
		cancel_timer_button.show_cancel_timer_button()
		emoji.hide_button_emo_box()
	else:
		topleft_button.show_top_left_button_2("pause")
		topleft_button_texture.frame = 2
		cancel_timer_button.hide_cancel_timer_button()
		emoji.show_button_emo_box()


#接受来自filed_mananger的种植完毕信号
func _on_filed_manager_plant_finished():
	execute_current_state_logic()
	print("执行当前逻辑。原因：plant_finished")


#倒计时结束后推进状态
func _on_focus_timer_completed() -> void:
	if current_state == State.COUNTDOWN:
		execute_current_state_logic()



func _on_filed_manager_harvest_finished():
	execute_current_state_logic()
	print("执行当前逻辑。原因：harvest_finished")


func _on_harvest_button_pressed():
	harvest_button.hide_harvest_button()


func _on_cancel_timer_button_pressed():
	time_lable.hide_timer_lable()
	topleft_button.hide_top_left_button()
	current_state = State.CANCEL
	focus_timer.cancel()
	cancel_timer_button.hide_cancel_timer_button()
	pass # Replace with function body.

#选择完计时器后 推进下一步
func _on_timer_selceter_select_time_finished():
	execute_current_state_logic()
	pass # Replace with function body.


func _on_timer_selceter_select_time(duration_seconds: int) -> void:
	selected_duration_seconds = duration_seconds
	time_lable.set_remaining_seconds(duration_seconds)
