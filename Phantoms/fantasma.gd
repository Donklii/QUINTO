extends Object
class_name Fantasma

var Hp: int
var MaxHp: int
var Dano: int
var geracao: String

var valorDoDano: int
var valorDaVida: int

var turnoAtual: bool = false
var MaxDeAcoes: int = 2
var acoesRestantes: int
var ativo: bool = false

var rastrosDeixados: Array[Rastro] = []
var rastro_mais_longo: Rastro
var distancia_do_maior_rastro: int = 0

var quadranteAtual: Quadrante = null

var game_manager: PhantomGameManager

var acoes: Array[String] = []

func _init(_geracao: String, inspiracao: Object) -> void:
	geracao = _geracao
	copiar(inspiracao)

func _to_string() -> String:
	if self is PhantomProtagonista: return "Protagonista"
	else: return "Inimigo"


func ocupar(quadrante: Quadrante):
	if not quadrante:
		print("sem quadrante")
		return
	elif quadranteAtual:
		desocupar()
	
	var ocup: OcupacaoFantasma = OcupacaoFantasma.new(geracao, self)
	quadranteAtual = quadrante
	quadrante.fantasmas.append(ocup)

func desocupar():
	for fantasmaAtual: OcupacaoFantasma in quadranteAtual.fantasmas:
		if fantasmaAtual.ocupante == self:
			quadranteAtual.fantasmas.erase(fantasmaAtual)
			return


##✹✹✹✹✹✹✹✹✹✹✹✹✹  C ⊛ M B A T E ✹✹✹✹✹✹✹✹✹✹✹✹✹
func atacar():
	if !detectarInimigos().is_empty():
		causarDano(detectarInimigos()[0])


func mov() -> bool:
	var quadrante: Quadrante
	for personagem in game_manager.lista_de_acao:
		if self is PhantomProtagonista:
			if personagem is PhantomInimigo:
				quadrante = phantom_proximo_passo(quadranteAtual.quadrante_matrix, personagem)
				break
		elif self is PhantomInimigo:
			if personagem is PhantomProtagonista:
				quadrante = phantom_proximo_passo(quadranteAtual.quadrante_matrix, personagem)
				break
	if quadrante:
		ocupar(quadrante)
		return true
	return false


func detectarInimigos() -> Array[Fantasma]:
	var lista: Array[Fantasma] = []
	
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if !quadrante_proximo:
			continue
		
		for ocupacaoFantasma: OcupacaoFantasma in quadrante_proximo.fantasmas:
			if ocupacaoFantasma.geracao == geracao:
				if self is PhantomInimigo:
					if ocupacaoFantasma.ocupante is PhantomProtagonista:
						lista.append(ocupacaoFantasma.ocupante)
				elif self is PhantomProtagonista:
					if ocupacaoFantasma.ocupante is PhantomInimigo:
						lista.append(ocupacaoFantasma.ocupante)
	return lista


func take_damage(dano: int, culpa: Fantasma = null, tipo: String = "") -> void:
	Hp -= dano
	ativo = true
	
	game_manager.adicionar_pontuacao(dano*valorDoDano)
	
	if Hp < 1:
		game_manager.adicionar_pontuacao(Hp*valorDoDano)
		morrer()


func recuperar_vida(vida: int, culpa: Entidade = null) -> void:
	var HpAntigo = Hp
	Hp += vida
	
	if Hp > MaxHp:
		Hp = MaxHp
	
	game_manager.adicionar_pontuacao(-valorDoDano*(Hp-HpAntigo))


func morrer() -> void:
	game_manager.adicionar_pontuacao(valorDaVida)
	
	desocupar()
	
	game_manager.remover_da_lista(self)


func causarDano(alvo: Fantasma) -> void:
	alvo.take_damage(Dano, self)


func phantom_proximo_passo(quadrantes: Array, objetivo: Object) -> Quadrante:
	var inicio: Quadrante = self.quadranteAtual
	var destino: Quadrante = objetivo.quadranteAtual
	
	if not destino:
		print("Erro: Quadrante inicial ou destino inválido.")
		return null
	
	# Lista aberta: quadrantes a serem visitados
	var lista_aberta: Array = []
	# Lista fechada: quadrantes já visitados
	var lista_fechada: Array = []
	
	# Mapas para armazenar custos e caminhos
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
			#print("Objetivo encontrado!")
			return reconstruir_caminho(caminhos, atual)
		
		lista_aberta.erase(atual)
		lista_fechada.append(atual)
		
		# Adiciona os vizinhos à lista aberta
		for i in range(4):
			var vizinho: Quadrante = atual.quadranteAoLado(i)
			var phantomOcupado: bool = false
			
			if vizinho:
				for fantasma in vizinho.fantasmas:
					if fantasma.geracao == geracao:
						phantomOcupado = true
						break
			
			if vizinho and not phantomOcupado and not lista_fechada.has(vizinho):
				var novo_custo_g = custo_g[atual] + 1
				if not lista_aberta.has(vizinho):
					lista_aberta.append(vizinho)
					caminhos[vizinho] = atual
				elif novo_custo_g >= custo_g.get(vizinho, INF):
					continue
				
				# Atualiza os custos do vizinho
				custo_g[vizinho] = novo_custo_g
				custo_f[vizinho] = custo_g[vizinho] + heuristica(vizinho, destino)
	
	#print("Nenhum caminho disponível para o objetivo.")
	return null

# Função heurística: calcula a distância de Manhattan
func heuristica(atual: Quadrante, destino: Quadrante) -> float:
	return abs(atual.posicao.x - destino.posicao.x) + abs(atual.posicao.y - destino.posicao.y)

# Reconstrói o caminho a partir dos quadrantes rastreados
func reconstruir_caminho(caminhos: Dictionary, atual: Quadrante) -> Quadrante:
	var caminho = []
	while atual in caminhos:
		caminho.append(atual)
		atual = caminhos[atual]
	caminho.reverse()
	return caminho[0] if caminho.size() > 0 else null


func copiar(inspiracao: Object) -> void:
	turnoAtual = inspiracao.turnoAtual
	MaxDeAcoes = inspiracao.MaxDeAcoes
	ativo = inspiracao.ativo
	acoesRestantes = inspiracao.acoesRestantes
	valorDaVida = inspiracao.valorDaVida
	valorDoDano = inspiracao.valorDoDano
	ocupar(inspiracao.quadranteAtual)
	
	if inspiracao is Inimigo or inspiracao is Protagonista:
		Hp = inspiracao.get_meta("Hp")
		MaxHp = inspiracao.get_meta("MaxHp")
		Dano = inspiracao.get_meta("Dano")
	elif inspiracao is PhantomInimigo or inspiracao is PhantomProtagonista:
		Hp = inspiracao.Hp
		MaxHp = inspiracao.MaxHp
		Dano = inspiracao.Dano
