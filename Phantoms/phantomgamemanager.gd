extends Object
class_name PhantomGameManager

var protagonista: Fantasma
var lista_de_acao: Array[Fantasma] = []
var dono_do_turno: Fantasma

var geracao: String
var pontuacao: int = 0
var agir: bool = true
var acao: String
var profundidade:int

var quadrante_matrix: Array[Array] = []


func _init(gameManager, _geracao: String, _profundidade: int, _pontuacao: int, _acao:String = "") -> void:
	geracao = _geracao
	profundidade = _profundidade
	acao = _acao
	pontuacao = _pontuacao
	
	copiar(gameManager)


func miniMax() -> Acontecimento:
	dono_do_turno.call(acao)
	dono_do_turno.acoesRestantes -= 1
	
	
	if dono_do_turno.acoesRestantes < 1:
		passar_turno()
	
	
	var pontuacaoNovaNova: int = -1000
	if profundidade > 0:
		for acaoAtual in dono_do_turno.acoes:
			var pMnovo = PhantomGameManager.new(self, (geracao+" + "+acaoAtual), profundidade-1, pontuacao, acaoAtual)
			var pontuacaoNova: int = (await pMnovo.miniMax()).valor
			if dono_do_turno is PhantomProtagonista:
				pontuacaoNovaNova = max(pontuacaoNova, pontuacaoNovaNova)
			else:
				pontuacao = pontuacaoNova
		if dono_do_turno is PhantomProtagonista:
			pontuacao = pontuacaoNovaNova
	else:
		#print("Geração: "+ str(geracao) + " - Vantagem: " + (str(pontuacao)))
		if dono_do_turno is PhantomProtagonista:
			await dono_do_turno.quadranteAtual.get_tree().process_frame
	deletar()
	return Acontecimento.new(acao, pontuacao)


func passar_turno():
	var index: int = lista_de_acao.find(dono_do_turno)
	if index == -1:
		print("Erro: Dono do turno não encontrado na lista de ação.")
		return
	
	if index + 1 >= lista_de_acao.size():
		dono_do_turno = lista_de_acao[0]  # Retorna ao início da lista
	else:
		dono_do_turno = lista_de_acao[index + 1]  # Passa para o próximo
	
	dono_do_turno.acoesRestantes = dono_do_turno.MaxDeAcoes


func deletar():
	for fantasma: Fantasma in lista_de_acao:
		fantasma.desocupar()
	lista_de_acao.clear()

func remover_da_lista(fantasma: Fantasma):
	lista_de_acao.erase(fantasma)

func adicionar_pontuacao(valor: int) -> void:
	pontuacao += valor


func copiar(gameManager: Object):
	for personagem: Object in gameManager.lista_de_acao:
		var personagemNovo: Fantasma = null
		
		if personagem is Inimigo or personagem is PhantomInimigo:
			personagemNovo = PhantomInimigo.new(geracao, personagem)
		elif personagem is Protagonista or personagem is PhantomProtagonista:
			personagemNovo = PhantomProtagonista.new(geracao, personagem)
		
		if personagemNovo.Hp <= 0:
			print(personagemNovo.to_string()+" ta morto!")
			continue
		
		if personagem is PhantomProtagonista or personagem is Protagonista:
			protagonista = personagemNovo
		
		if personagem == gameManager.dono_do_turno:
			dono_do_turno = personagemNovo
		
		personagemNovo.game_manager = self
		lista_de_acao.append(personagemNovo)
