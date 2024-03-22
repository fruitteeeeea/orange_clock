extends Sprite2D

@export var position_show = Vector2(152, 712)
@export var position_hide = Vector2(-200, 712)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = position_hide
	pass # Replace with function body.

func show_select_timer_pannel():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)


func hide_select_timer_pannel():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
