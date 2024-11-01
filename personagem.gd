extends CharacterBody2D
class_name Personagem


var rastrosDeixados: Array[Rastro] = []
var rastrosDesejados: Array[String] = []

var turnoAtual: bool = false
var MaxDeAcoes: int = 2
var movendo: bool = false
var quadranteAtual: Quadrante = null
var rastro_mais_longo: Rastro
var disntacia_do_maior_rastro: int = 0

@onready var game_manager: Node = $".."

signal causou_dano
signal tomou_dano
signal matou
signal morreu

signal acabou_acao
signal acabou_turno


func set_rastrosDesejados() -> void:
	pass
func set_rastrosDeixados() -> void:
	pass




func _ready() -> void:
	await game_manager.pronto
	set_quadrante()
	set_rastrosDeixados()
	set_rastrosDesejados()
	calcularDistanciaDoMaiorRastro()

## ⎯⎯⎯⎯⎯  𝌅 🌲 ÁRVORE DE DECISÃO 🌲 𝌅  ⎯⎯⎯⎯⎯


func agir(Acoes: int) -> void:
	turnoAtual = true
	
	game_manager.comeco_da_acao.emit()
	
	await decidirAcao()
	
	acabou_acao.emit()
	game_manager.fim_da_acao.emit()
	
	await Global.create_and_start_timer(0.5, self)
	
	if Acoes > 1:
		agir(Acoes-1)
	else:
		finalizarTurno()


func finalizarTurno():
	acabou_turno.emit()


func decidirAcao() -> void:
	var inimigoProximo: Personagem = detectarInimigos()
	
	if inimigoProximo:
		await causarDano(inimigoProximo)
		return
	
	var quadrantebusca: Quadrante = buscarQuadrante()
	
	if quadrantebusca and not movendo:
		await mover_ate_quadrante(quadrantebusca)
		return


func detectarInimigos() -> Personagem:
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if quadrante_proximo:
			if quadrante_proximo.ocupado and quadrante_proximo.donoAtual:
				if self is Inimigo:
					if quadrante_proximo.donoAtual is Protagonista:
						return quadrante_proximo.donoAtual
				elif self is Protagonista:
					if quadrante_proximo.donoAtual is Inimigo:
						return quadrante_proximo.donoAtual
	return null


func buscarQuadrante() -> Quadrante:
	var forca: int = 0
	
	for rastro in quadranteAtual.lista_de_rastros:
			if rastro.nome in rastrosDesejados and rastro.forca > forca:
				forca = rastro.forca
	
	var quadranteDesejado: Quadrante = null
	
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if quadrante_proximo:
			if not quadrante_proximo.ocupado:
				for rastro in quadrante_proximo.lista_de_rastros:
						if rastro.nome in rastrosDesejados and rastro.forca > forca:
							quadranteDesejado = quadrante_proximo
							forca = rastro.forca
	
	return quadranteDesejado


##⇀ ⇀ ⇀ ⇀ ⇀ ➤ M O V I M E N T A Ç Ã O ➤ ⇀ ⇀ ⇀ ⇀ ⇀

func mover(alvo: Vector2, velocidade: int, proximidade: float = 4) -> void:
	
	movendo = true
	
	while (alvo.distance_to(global_position) > proximidade):
		var direction = (alvo - global_position).normalized()
		
		velocity = direction * velocidade
		
		move_and_slide()
		await get_tree().process_frame
	
	velocity = Vector2(0,0)
	movendo = false



func mover_ate_quadrante(quadrantebusca: Quadrante) -> void:
	
	quadrantebusca.mudarCor(Color(0,1,0,1))
	
	await mover(quadrantebusca.global_position, 30,2)
	
	
	global_position = quadrantebusca.global_position
	
	
	await get_tree().process_frame
	
	quadrantebusca.mudarCor(Color(1,1,1,0.25))
	
	await quadrantebusca.ocupar(self)


##✹✹✹✹✹✹✹✹✹✹✹✹✹  C ⊛ M B A T E ✹✹✹✹✹✹✹✹✹✹✹✹✹


func mostrarDano(dano: int) -> void:
	var numeroFlutuante = Label.new()
	numeroFlutuante.text = str(dano)
	
	
	var cor: int = 255-(dano*15)
	numeroFlutuante.self_modulate = Color(255,cor,0)
	
	add_child(numeroFlutuante)
	numeroFlutuante.global_position = get_node("AnimatedSprite2D").global_position + Vector2(0,-20)
	
	var tempo: float = 5
	var velocidade: Vector2 = Vector2(0,-randi_range(20,40))
	
	while tempo > 0:
		tempo -= get_process_delta_time()
		
		numeroFlutuante.modulate.a -= 0.02
		numeroFlutuante.global_position += velocidade * get_process_delta_time()
		await get_tree().process_frame
	
	numeroFlutuante.queue_free()


func take_damage(dano: int, tipo: String = "", culpa: Personagem = null) -> void:
	print("dano")
	set_meta("Hp",get_meta("Hp") - dano)
	mostrarDano(dano)
	
	if get_meta("Hp") < 1:
		morrer()
		if culpa:
			culpa.matou.emit()
		
	tomou_dano.emit()


func morrer() -> void:
	game_manager.morte.emit(self)
	
	await get_tree().process_frame
	
	queue_free()


func causarDano(alvo: Personagem) -> void:
	var quadrante_do_alvo: Quadrante = alvo.quadranteAtual
	quadrante_do_alvo.mudarCor(Color(1,0.2,0,1))
	
	await mover(alvo.global_position, 40)
	
	alvo.take_damage(get_meta("Dano"))
	causou_dano.emit()
	
	
	await mover(quadranteAtual.global_position, 15,2)
	
	global_position = quadranteAtual.global_position
	quadrante_do_alvo.mudarCor(Color(1,1,1,0.25))


##✧✧✧  𝕌𝕋𝕀𝕃𝕊 ✧✧✧


func configurarQuadrante() -> void:
	await get_tree().process_frame
	for rastro in rastrosDeixados:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.copiar(rastro)
		
		quadranteAtual.adicionar_rastro(rastronovo)

func calcularDistanciaDoMaiorRastro() -> void:
	for rastro in rastrosDeixados:
		if rastro_mais_longo == null:
			rastro_mais_longo = rastro
		if  calcularDistanciaDoRastro(rastro) >  calcularDistanciaDoRastro(rastro_mais_longo):
			rastro_mais_longo = rastro
	
	disntacia_do_maior_rastro = calcularDistanciaDoRastro(rastro_mais_longo)

func calcularDistanciaDoRastro(rastro: Rastro) -> int:
	return rastro.forca/rastro.decaimento


func set_quadrante() -> void:
	var quadranteDesejado: Quadrante = null
	for quadrante in $Area2D.get_overlapping_bodies():
		if quadrante is Quadrante:
			if not quadrante.ocupado:
				if not quadranteDesejado:
					quadranteDesejado = quadrante
				elif global_position.distance_to(quadranteDesejado.global_position) > global_position.distance_to(quadrante.global_position):
					quadranteDesejado = quadrante
	
	global_position = quadranteDesejado.global_position
	await quadranteDesejado.ocupar(self)
	$Area2D.queue_free()
