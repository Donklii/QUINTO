extends Node2D
class_name Quadrante

var posicao: Vector2
var quadrante_matrix: Array[Array]

var lista_de_rastros: Array[Rastro] = []


var ocupado: bool = false
var donoAtual: Personagem = null


@onready var game_manager = $".."


func ocupar(ocupante: Personagem) -> void:
	ocupado = true
	
	if ocupante.quadranteAtual:
		ocupante.quadranteAtual.desocupar()
	
	donoAtual = ocupante
	donoAtual.quadranteAtual = self
	
	var lista: Array[Personagem] = []
	for rastro in lista_de_rastros:
		if not rastro.passa_por_personagem and rastro.emissor != ocupante:
			if not rastro.emissor in lista:
				lista.append(rastro.emissor)
	
	for personagem in lista:
		game_manager.resetar_rastros.emit(personagem)
		await get_tree().process_frame
		personagem.configurarQuadrante()
	
	donoAtual.configurarQuadrante()


func desocupar() -> void:
	ocupado = false
	donoAtual = null


func _ready() -> void:
	game_manager.connect("resetar_rastros", Callable(self, "remover_rastros"))


##➳➳➳ 𝐹𝑈𝑁𝐶̧𝑂̃𝐸𝑆 𝐵𝐴𝑆𝐸 ➳➳➳


func adicionar_rastro(rastroNovo:Rastro) -> void:
	if ocupado:
		if donoAtual != rastroNovo.emissor and not rastroNovo.passa_por_personagem:
			rastroNovo.queue_free()
			return
	
	for rastroatual in lista_de_rastros:
		if rastroatual.equals(rastroNovo):
			rastroNovo.queue_free()
			return
			
		elif rastroatual.nome == rastroNovo.nome and rastroatual.emissor == rastroNovo.emissor:
			
			if  rastroatual.forca >= rastroNovo.forca:
				rastroNovo.queue_free()
				return
			else:
				rastroatual.forca = rastroNovo.forca
				rastroNovo.queue_free()
				espalhar_rastros()
				return
	
	lista_de_rastros.append(rastroNovo)
	
	espalhar_rastros()


func remover_rastros(emissor: Personagem) -> void:
	
	for rastropresente in lista_de_rastros:
		
		if rastropresente.emissor == emissor:
			lista_de_rastros.erase(rastropresente)
			rastropresente.queue_free()


func remover_todos_os_rastros():
	lista_de_rastros.clear()


func espalhar_rastros()  -> void:
	if lista_de_rastros.size() < 1:
		return
	
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAoLado(i)
		
		if quadrante_proximo:
			for rastro in lista_de_rastros:
				
				if rastro.forca - rastro.decaimento > 0 and is_instance_valid(rastro.emissor):
					
					var rastroNovo = Rastro.new()
					rastroNovo.copiar(rastro)
					rastroNovo.forca -= rastro.decaimento
					
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

func mudarCor(cor: Color) -> void:
	$AnimatedSprite2D.modulate = cor

func mudarTransparencia(a: float) -> void:
	$AnimatedSprite2D.modulate.a = a

func _on_mouse_entered() -> void:
	mudarCor(Color(0,0,1,1))
	$Label.text = "Ocuapdo: " + str(ocupado)
	for rastro in lista_de_rastros:
		$Label.text += str(str("\n")+str("Rastro: ")+str(rastro.nome)+str(" Força: ")+str(rastro.forca))
	$Label.visible = true
	


func _on_mouse_exited() -> void:
	mudarCor(Color(1,1,1,0.25))
	$Label.visible = false


func adicionar_rastro_com_click()  -> void:
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


func calcularDistanciaDoAtual() -> int:
	var quadranteAlmejado: Quadrante =  game_manager.dono_do_turno.quadranteAtual
	
	var distancia: int = abs(global_position.x - quadranteAlmejado.global_position.x)
	distancia += abs(global_position.y - quadranteAlmejado.global_position.y)
	
	distancia /= 16
	
	return distancia
