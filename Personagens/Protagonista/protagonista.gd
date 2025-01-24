extends Personagem
class_name Protagonista

var arvoreDeDecisao: Sequence

var valorDaVida: int = -100
var valorDoDano: int = -1

var direcao: int
var direcaoAnterior: int = -1
var ataqueBuffCd: bool = false

var level:int = 1
var xp: int = 0
var xpNecessario: int = 2

signal xp_aumentou
signal level_up

func set_rastrosDeixados():
	var rastronovo: Rastro = Rastro.new()
	rastronovo.nome = "stealth"
	rastronovo.decaimento = 5
	rastronovo.forca = 50
	rastronovo.emissor = self
	rastrosDeixados.append(rastronovo)
	
	var rastronovo2: Rastro = Rastro.new()
	rastronovo2.nome = "protagonista"
	rastronovo2.decaimento = 5
	rastronovo2.forca = 100
	rastronovo2.emissor = self
	rastronovo2.passa_por_personagem = false
	rastrosDeixados.append(rastronovo2)


func set_rastrosDesejados() -> void:
	rastrosDesejados = ["test", "tesouro", "inimigo"]

func agir(Acoes: int) -> void:
	turnoAtual = true
	
	acoesRestantes = Acoes
	
	game_manager.comeco_da_acao.emit()
	
	if game_manager.lista_de_acao.size() > 1:
		var profundidade = acoesRestantes+(game_manager.lista_de_acao.size()-1)*2-1
		await miniMax(profundidade)
	else:
		await arvore_de_decisao.execute()
	
	while not pronto_para_fim_da_acao:
		await get_tree().process_frame
	
	acabou_acao.emit()
	game_manager.fim_da_acao.emit()
	
	await Global.create_and_start_timer(0.5, self)
	
	
	if Acoes > 1:
		agir(Acoes-1)
	elif game_manager.lista_de_acao.size() < 2:
		agir(MaxDeAcoes)
	else:
		finalizarTurno()
		acoesRestantes = 0

func miniMax(profundidade: int):
	var acaoFinal: Acontecimento = Acontecimento.new("aa",-1000)
	var clonezin = PhantomProtagonista.new("0", self)
	
	for acao: String in clonezin.acoes:
		print("-------------Decisão Inicial: "+ acao + "-------------")
		var phantomManager = PhantomGameManager.new(game_manager, acao, profundidade, 0 ,acao)
		var decisao: Acontecimento = await phantomManager.miniMax()
		phantomManager.deletar()
		print("Valor de "+acao+": "+ str(decisao.valor) + " // Valor da decisão atual: " +str(acaoFinal.valor))
		if decisao.valor > acaoFinal.valor:
			print("Mudou Decisao")
			acaoFinal = decisao
	clonezin.desocupar()
	
	print("Acao: " + acaoFinal.acao + " - Vantagem: " + str(acaoFinal.valor))
	await call(acaoFinal.acao)
	print("------------------\nfim do pensamento\n------------------")


func atacar() -> void:
	var listaInimigos = detectarInimigos()
	
	if listaInimigos.is_empty(): return
	var inimigo_proximo: Personagem = detectarInimigos()[0]
	if inimigo_proximo:
		await causarDano(inimigo_proximo)


func mov() -> void:
	for personagem in game_manager.lista_de_acao:
		if personagem is Inimigo:
			await mover_ate_quadrante(melhor_proximo_passo(quadranteAtual.quadrante_matrix, personagem))
			return

func desviar() -> void:
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if !quadrante_proximo:
			continue
		
		if quadrante_proximo.ocupado:
			continue
		
		for j in range(0,4):
			var quadrante_distante: Quadrante = quadrante_proximo.quadranteAoLado(i)
			
			if !quadrante_distante:
				continue
			
			if quadrante_distante.ocupado:
				if quadrante_distante.donoAtual is Inimigo:
					continue
			
			mover_ate_quadrante(quadrante_proximo)
			return


func procurar_por_vida() -> void:
	#if get_meta("Hp") >= get_meta("MaxHp"):
	#	if "vida" in rastrosDesejados:
	#		rastrosDesejados.erase("vida")
	#	return
	
	var vidaAlvo: VidaDrop = null
	for i: Array[Quadrante] in quadranteAtual.quadrante_matrix:
		for quadrante: Quadrante in i:
			if !quadrante:
				continue
			
			if quadrante.entidade:
				if not vidaAlvo:
					vidaAlvo = quadrante.entidade
				if heuristica(quadranteAtual, vidaAlvo.quadranteAtual) > heuristica(quadranteAtual, quadrante):
					vidaAlvo = quadrante.entidade
	
	await mover_ate_quadrante(melhor_proximo_passo(quadranteAtual.quadrante_matrix, vidaAlvo))
	
	if quadranteAtual.entidade:
		if quadranteAtual.entidade is VidaDrop:
			quadranteAtual.entidade.usar(self)
			await Global.create_and_start_timer(1,self)
	#elif not "vida" in rastrosDesejados:
	#	rastrosDesejados.append("vida")

func escolher_direcao_aleatoria(jaforam: Array[int] = []):
	while direcao in jaforam or direcao == direcaoAnterior:
		direcao = randi_range(0,4)
	
	
	var quadrante_desejado: Quadrante = quadranteAtual.quadranteAoLado(direcao)
	if quadrante_desejado: 
		if !quadrante_desejado.ocupado:
			await mover_ate_quadrante(quadrante_desejado)
			
			direcaoAnterior = (direcao + 1)%4
			
			return
	
	jaforam.append(direcao)
	
	if jaforam.size() > 2 and direcaoAnterior >= 0:
		direcaoAnterior = -1
	
	if jaforam.size() > 3:
		return
	
	await escolher_direcao_aleatoria(jaforam)


