extends Entidade
class_name Personagem


var rastrosDesejados: Array[String] = []

var turnoAtual: bool = false
var MaxDeAcoes: int = 2
var acoesRestantes: int = 0

var ativo: bool = false
var pronto_para_fim_da_acao: bool = true

var arvore_de_decisao: Selector

signal recuperou_vida
signal causou_dano
signal tomou_dano
signal matou
signal morreu

signal acabou_acao
signal acabou_turno

func set_rastrosDesejados() -> void:
	pass

func _ready() -> void:
	await game_manager.pronto
	
	set_rastrosDeixados()
	set_rastrosDesejados()
	
	calcularDistanciaDoMaiorRastro()
	
	set_quadrante()
	
	arvore_de_decisao = criar_arvore_decisao()


func _process(_delta: float) -> void:
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("idle")


## ⎯⎯⎯⎯⎯  𝌅 🌲 ÁRVORE DE DECISÃO 🌲 𝌅  ⎯⎯⎯⎯⎯


func agir(Acoes: int) -> void:
	turnoAtual = true
	
	acoesRestantes = Acoes
	
	game_manager.comeco_da_acao.emit()
	
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


func finalizarTurno():
	acabou_turno.emit()


func detectarInimigos() -> Array[Personagem]:
	var lista: Array[Personagem] = []
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if quadrante_proximo:
			if quadrante_proximo.ocupado and quadrante_proximo.donoAtual:
				if self is Inimigo:
					if quadrante_proximo.donoAtual is Protagonista:
						lista.append(quadrante_proximo.donoAtual)
				elif self is Protagonista:
					if quadrante_proximo.donoAtual is Inimigo:
						lista.append(quadrante_proximo.donoAtual)
	return lista


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

func melhor_proximo_passo(quadrantes: Array, objetivo: Object) -> Quadrante:
	var inicio: Quadrante = self.quadranteAtual
	var destino: Quadrante = objetivo.quadranteAtual
	print("posição inimiga: " + str(destino.posicao))
	
	if not destino:
		print("Erro: Quadrante inicial ou destino inválido.")
		return null
	
	var lista_aberta: Array = []
	var lista_fechada: Array = []
	
	var custo_g = {}
	var custo_f = {}
	var caminhos = {}
	
	lista_aberta.append(inicio)
	custo_g[inicio] = 0
	custo_f[inicio] = heuristica(inicio, destino)
	
	while lista_aberta.size() > 0:
		# Encontra o quadrante com menor custo f na lista aberta
		var atual = lista_aberta[0]
		for quadrante in lista_aberta:
			if custo_f.has(quadrante) and custo_f[quadrante] < custo_f[atual]:
				atual = quadrante
	
		# Verifica se alcançou o destino
		if atual == destino or (
			(objetivo is Personagem or objetivo is Fantasma) and 
			(atual == quadrantes[destino.posicao.x][destino.posicao.y-1] or
			atual == quadrantes[destino.posicao.x][destino.posicao.y+1] or
			atual == quadrantes[destino.posicao.x-1][destino.posicao.y] or 
			atual == quadrantes[destino.posicao.x+1][destino.posicao.y])
		):
			print("Objetivo encontrado!")
			return reconstruir_caminho(caminhos, atual)
		
		lista_aberta.erase(atual)
		lista_fechada.append(atual)
		
		# Adiciona os vizinhos à lista aberta
		for i in range(4):
			var vizinho = atual.quadranteAoLado(i)
			if vizinho and not vizinho.ocupado and not lista_fechada.has(vizinho):
				var novo_custo_g = custo_g[atual] + 1
				if not lista_aberta.has(vizinho):
					lista_aberta.append(vizinho)
					caminhos[vizinho] = atual
				elif novo_custo_g >= custo_g.get(vizinho, INF):
					continue
				
				# Atualiza os custos do vizinho
				custo_g[vizinho] = novo_custo_g
				custo_f[vizinho] = custo_g[vizinho] + heuristica(vizinho, destino)
	
	print("Nenhum caminho disponível para o objetivo.")
	return null


func heuristica(atual: Quadrante, destino: Quadrante) -> float:
	return abs(atual.posicao.x - destino.posicao.x) + abs(atual.posicao.y - destino.posicao.y)


func reconstruir_caminho(caminhos: Dictionary, atual: Quadrante) -> Quadrante:
	var caminho = []
	while atual in caminhos:
		caminho.append(atual)
		atual = caminhos[atual]
	caminho.reverse()
	return caminho[0] if caminho.size() > 0 else null


func mover(alvo: Vector2, velocidade: int, proximidade: float = 4) -> void:
	
	while (alvo.distance_to(global_position) > proximidade):
		var direction = (alvo - global_position).normalized()
		
		velocity = direction * velocidade
		
		move_and_slide()
		await get_tree().process_frame
	
	velocity = Vector2(0,0)



