extends Node

var protagonista: Protagonista

signal fim_da_acao
signal fim_do_turno
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	protagonista = get_node("Protagonista")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Camera2D.global_position = $Protagonista.global_position
	
	for filho in get_children():
		if !is_instance_valid(filho):
			return
		if filho.global_position.distance_to(protagonista.global_position) > 200:
			filho.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			filho.process_mode = Node.PROCESS_MODE_INHERIT
