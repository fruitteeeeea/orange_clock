extends Button

@export var position_show = Vector2(255, 625)
@export var position_hide = Vector2(400, 625)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = position_hide
	pass # Replace with function body.

func show_cancel_timer_button():
	#解放聚焦
	if self.has_focus():
			self.release_focus()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)
	
#隐藏button
func hide_cancel_timer_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
