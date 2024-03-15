extends Sprite2D

@export var initial_position: Vector2 = Vector2(80, -60)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = initial_position
	pass # Replace with function body.

func move_cursor(position):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", position, .1)
	await tween.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
