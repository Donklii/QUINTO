extends Node

var protagonista: Protagonista
var lista_de_acao: Array[Personagem] = []
var dono_do_turno: Personagem
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


signal pronto

signal comeco_da_acao
signal fim_da_acao

signal comeco_do_turno
signal fim_do_turno

signal morte
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
		comeco_do_turno.emit()
		await Global.create_and_start_timer(2,self)
		personagem.agir(personagem.MaxDeAcoes)
		
		await personagem.acabou_turno
		fim_do_turno.emit()
		print("mudando turno\n")
		await Global.create_and_start_timer(1,self)
	
	await get_tree().process_frame
	gerenciarAcoes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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


func _on_comeco_da_acao() -> void:
	fade_dos_quadrantes()


func fade_dos_quadrantes():
	for filho in get_children():
		if filho is Quadrante:
			if filho.calcularDistanciaDoAtual() > 10:
				var cor: float = exp(-0.3 * filho.calcularDistanciaDoAtual())
				filho.mudarTransparencia(cor)
			else:
				filho.mudarTransparencia(0.25)

func _on_comeco_do_turno() -> void:
	fade_dos_quadrantes()


func _on_morte(personagem: Personagem) -> void:
	if personagem in lista_de_acao:
		lista_de_acao.erase(personagem)
	
	resetar_rastros.emit(personagem)
	
	personagem.quadranteAtual.desocupar()