func _on_acabou_acao() -> void:
	pass

func ataqueBuff():
	if !ataqueBuffCd:
		ataqueBuffCd = true
		set_meta("Dano", get_meta("Dano") + 2)
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://Imagens/pixil-frame-0 (18).png")
		subir(sprite)
		await Global.create_and_start_timer(1,self)
		recarregar()
		return true
	else:
		return false

func recarregar():
	await acabou_turno
	set_meta("Dano", get_meta("Dano") - 2)
	await acabou_turno
	ataqueBuffCd = false

func _on_matou(inimigo: Inimigo) -> void:
	print("matouuuu")
	xp += inimigo.xpDrop
	numeroFlutuante(Color(255,255,0),str("+"+ str(inimigo.xpDrop) +" Exp"))
	xp_aumentou.emit()


func _on_xp_aumentou() -> void:
	if xp >= xpNecessario:
		
		levelUp()
		xp -= xpNecessario
		await Global.create_and_start_timer(0.5,self)
		numeroFlutuante(Color(0,0,255),"Level Up")


func levelUp() -> void:
	level += 1
	
	pronto_para_fim_da_acao = false
	
	
	set_meta("MaxHp",get_meta("MaxHp")+1)
	
	match level:
		2:
			xpNecessario = 5
		3:
			xpNecessario = 12
		4:
			xpNecessario = 28
		5:
			xpNecessario = 100000
	
	level_up.emit(level)
	
	await $Ups.buff_escolhido
	
	pronto_para_fim_da_acao = true
	
	recuperar_vida(get_meta("MaxHp")-get_meta("Hp"))



func criar_arvore_decisao() -> Selector:
	var root_selector = Selector.new()
	
	var procurar_por_vida_action = Action.new()
	procurar_por_vida_action.set_function(self, "_procurar_por_vida")
	root_selector.add_child(procurar_por_vida_action)
	
	#--------------inimigo_sequence--------------
	var inimigo_sequence = Sequence.new()
	
	var detectar_inimigo_condition = Condition.new()
	detectar_inimigo_condition.set_function(self, "_detectar_inimigos")
	inimigo_sequence.add_child(detectar_inimigo_condition)
	
	var ataque_seletor = Selector.new()
	
	var ataque_buff_action = Action.new()
	ataque_buff_action.set_function(self, "ataqueBuff")
	ataque_seletor.add_child(ataque_buff_action)
	
	var causar_dano_action = Action.new()
	causar_dano_action.set_function(self, "_causar_dano")
	ataque_seletor.add_child(causar_dano_action)
	
	inimigo_sequence.add_child(ataque_seletor)
	root_selector.add_child(inimigo_sequence)
	
	
	#--------------busca_sequence--------------
	var busca_sequence = Sequence.new()
	
	var buscar_quadrante_condition = Condition.new()
	buscar_quadrante_condition.set_function(self, "_buscar_quadrante")
	busca_sequence.add_child(buscar_quadrante_condition)
	
	var mover_selector = Selector.new()
	
	var profundidade_action = Action.new()
	profundidade_action.set_function(self, "_buscar_por_profundidade")
	mover_selector.add_child(profundidade_action)
	
	var mover_ate_quadrante_action = Action.new()
	mover_ate_quadrante_action.set_function(self, "_mover_ate_quadrante")
	mover_selector.add_child(mover_ate_quadrante_action)
	
	busca_sequence.add_child(mover_selector)
	root_selector.add_child(busca_sequence)
	#--------------escolher_direcao_action--------------
	var escolher_direcao_action = Action.new()
	escolher_direcao_action.set_function(self, "_escolher_direcao_aleatoria")
	root_selector.add_child(escolher_direcao_action)
	
	return root_selector


func _procurar_por_vida() -> bool:
	if get_meta("Hp") < get_meta("MaxHp")*3/5:
		await procurar_por_vida()
		return true
	else:
		return false


func _causar_dano() -> bool:
	var inimigo_proximo: Personagem = detectarInimigos()[0]
	if inimigo_proximo:
		await causarDano(inimigo_proximo)
		return true
	return false

func _buscar_por_profundidade() -> bool:
	var alvo: Inimigo
	
	for inimigo in game_manager.lista_de_acao:
		if inimigo is Inimigo:
			alvo = inimigo
			break
	if alvo:
		var quadrantebusca: Quadrante = await melhor_proximo_passo(quadranteAtual.quadrante_matrix, alvo)
		if quadrantebusca:
			await mover_ate_quadrante(quadrantebusca)
			return true
	return false

func _mover_ate_quadrante() -> bool:
	var quadrantebusca: Quadrante = buscarQuadrante()
	if quadrantebusca:
		await mover_ate_quadrante(quadrantebusca)
		return true
	return false

func _escolher_direcao_aleatoria() -> bool:
	await escolher_direcao_aleatoria()
	return true

func copiar(inspiracao: Personagem):
	ataqueBuffCd = inspiracao.ataqueBuffCd
	level = inspiracao.level
	xp = inspiracao.xp
	xpNecessario = inspiracao.xpNecessario
