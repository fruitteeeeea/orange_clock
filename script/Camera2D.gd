extends Camera2D

@export var initial_zoom = Vector2(3, 3)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.zoom = initial_zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func do_zoom(zoom_factor:Vector2):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "zoom", zoom_factor, .1)
