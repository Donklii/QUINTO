extends Fantasma
class_name PhantomProtagonista

var ataqueBuffCd: int = 0

var level:int
var xp: int
var xpNecessario: int

var arvoreDeDecisao: Sequence

var direcao: int
var direcaoAnterior: int = -1


func _init(_geracao: String, inspiracao: Object) -> void:
	super._init(_geracao, inspiracao)
	
	if ataqueBuffCd == 4:
		Dano -= 2
	if ataqueBuffCd > 0:
		ataqueBuffCd -= 1


func procurar_por_vida() -> void:
	var vidaAlvo: VidaDrop = null
	for i: Array[Quadrante] in quadranteAtual.quadrante_matrix:
		for quadrante: Quadrante in i:
			if quadrante:
				if quadrante.entidade:
					if not vidaAlvo:
						vidaAlvo = quadrante.entidade
					if heuristica(quadranteAtual, vidaAlvo.quadranteAtual) > heuristica(quadranteAtual, quadrante):
						vidaAlvo = quadrante.entidade
	
	ocupar(phantom_proximo_passo(quadranteAtual.quadrante_matrix, vidaAlvo))
	
	if quadranteAtual.entidade:
		if quadranteAtual.entidade is VidaDrop:
			recuperar_vida(3)

func ataqueBuff() -> void:
	if ataqueBuffCd > 1:
		print("USOU EM CD ESSA MERDA")
	ataqueBuffCd = acoesRestantes+4
	Dano += 2
	game_manager.adicionar_pontuacao(-1)
	acoes = ["mov", "atacar" , "procurar_por_vida", "desviar"]


func desviar() -> void:
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAtual.quadranteAoLado(i)
		
		if !quadrante_proximo:
			continue
		
		var quebra: bool = false
		for fantasma: OcupacaoFantasma in quadrante_proximo.fantasmas:
			if fantasma.geracao == geracao:
				quebra = true
				break
		if quebra: continue
		
		for j in range(0,4):
			var quadrante_distante: Quadrante = quadrante_proximo.quadranteAoLado(i)
			
			if !quadrante_distante:
				continue
			
			
			var quebra2: bool = false
			for fantasma: OcupacaoFantasma in quadrante_distante.fantasmas:
				if fantasma.geracao == geracao and fantasma.ocupante is PhantomInimigo:
					quebra2 = true
					break
			if quebra2: continue
			
			ocupar(quadrante_proximo)
			return


func aumentar_xp(quantia:int) -> void:
	xp += quantia
	if xp >= xpNecessario:
		
		levelUp()
		xp -= xpNecessario
		await Global.create_and_start_timer(0.2,self)


func levelUp() -> void:
	level += 1
	
	MaxHp += 1
	
	match level:
		2:
			xpNecessario = 5
		3:
			xpNecessario = 12
		4:
			xpNecessario = 28
		5:
			xpNecessario = 100000
	
	recuperar_vida(MaxHp-Hp)



func copiar(inspiracao: Object) -> void:
	super.copiar(inspiracao)
	if inspiracao is Protagonista:
		
		if inspiracao.ataqueBuffCd: ataqueBuffCd = 3
		else: ataqueBuffCd = 0
	else:
		ataqueBuffCd = inspiracao.ataqueBuffCd
	
	level = inspiracao.level
	xp = inspiracao.xp
	xpNecessario = inspiracao.xpNecessario
	
	if ataqueBuffCd > 1:
		acoes = ["mov", "atacar" , "procurar_por_vida", "desviar"]
	else:
		acoes = ["mov", "atacar", "procurar_por_vida", "ataqueBuff", "desviar"]
