extends CharacterBody2D
class_name Personagem


var rastrosDeixados: Array[Rastro] = []
var rastrosDesejados: Array[String] = []

var turnoAtual: bool = false
var MaxDeAcoes: int = 2
var movendo: bool = false
var quadranteAtual: Quadrante = null

signal tomou_dano
signal causou_dano

signal acabou_acao
signal acabou_turno


func set_rastrosDesejados():
	pass
func set_rastrosDeixados():
	pass

func set_quadrante():
	var quadranteDesejado: Quadrante
	for quadrante in $Area2D.get_overlapping_bodies():
		if quadrante is Quadrante:
			if not quadrante.ocupado:
				if not quadranteDesejado:
					quadranteDesejado = quadrante
				elif global_position.distance_to(quadranteDesejado.global_position) > global_position.distance_to(quadrante.global_position):
					quadranteDesejado = quadrante
	
	global_position = quadranteDesejado.global_position
	quadranteDesejado.ocupar(self)
	quadranteAtual = quadranteDesejado

func _ready() -> void:
	await get_parent().pronto
	set_quadrante()
	set_rastrosDeixados()
	set_rastrosDesejados()
	configurarQuadrante()
	get_parent().connect("fim_da_acao", Callable(self, "configurarQuadrante"))

func detectarInimigos() -> Personagem:
	for quadrante in $Area2D.get_overlapping_bodies():
		if quadrante is Quadrante:
			if quadrante.ocupado and quadrante.donoAtual and quadrante != quadranteAtual:
				if self is Inimigo:
					if quadrante.donoAtual is Protagonista:
						return quadrante.donoAtual
				elif self is Protagonista:
					if quadrante.donoAtual is Inimigo:
						return quadrante.donoAtual
	return null


func decidirAcao():
	var inimigoProximo: Personagem = detectarInimigos()
	
	if inimigoProximo:
		await causarDano(inimigoProximo)
		return
	
	var quadrantebusca: Quadrante = buscarQuadrante()
	
	if quadrantebusca and not movendo:
		await mover_ate_quadrante(quadrantebusca)
		return

func agir(Acoes: int) -> void:
	turnoAtual = true
	
	await decidirAcao()
	
	acabou_acao.emit()
	get_parent().fim_da_acao.emit()
	
	if Acoes > 1:
		await Global.create_and_start_timer(1, self)
		agir(Acoes-1)
	else:
		acabou_turno.emit()
		get_parent().fim_do_turno.emit()


func mostrarDano(dano: int) -> void:
	var numeroFlutuante = Label.new()
	numeroFlutuante.text = str(dano)
	
	
	var cor: int = 255-(dano*10)
	numeroFlutuante.self_modulate = Color(255,0,0)
	numeroFlutuante.self_modulate.g = cor
	
	numeroFlutuante.global_position = get_node("AnimatedSprite2D").global_position + Vector2(10,-20)
	add_child(numeroFlutuante)
	
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
	tomou_dano.emit()

func morrer():
	quadranteAtual.desocupar()
	
	if self in get_parent().lista_de_acao:
		get_parent().lista_de_acao.erase(self)
	
	queue_free()

func causarDano(alvo: Personagem):
	#movendo = true
	
	#while global_position.distance_to(alvo.global_position) < 40:
	#	print("1")
	#	var direction = (alvo.global_position - global_position).normalized()
	#	velocity = direction * 40
	#	move_and_slide()
	#	await get_tree().process_frame
	
	#while global_position.distance_to(alvo.global_position) > 5:
	#	print("2")
	#	var direction = (global_position -alvo.global_position ).normalized()
	#	velocity = direction * 80
	#	move_and_slide()
	#	await get_tree().process_frame
	
	alvo.take_damage(get_meta("Dano"))
	causou_dano.emit()
	
	
	#while quadranteAtual.global_position.distance_to(global_position) > 3:
	#	print("3")
	#	var direction = (quadranteAtual.global_position - position).normalized()
	#	velocity = direction * 50
	#	
	#	move_and_slide()
	#	await get_tree().process_frame
	
	#movendo = false
	#velocity = Vector2(0,0)
	#global_position = quadranteAtual.global_position


func buscarQuadrante() -> Quadrante:
	var forca: int = 0
	
	for rastro in quadranteAtual.lista_de_rastros:
		if rastro.nome in rastrosDesejados and rastro.forca > forca:
			forca = rastro.forca
	
	var quadranteDesejado: Quadrante = null
	
	for quadrante in $Area2D.get_overlapping_bodies():
		if quadrante is Quadrante:
			if not quadrante.ocupado:
				
				for rastro in quadrante.lista_de_rastros:
					if rastro.nome in rastrosDesejados:
						if rastro.forca > forca:
							quadranteDesejado = quadrante
							forca = rastro.forca
	
	return quadranteDesejado


func mover_ate_quadrante(quadrantebusca: Quadrante) -> void:
	movendo = true
	quadranteAtual.desocupar()
	
	while quadrantebusca.global_position.distance_to(global_position) > 3:
		var direction = (quadrantebusca.global_position - position).normalized()
		velocity = direction * 50
		
		move_and_slide()
		await get_tree().process_frame
	
	velocity = Vector2(0,0)
	global_position = quadrantebusca.global_position
	movendo = false
	
	quadrantebusca.ocupar(self)
	quadranteAtual = quadrantebusca


func configurarQuadrante():
	await get_tree().process_frame
	for rastro in rastrosDeixados:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.nome = rastro.nome
		rastronovo.decaimento = rastro.decaimento
		rastronovo.forca = rastro.forca
		quadranteAtual.adicionar_rastro(rastronovo)
