extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.self_modulate = Color(0, 0, 0, 0)
	self.position = Vector2(0, -24)
	HARVEST()
	pass # Replace with function body.

func HARVEST():
	#果实动画
	#果实登场动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 1), .4)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), .4)
	tween.tween_property(self, "position", Vector2(0, 0), .4)
	await tween.finished
	
	#等待一段时间
	await get_tree().create_timer(.3).timeout
	
	#果实移动到盒子
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_EXPO)
	tween2.tween_property(self, "position", Vector2(-24, 72), .4)
	tween2.tween_property(self, "scale", Vector2(.5, .5), .4)

	#果实消失
	var tween3 = create_tween()
	tween3.set_ease(Tween.EASE_OUT)
	tween3.set_trans(Tween.TRANS_EXPO)
	tween3.tween_property(self, "self_modulate", Color(0, 0, 0, 0), .4)
	await tween.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

