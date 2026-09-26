class_name OrangeField
extends Node2D

signal field_ready
signal planting_completed(round_id: int)
signal harvest_completed(round_id: int)
signal clear_completed(round_id: int)

var is_ready: bool = false
var _round_id: int = 0
var _operation_version: int = 0
var _busy: bool = false

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
@onready var cursor = $Cursor
@onready var crop_container: Node2D = $Crops



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
			var position = Vector2(j - grid_size / 2, i - grid_size / 2) * block_size
			print(position)
			field_block.position = position
			# 使用计数器值为方块命名，确保唯一性
			field_block.name = "Block_" + str(block_id) 
			# 增加计数器
			block_id += 1 
			# 添加FieldBlock到filed_manager
			crop_container.add_child(field_block)
			blocks.append(field_block) 
			
			#制造延迟感
			await get_tree().create_timer(0.1).timeout
			#打印当前blcok数量
			print(blocks.size())

	is_ready = true
	field_ready.emit()

#进入plant状态
func begin_planting(session_round: int):
	if not is_ready or _busy:
		return
	_round_id = session_round
	_operation_version += 1
	#重设当前id索引为第一个
	fouce_update_current_block_index()
	#cursor移动到第一个block位置
	cursor.move_cursor(blocks[current_block_index].position)
	#当前blcok聚焦
	blocks[current_block_index].focus()
	#切换种植状态
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
		cursor.move_cursor(Vector2(150, -60))
		
		print("结局")
		# Close input before notifying the controller.
		plant_state = false
		planting_completed.emit(_round_id)
	pass

#生成作物
func do_plant(position):
	print("当前种植的index是：", current_block_index)
	var flower = flower.instantiate()
	crop_container.add_child(flower)
	flower.position = position
	flower.name = "Flower_" + str(flower_id) 
	#作物加入数组，方便引用
	flowers.append(flower)

##===这里是收获模块===
#在这里面更改作物状态
func mature_all(session_round: int):
	if session_round != _round_id or _busy:
		return
	for flower in flowers:
			if flower and flower.is_inside_tree() and flower.has_method("MATURE"):
				flower.MATURE()

func harvest_all(session_round: int) -> void:
	if session_round != _round_id or _busy:
		return
	_busy = true
	_operation_version += 1
	var version: int = _operation_version
	var crops: Array = flowers.duplicate()
	for crop in crops:
		if version != _operation_version or session_round != _round_id:
			return
		if is_instance_valid(crop):
			crop.HARVEST()
		await get_tree().create_timer(0.1).timeout
	if version != _operation_version or session_round != _round_id:
		return
	flowers.clear()
	_busy = false
	harvest_completed.emit(session_round)

func clear_all(session_round: int) -> void:
	if session_round != _round_id or _busy:
		return
	_busy = true
	plant_state = false
	_operation_version += 1
	var version: int = _operation_version
	var crops: Array = flowers.duplicate()
	for crop in crops:
		if version != _operation_version or session_round != _round_id:
			return
		if is_instance_valid(crop):
			crop.DESTROY()
		await get_tree().create_timer(0.1).timeout
	if version != _operation_version or session_round != _round_id:
		return
	flowers.clear()
	_busy = false
	clear_completed.emit(session_round)

func plant_next() -> void:
	if not plant_state or _busy:
		return
	plant_stuff()
