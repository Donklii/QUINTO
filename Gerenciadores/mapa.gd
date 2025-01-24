extends Node
class_name GameManager

var protagonista: Protagonista
var lista_de_acao: Array[Personagem] = []
var dono_do_turno: Personagem

var cameraMov: Vector2 = Vector2(0,0)
var cameraPos: Vector2
var quadrante_matrix: Array[Array] = []

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

signal pronto

signal comeco_da_acao
signal fim_da_acao

signal comeco_do_turno
signal fim_do_turno

signal morte
signal resetar_rastros
signal apagar_rastro

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	protagonista = get_node("Protagonista")
	await pronto
	await get_tree().process_frame
	await adicionarListaDeAcoes()
	gerenciarAcoes()

func adicionarListaDeAcoes() -> void:
	await get_tree().process_frame
	if not is_instance_valid(protagonista):
		return
	for filho in get_children():
		if filho is Personagem and not filho in lista_de_acao and is_instance_valid(filho):
			if not filho.quadranteAtual or filho.get_meta("Hp") < 1:
				await get_tree().process_frame
				adicionarListaDeAcoes()
				return
			elif (filho.quadranteAtual.setor == protagonista.quadranteAtual.setor or
			filho.ativo or
			filho.quadranteAtual.setor in protagonista.quadranteAtual.setoresAdjacentes
			):
				lista_de_acao.append(filho)
				filho.ativo = true

func gerenciarAcoes() -> void:
	for personagem in lista_de_acao:
		dono_do_turno = personagem
		
		if not esta_movendo_a_camera():
			cameraMov = Vector2(0,0)
		
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
	if not esta_movendo_a_camera():
		if dono_do_turno and is_instance_valid(dono_do_turno):
			$Camera2D.global_position = dono_do_turno.global_position + cameraMov
			cameraPos = $Camera2D.global_position - cameraMov
		else:
			dono_do_turno = null
	else:
		$Camera2D.global_position = cameraPos + cameraMov

func _on_fim_da_acao() -> void:
	adicionarListaDeAcoes()


func _on_comeco_da_acao() -> void:
	fade_dos_quadrantes()

func esta_movendo_a_camera() -> bool:
	return (Input.is_action_pressed("A") or
	Input.is_action_pressed("D") or 
	Input.is_action_pressed("W") or
	Input.is_action_pressed("S"))

func fade_dos_quadrantes():
	for filho in get_children():
		if filho is Quadrante:
			if filho.calcularDistanciaDoAlvo() > 10:
				var cor: float = exp(-0.3 * filho.calcularDistanciaDoAlvo())
				filho.mudarTransparencia(cor)
			else:
				filho.mudarTransparencia(0.25)

func _on_comeco_do_turno() -> void:
	fade_dos_quadrantes()


func _on_morte(personagem: Personagem) -> void:
	if personagem in lista_de_acao:
		lista_de_acao.erase(personagem)
