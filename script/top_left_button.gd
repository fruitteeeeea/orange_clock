extends Button

#设置显示及隐藏位置
@export var position_show = Vector2(0, 150)
@export var position_show_2 = Vector2(0, 650)
@export var position_hide = Vector2(-200, 150)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = position_hide
	show_top_left_button("plant")
	pass # Replace with function body.

#显示button
func show_top_left_button(text: String):
	#解放聚焦
	if self.has_focus():
			self.release_focus()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show, .4)
	self.text = text
	pass

func show_top_left_button_2(text: String):
		#解放聚焦
	if self.has_focus():
			self.release_focus()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_show_2, .4)
	self.text = text
	pass

#隐藏button
func hide_top_left_button():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position_hide, .4)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
