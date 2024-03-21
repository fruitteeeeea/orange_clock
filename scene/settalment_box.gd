extends PanelContainer

#设置显示及隐藏位置
@export var position_show = Vector2(35, 280)
@export var position_hide = Vector2(420,280)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = position_hide
	pass # Replace with function body.

func show_settalment_box():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)


func hide_settalment_box():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
