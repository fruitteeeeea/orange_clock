extends Button

#设置显示及隐藏位置
@export var position_show = Vector2(144.5, 630)
@export var position_hide = Vector2(144.5, 900)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func show_bottom_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)


func hide_bottom_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
