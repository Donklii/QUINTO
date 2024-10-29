extends Node

var protagonista: Protagonista
var lista_de_acao: Array[Personagem] = []
var alvo_da_camera: Personagem

signal pronto
signal fim_da_acao
signal fim_do_turno
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	protagonista = get_node("Protagonista")
	lista_de_acao.append(protagonista)
	lista_de_acao.append(get_node("Inimigo"))
	await pronto
	await get_tree().process_frame
	gerenciarAcoes()

func gerenciarAcoes():
	for personagem in lista_de_acao:
		alvo_da_camera = personagem
		print(str("turno de ") + str(personagem.name))
		await get_tree().create_timer(2).timeout
		personagem.agir(personagem.MaxDeAcoes)
		
		await personagem.acabou_turno
		print("mudando turno")
		await get_tree().create_timer(2).timeout
	
	await get_tree().process_frame
	gerenciarAcoes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if alvo_da_camera and is_instance_valid(alvo_da_camera):
		$Camera2D.global_position = alvo_da_camera.global_position
	else:
		alvo_da_camera = null
	
	for filho in get_children():
		if !is_instance_valid(filho) or not filho is Node2D:
			pass
		elif filho.global_position.distance_to($Camera2D.global_position) > 300:
			filho.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			filho.process_mode = Node.PROCESS_MODE_INHERIT
