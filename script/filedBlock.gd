extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Spwan()
	pass # Replace with function body.

func Spwan():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "offset", Vector2(0, -8.0), .1)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "offset", Vector2(0, 8), .3)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func focus():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "offset", Vector2(0, -8.0), .1)
	print("名字", self.name)
	print("focus")

func plant():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "offset", Vector2(0, -5.0), .1)
	tween.tween_property(self, "offset", Vector2(0, -8.0), .1)
	print("do_plant")
	
	
func not_focus():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "offset", Vector2(0, 8), .3)
	print("not_focus")
	
func _on_area_2d_mouse_entered():
	focus()

func _on_area_2d_mouse_exited():
	not_focus()
