extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pausa"):
		get_tree().paused = !get_tree().paused
	
	if Input.is_action_just_pressed("aumentarvelocidade"):
		Engine.time_scale *= 2
	elif Input.is_action_just_pressed("diminuirvelocidade"):
		Engine.time_scale /= 2
	
	$Label2.text = str(Engine.time_scale) + "x"
	if get_tree().paused:
		$Label.visible = true
	else:
		$Label.visible = false
