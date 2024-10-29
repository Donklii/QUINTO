extends Node2D
class_name Quadrante

var lista_de_rastros: Array[Rastro] = []
var ocupado: bool = false
var donoAtual: Personagem = null

@onready var game_manager = $".."

signal espalhar

func ocupar(ocupante: Personagem) -> void:
	ocupado = true
	donoAtual = ocupante

func desocupar():
	ocupado = false
	donoAtual = null

func reparar():
	for rastroPrimario in lista_de_rastros:
		for rastroatual in lista_de_rastros:
			if rastroatual == rastroPrimario:
				pass
			elif rastroatual.nome == rastroPrimario.nome:
				if rastroatual.forca > rastroPrimario.forca:
					lista_de_rastros.erase(rastroPrimario)
				else:
					lista_de_rastros.erase(rastroatual)


func mouse_esta_em_cima() -> bool:
	if (
		(abs(get_global_mouse_position().x - global_position.x) <= 8) and 
		(abs(get_global_mouse_position().y - global_position.y) <= 8)
		):
			return true
	else:
		return false


func adicionar_rastro_com_click():
	var temrastrodeviado: bool = false
	for rastroinspec in lista_de_rastros:
		if rastroinspec.nome == "viado":
			temrastrodeviado = true
			rastroinspec.forca += 150
		
	if not temrastrodeviado:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.nome = "viado"
		rastronovo.decaimento = 50
		rastronovo.forca = 150
		adicionar_rastro(rastronovo)
	
	espalhar_rastros()

func _ready() -> void:
	game_manager.connect("resetar_rastros", Callable(self, "remover_todos_os_rastros"))

func _process(delta: float) -> void:
	if mouse_esta_em_cima():
		if Input.is_action_just_pressed("botaoesquerdo"):
			adicionar_rastro_com_click()
		
		elif Input.is_action_just_pressed("botaodireito"):
			if donoAtual:
				donoAtual.take_damage(5, "oioio", null)
			print(str("\nEsta no Limite: ")+ str(estaNoLimite()))
		
		modulate = Color(0,0,1,1)
		$Label.text = ""
		for rastro in lista_de_rastros:
			$Label.text += str(str("\n")+str("Rastro: ")+str(rastro.nome)+str(" Força: ")+str(rastro.forca))
		$Label.visible = true
	else:
		modulate = Color(1,1,1,1)
		$Label.visible = false


func adicionar_rastro(rastroNovo:Rastro) -> void:
	for rastroatual in lista_de_rastros:
		if rastroatual.equals(rastroNovo):
			return
			
		elif rastroatual.nome == rastroNovo.nome:
			
			if rastroNovo.forca <= rastroatual.forca:
				return
			else:
				rastroatual.forca = rastroNovo.forca
				break
	
	lista_de_rastros.append(rastroNovo)
	reparar()
	espalhar_rastros()


func remover_todos_os_rastros(rastrosDeixados: Array[Rastro]) -> void:
	if lista_de_rastros.size() < 0:
		return
	
	for rastro in rastrosDeixados:
		for rastropresente in lista_de_rastros:
			if rastro.nome == rastropresente.nome:
				lista_de_rastros.erase(rastropresente)


func espalhar_rastros()  -> void:
	if lista_de_rastros.size() < 1:
		return
	
	for quadrante_proximo in $Area2D.get_overlapping_bodies():
		
		if quadrante_proximo is Quadrante and quadrante_proximo != self:
			
			for rastro in lista_de_rastros:
				
				if rastro.forca - rastro.decaimento > 0:
					
					var rastroNovo = Rastro.new()
					rastroNovo.forca = rastro.forca - rastro.decaimento
					rastroNovo.nome = rastro.nome
					rastroNovo.decaimento = rastro.decaimento
					
					quadrante_proximo.adicionar_rastro(rastroNovo)

func estaNoLimite():
	print(str("\n\nDistancia até o player: ")+str(global_position.distance_to(game_manager.dono_do_turno.global_position))+str("\nDistancia até do mrastro: ")+str(game_manager.dono_do_turno.disntacia_do_maior_rastro*16))
	if (
		global_position.distance_to(game_manager.dono_do_turno.global_position) > 
		game_manager.dono_do_turno.disntacia_do_maior_rastro*16
		):
		return false
	else:
		return true
