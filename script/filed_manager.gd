extends Node2D

signal plant_finished
signal harvest_finished

#===种植相关模块===
#种植状态
var plant_state = false
#预载作物
var flower = preload("res://scene/flower_test.tscn")
#初始化计数器
var flower_id = 0 
#作物加入数组，方便引用
var flowers = []


#===block及生成模块===
#预载filed_area
@onready var filed_area = $filed_area
#预载block场景
var field_block = preload("res://scene/filed_block.tscn")
#网格尺寸
@export var grid_size = 3
#blcok的尺寸
var block_size = Vector2(16, 16)
#初始化计数器
var block_id = 0 
#block数组
var blocks = []
#当前block_序号
var current_block_index = 0


#===cursor模块====
#加载cursor
@onready var cursor = $"../cursor"



func _ready():
	#如果要开始就生成blocks的话
	generate_filed_blocks()
	pass # Replace with function body.


#===blocks生成模块===
#生成blocks
func generate_filed_blocks():
	#获取中心点位置
	var center_index = Vector2((grid_size - 1) / 2, (grid_size - 1) / 2) 
	#行
	for i in range(grid_size):
		#列
		for j in range(grid_size):
			# 实例化FieldBlock
			var field_block = field_block.instantiate()
			# 正确放置blocks## + Vector2(24, 24) 修正filed_area中clip_contents的偏移
			var position = Vector2(j - grid_size / 2, i - grid_size / 2) * block_size
			#var position = Vector2(j - grid_size / 2, i - grid_size / 2) * block_size + Vector2(24, 48)
			print(position)
			field_block.position = position
			# 使用计数器值为方块命名，确保唯一性
			field_block.name = "Block_" + str(block_id) 
			# 增加计数器
			block_id += 1 
			# 添加FieldBlock到filed_manager
			add_child(field_block)
			#filed_area.add_child(field_block)
			blocks.append(field_block) 
			
			#制造延迟感
			await get_tree().create_timer(0.1).timeout
			#打印当前blcok数量
			print(blocks.size())

#进入plant状态
func enter_plant_state():
	#重设当前id索引为第一个
	fouce_update_current_block_index()
	#cursor移动到第一个block位置
	cursor.move_cursor(blocks[current_block_index].position)
	#当前blcok聚焦
	blocks[current_block_index].focus()
	##显示按钮
	#plant_button.position = Vector2(144, 688)
	#开启plant
	plant_state = true
	pass

#更新block_index
func update_current_block_index():
	if current_block_index < blocks.size():
		current_block_index += 1

#强制更新block_index
func fouce_update_current_block_index():
	current_block_index = 0

#===种植模块===

#生成作物
func do_plant(position):
	print("当前种植的index是：", current_block_index)
	var flower = flower.instantiate()
	add_child(flower)
	#filed_area.add_child(flower)
	flower.position = position
	flower.name = "Flower_" + str(flower_id) 
	#作物加入数组，方便引用
	flowers.append(flower)

func plant_stuff():
	#确定种植条件：场景内存在blcok和种植状态为开启
	if blocks.size() > 0 and plant_state == true:
		move_cursor_and_plant()
		pass

func move_cursor_and_plant():
	#先定义最后一个方块
	var the_last_block: int = blocks.size() - 1
	#当index等于零
	if current_block_index == 0:
		#block动画
		blocks[current_block_index].plant()
		#await get_tree().create_timer(0.5).timeout
		
		#种植动画
		do_plant(blocks[current_block_index].position)
		blocks[current_block_index].not_focus()
		
		#更新block_index
		update_current_block_index()
		
		#cursor和focus移动到下一个blcok
		cursor.move_cursor(blocks[current_block_index].position)
		blocks[current_block_index].focus()
		print("当前序号：", current_block_index)
	
	#当index大于零且小于最大值
	elif current_block_index > 0 and current_block_index < the_last_block:
		#block动画
		blocks[current_block_index].plant()
		
		#种植动画
		do_plant(blocks[current_block_index].position)
		blocks[current_block_index].not_focus()
		
		#更新block_index
		update_current_block_index()
		


		cursor.move_cursor(blocks[current_block_index].position)
		blocks[current_block_index].focus()
		print("当前序号：", current_block_index)

	#当index等于最后以一个方块
	elif current_block_index == the_last_block:
		#block动画
		blocks[current_block_index].plant()
				#await get_tree().create_timer(0.5).timeout

		#种植动画
		do_plant(blocks[current_block_index].position)
		blocks[current_block_index].not_focus()
		#移动光标
		cursor.move_cursor(Vector2(80, -60))
		
		##消失按钮
		#plant_button.position = Vector2(144, 900)
		print("结局")
		emit_signal("plant_finished")
		#关闭种植状态
		plant_state = false
	pass


##===这里是收获模块===
#func move_cursor_and_harvest():
	#var the_last_flower: int = flowers.size() - 1
	#pass

#在这里面更改作物状态
func change_sprite():
	for flower in flowers:
			if flower and flower.is_inside_tree() and flower.has_method("MATURE"):
				flower.MATURE()

func do_harvest():
	for flower in flowers:
		#if flower != null:
			## 对每个花朵进行操作，这里只是打印出花朵的位置，你可以根据需要进行具体操作
			#print("Flower Position:", flower.position)
			flower.HARVEST()
			print("收获一个作物")
			await get_tree().create_timer(0.1).timeout
	
	flowers.clear()
	emit_signal("harvest_finished")
	print("harvest finished")

func _process(delta):
	pass

func _on_state_manager_enter_plant_state():
	enter_plant_state()


func _on_bottom_button_pressed():
	$"../state_manager/CanvasLayer2/bottom_button/AnimatedSprite2D".button_pressed()
	plant_stuff()


func _on_state_manager_updata_plant_state():
	change_sprite()

func _on_harvest_button_pressed():
	do_harvest()



#===Debug调试===
func _on_调试按钮1_pressed():
	do_harvest()
	pass # Replace with function body.


func _on_调试种植_pressed():
	plant_stuff()
	pass # Replace with function body.


func _on_调试更改作物状态_pressed():
	change_sprite()