func mover_ate_quadrante(quadrantebusca: Quadrante) -> void:
	
	if !quadrantebusca:
		print("Quadrante invalido")
		return
	
	quadrantebusca.mudarCor(Color(0,1,0,1))
	
	await mover(quadrantebusca.global_position, 30,2)
	
	
	global_position = quadrantebusca.global_position
	
	
	await get_tree().process_frame
	
	quadrantebusca.mudarCor(Color(1,1,1,0.25))
	
	await quadrantebusca.ocupar(self)


##✹✹✹✹✹✹✹✹✹✹✹✹✹  C ⊛ M B A T E ✹✹✹✹✹✹✹✹✹✹✹✹✹
func subir(objeto: Object):
	add_child(objeto)
	objeto.global_position = get_node("AnimatedSprite2D").global_position + Vector2(0,-20)
	
	var tempo: float = 5
	var velocidade: Vector2 = Vector2(0,-randi_range(20,40))
	
	while tempo > 0:
		tempo -= get_process_delta_time()
		
		objeto.modulate.a -= 0.02
		objeto.global_position += velocidade * get_process_delta_time()
		await get_tree().process_frame
	
	objeto.queue_free()

func numeroFlutuante(cor: Color, mensagem: String = "") -> void:
	var numeroFlutuante = Label.new()
	numeroFlutuante.text = mensagem
	
	numeroFlutuante.self_modulate = cor
	
	subir(numeroFlutuante)


func mostrarDano(dano: int) -> void:
	var cor: Color = Color(255,200-(dano*15),0)
	numeroFlutuante(cor,str(dano))

func mostrarRecuperacao(vida) -> void:
	var cor: Color = Color(0,255+(vida*15),0)
	numeroFlutuante(cor,str(vida))


func take_damage(dano: int, culpa: Personagem = null, tipo: String = "") -> void:
	set_meta("Hp",get_meta("Hp") - dano)
	mostrarDano(dano)
	ativo = true
	if get_meta("Hp") < 1:
		morrer()
		if culpa:
			culpa.matou.emit(self)
		
	tomou_dano.emit()

func recuperar_vida(vida: int, culpa: Entidade = null) -> void:
	set_meta("Hp",get_meta("Hp") + vida)
	mostrarRecuperacao(vida)
	
	if get_meta("Hp") > get_meta("MaxHp"):
		set_meta("Hp", get_meta("MaxHp"))
	
	recuperou_vida.emit()

func morrer() -> void:
	game_manager.morte.emit(self)
	
	quadranteAtual.desocupar()
	
	await get_tree().process_frame
	
	queue_free()


func causarDano(alvo: Personagem) -> void:
	var quadrante_do_alvo: Quadrante = alvo.quadranteAtual
	quadrante_do_alvo.mudarCor(Color(1,0.2,0,1))
	
	await mover(alvo.global_position, 40)
	
	alvo.take_damage(get_meta("Dano"), self)
	causou_dano.emit()
	
	
	await mover(quadranteAtual.global_position, 15,2)
	
	global_position = quadranteAtual.global_position
	quadrante_do_alvo.mudarCor(Color(1,1,1,0.25))



func criar_arvore_decisao() -> Selector:
	var root_selector = Selector.new()
	
	#--------------inimigo_sequence--------------
	var inimigo_sequence = Sequence.new()
	
	var detectar_inimigo_condition = Condition.new()
	detectar_inimigo_condition.set_function(self, "_detectar_inimigos")
	inimigo_sequence.add_child(detectar_inimigo_condition)
	
	var causar_dano_action = Action.new()
	causar_dano_action.set_function(self, "_causar_dano")
	inimigo_sequence.add_child(causar_dano_action)
	
	
	root_selector.add_child(inimigo_sequence)
	
	#--------------busca_sequence--------------
	var busca_sequence = Sequence.new()
	
	var buscar_quadrante_condition = Condition.new()
	buscar_quadrante_condition.set_function(self, "_buscar_quadrante")
	busca_sequence.add_child(buscar_quadrante_condition)
	
	var mover_ate_quadrante_action = Action.new()
	mover_ate_quadrante_action.set_function(self, "_mover_ate_quadrante")
	busca_sequence.add_child(mover_ate_quadrante_action)
	
	
	root_selector.add_child(busca_sequence)
	
	
	return root_selector


func _detectar_inimigos() -> bool:
	return !detectarInimigos().is_empty()

func _causar_dano() -> bool:
	var inimigo_proximo: Personagem = detectarInimigos()[0]
	if inimigo_proximo:
		await causarDano(inimigo_proximo)
		return true
	return false

func _buscar_quadrante() -> bool:
	return buscarQuadrante() != null

func _mover_ate_quadrante() -> bool:
	var quadrante_busca: Quadrante = buscarQuadrante()
	if quadrante_busca:
		await mover_ate_quadrante(quadrante_busca)
		return true
	return false



func copiar(inspiracao: Personagem):
	turnoAtual = inspiracao.turnoAtual
	MaxDeAcoes = inspiracao.MaxDeAcoes
	ativo = inspiracao.ativo
	pronto_para_fim_da_acao = inspiracao.pronto_para_fim_da_acao
