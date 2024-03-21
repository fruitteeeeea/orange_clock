extends Timer

@onready var timer = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print_debug(self.time_left)
	pass


func _on_button_pressed():
	timer.start()
	pass # Replace with function body.


func _on_button_2_pressed():
	timer.paused = true
	pass # Replace with function body.



func _on_button_4_pressed():
	timer.paused = false
	pass # Replace with function body.
	


func _on_button_3_pressed():
	timer.stop()
	pass # Replace with function body.
