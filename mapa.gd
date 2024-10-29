extends Node

var protagonista: Protagonista
var lista_de_acao: Array[Personagem] = []
var dono_do_turno: Personagem

signal pronto
signal fim_da_acao
signal fim_do_turno
signal resetar_rastros

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	protagonista = get_node("Protagonista")
	await pronto
	await get_tree().process_frame
	adicionarListaDeAcoes()
	gerenciarAcoes()

func adicionarListaDeAcoes() -> void:
	for filho in get_children():
		if filho is Personagem:
			lista_de_acao.append(filho)

func gerenciarAcoes() -> void:
	for personagem in lista_de_acao:
		dono_do_turno = personagem
		
		print(str("turno de ") + str(personagem.name))
		await get_tree().create_timer(2).timeout
		personagem.agir(personagem.MaxDeAcoes)
		
		await personagem.acabou_turno
		fim_do_turno.emit()
		print("mudando turno")
		await get_tree().create_timer(2).timeout
	
	await get_tree().process_frame
	gerenciarAcoes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dono_do_turno and is_instance_valid(dono_do_turno):
		$Camera2D.global_position = dono_do_turno.global_position
	else:
		dono_do_turno = null



func desativarQuadrantesLonges() -> void:
	for filho in get_children():
		if filho is Quadrante:
			if filho.estaNoLimite():
				filho.process_mode = Node.PROCESS_MODE_INHERIT
			else:
				filho.process_mode = Node.PROCESS_MODE_DISABLED


func _on_fim_da_acao() -> void:
	pass # Replace with function body.
