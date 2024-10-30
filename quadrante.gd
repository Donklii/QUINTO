extends Node2D
class_name Quadrante

var posicao: Vector2
var quadrante_matrix: Array[Array]

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

func _ready() -> void:
	game_manager.connect("resetar_rastros", Callable(self, "remover_todos_os_rastros"))


##➳➳➳ 𝐹𝑈𝑁𝐶̧𝑂̃𝐸𝑆 𝐵𝐴𝑆𝐸 ➳➳➳


func adicionar_rastro(rastroNovo:Rastro) -> void:
	for rastroatual in lista_de_rastros:
		if rastroatual.equals(rastroNovo):
			return
			
		elif rastroatual.nome == rastroNovo.nome and rastroatual.emissor == rastroNovo.emissor:
			
			if  rastroatual.forca >= rastroNovo.forca:
				return
			else:
				rastroatual.forca = rastroNovo.forca
				espalhar_rastros()
				return
	
	lista_de_rastros.append(rastroNovo)
	espalhar_rastros()


func remover_todos_os_rastros(emissor: Personagem) -> void:
	if lista_de_rastros.size() < 1:
		return
	
	for rastropresente in lista_de_rastros:
		
		if rastropresente.emissor == emissor:
			lista_de_rastros.erase(rastropresente)


func espalhar_rastros()  -> void:
	if lista_de_rastros.size() < 1:
		return
	
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAoLado(i)
		
		if quadrante_proximo:
			for rastro in lista_de_rastros:
				
				if rastro.forca - rastro.decaimento > 0:
					
					var rastroNovo = Rastro.new()
					rastroNovo.forca = rastro.forca - rastro.decaimento
					rastroNovo.nome = rastro.nome
					rastroNovo.decaimento = rastro.decaimento
					rastroNovo.emissor = rastro.emissor
					
					quadrante_proximo.adicionar_rastro(rastroNovo)


func quadranteAoLado(indice: int) -> Quadrante:
	var quadrante_proximo: Quadrante
	match indice:
			0:
				if quadrante_matrix.size() > posicao.x:
					quadrante_proximo = quadrante_matrix[posicao.x+1][posicao.y]
			1:
				if quadrante_matrix[posicao.x].size() > posicao.y:
					quadrante_proximo = quadrante_matrix[posicao.x][posicao.y+1]
				
			2:
				if posicao.x > 0:
					quadrante_proximo = quadrante_matrix[posicao.x-1][posicao.y]
			3:
				if posicao.y > 0:
					quadrante_proximo = quadrante_matrix[posicao.x][posicao.y-1]
	
	return quadrante_proximo



##✧✧✧  𝕌𝕋𝕀𝕃𝕊 ✧✧✧


func estaNoLimite():
	
	var quadranteAlmejado: Quadrante =  game_manager.dono_do_turno.quadranteAtual
	var distancia: int = abs(global_position.x - quadranteAlmejado.global_position.x)
	distancia += abs(global_position.y - quadranteAlmejado.global_position.y)
	
	distancia /= 16
	
	if (
		distancia > 
		game_manager.dono_do_turno.disntacia_do_maior_rastro
		):
		return false
	else:
		return true


func _on_mouse_entered() -> void:
	if Input.is_action_just_pressed("botaoesquerdo"):
		adicionar_rastro_com_click()
		
	elif Input.is_action_just_pressed("botaodireito"):
		if donoAtual:
			donoAtual.take_damage(5, "oioio", null)
			print(posicao)
			print(str("\nEsta no Limite: ")+ str(estaNoLimite()))
		
	modulate = Color(0,0,1,1)
	$Label.text = ""
	for rastro in lista_de_rastros:
		$Label.text += str(str("\n")+str("Rastro: ")+str(rastro.nome)+str(" Força: ")+str(rastro.forca))
	$Label.visible = true
	


func _on_mouse_exited() -> void:
	modulate = Color(1,1,1,1)
	$Label.visible = false


func adicionar_rastro_com_click():
	var temrastrotest: bool = false
	for rastroinspec in lista_de_rastros:
		if rastroinspec.nome == "test":
			temrastrotest = true
			rastroinspec.forca += 150
		
	if not temrastrotest:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.nome = "test"
		rastronovo.decaimento = 50
		rastronovo.forca = 150
		adicionar_rastro(rastronovo)
	
	espalhar_rastros()


#func calcularDistanciaDoLimite() -> int:
#	var quadranteAlmejado: Quadrante =  game_manager.dono_do_turno.quadranteAtual
#	var distancia: int = abs(global_position.x - quadranteAlmejado.global_position.x)
#	distancia += abs(global_position.y - quadranteAlmejado.global_position.y)
#	
#	distancia /= 16
#	
#	return distancia - game_manager.dono_do_turno.disntacia_do_maior_rastro
