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
		if Engine.time_scale > 8:
			Engine.time_scale = 8
	elif Input.is_action_just_pressed("diminuirvelocidade"):
		Engine.time_scale /= 2
		if Engine.time_scale < 0.25:
			Engine.time_scale = 0.25
	
	$Label2.text = str(Engine.time_scale) + "x"
	if get_tree().paused:
		$Label.visible = true
	else:
		$Label.visible = false
	
	if Input.is_action_pressed("D"):
		get_tree().current_scene.cameraMov.x += 10
	elif Input.is_action_pressed("A"):
		get_tree().current_scene.cameraMov.x -= 10
	if Input.is_action_pressed("W"):
		get_tree().current_scene.cameraMov.y -= 10
	elif Input.is_action_pressed("S"):
		get_tree().current_scene.cameraMov.y += 10
