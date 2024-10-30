extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func framefreeze(duracao: float) -> void:
	Engine.time_scale = 0
	await get_tree().create_timer(duracao, true, false, true).timeout
	Engine.time_scale = 1


func create_and_start_timer(duration, dono):
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.autostart = true
	dono.add_child(timer)
	await timer.timeout
	timer.queue_free()
	return
