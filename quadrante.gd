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
		await ocupante.quadranteAtual.desocupar()
	
	donoAtual = ocupante
	donoAtual.quadranteAtual = self
	
	for rastro in lista_de_rastros:
		if not rastro.passa_por_personagem and rastro.emissor != ocupante:
			var salvo: Personagem = rastro.emissor
			
			var rastroNovo: Rastro = Rastro.new()
			rastroNovo.copiar(rastro)
			rastroNovo.forca += rastroNovo.decaimento
			apagar_restos_de_rastro(rastroNovo)
			
			apagar_rastro(rastro)
			rastroNovo.queue_free()
			
			salvo.configurarQuadrante()
	
	donoAtual.configurarQuadrante()

func apagar_restos_de_rastro(rastro: Rastro):
	var rastroDecendente: Rastro = tem_residuos_do_rastro(rastro)
	
	if !rastroDecendente:
		return
	
	if not (rastroDecendente.forca - rastroDecendente.decaimento > 0):
		apagar_rastro(rastroDecendente)
		return
	
	for i in range(0,4):
		var quadrante_desejado: Quadrante = quadranteAoLado(i)
		
		if quadrante_desejado:
			
			if quadrante_desejado.tem_residuos_do_rastro(rastro):
				quadrante_desejado.apagar_restos_de_rastro(rastroDecendente)
	
	apagar_rastro(rastroDecendente)

func desocupar() -> void:
	ocupado = false
	
	for rastroDeixado in donoAtual.rastrosDeixados:
		var rastro: Rastro = Rastro.new()
		rastro.copiar(rastroDeixado)
		rastro.forca += rastro.decaimento
		await apagar_restos_de_rastro(rastro)
	
	donoAtual = null


func _ready() -> void:
	game_manager.connect("apagar_rastro", Callable(self, "remover_rastro"))
	game_manager.connect("resetar_rastros", Callable(self, "remover_rastros_por_emissor"))


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


func remover_rastros_por_emissor(emissor: Personagem) -> void:
	
	if lista_de_rastros.size() < 1:
		return
	
	
	for rastroPresente in lista_de_rastros:
		
		if rastroPresente.emissor == emissor:
			apagar_rastro(rastroPresente)


func remover_rastro(rastro: Rastro):
	var rastroPresente: Rastro = tem_rastro(rastro)
	
	if rastroPresente:
		apagar_rastro(rastroPresente)


func remover_todos_os_rastros():
	for rastro in lista_de_rastros:
		lista_de_rastros.erase(rastro)
		rastro.queue_free()


func apagar_rastro(rastro: Rastro):
	lista_de_rastros.erase(rastro)
	rastro.queue_free()




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

func tem_rastro(rastro: Rastro) -> Rastro:
	for rastroAtual in lista_de_rastros:
		if rastroAtual.nome == rastro.nome and rastroAtual.emissor == rastro.emissor:
			return rastroAtual
	
	return null

func tem_residuos_do_rastro(rastro: Rastro) -> Rastro:
	for rastroAtual in lista_de_rastros:
		if rastro.nome == rastroAtual.nome and rastro.emissor == rastroAtual.emissor:
			if rastro.forca > rastroAtual.forca:
				return rastroAtual
	
	return null


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


func calcularDistanciaDoAlvo(alvo: Personagem = game_manager.dono_do_turno) -> int:
	var quadranteAlmejado: Quadrante =  alvo.quadranteAtual
	
	var distancia: int = abs(global_position.x - quadranteAlmejado.global_position.x)
	distancia += abs(global_position.y - quadranteAlmejado.global_position.y)
	
	distancia /= 16
	
	return distancia
