extends Personagem
class_name Protagonista

var direcao: int
var direcaoAnterior: int = -1
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



func _process(_delta: float) -> void:
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("Idle")

func decidirAcao() -> void:
	var inimigoProximo: Personagem = detectarInimigos()
	
	await procurar_por_vida()
	
	if inimigoProximo:
		await causarDano(inimigoProximo)
		return
	
	var quadrantebusca: Quadrante = buscarQuadrante()
	
	if quadrantebusca:
		await mover_ate_quadrante(quadrantebusca)
		return
	
	await escolher_direcao_aleatoria()


func procurar_por_vida():
	if get_meta("Hp") >= get_meta("MaxHp"):
		if "vida" in rastrosDesejados:
			rastrosDesejados.erase("vida")
		return
	
	if quadranteAtual.entidade:
		if quadranteAtual.entidade is VidaDrop:
			quadranteAtual.entidade.usar(self)
			await Global.create_and_start_timer(1,self)
	elif not "vida" in rastrosDesejados:
		rastrosDesejados.append("vida")
	

func escolher_direcao_aleatoria(jaforam: Array[int] = []):
	while direcao in jaforam or direcao == direcaoAnterior:
		direcao = randi_range(0,4)
	
	
	var quadrante_desejado: Quadrante = quadranteAtual.quadranteAoLado(direcao)
	if quadrante_desejado: 
		if !quadrante_desejado.ocupado:
			await mover_ate_quadrante(quadrante_desejado)
			
			direcaoAnterior = (direcao + 2)%4
			
			return
	
	jaforam.append(direcao)
	
	if jaforam.size() > 2 and direcaoAnterior >= 0:
		direcaoAnterior = -1
	
	if jaforam.size() > 3:
		return
	
	await escolher_direcao_aleatoria(jaforam)


func _on_acabou_acao() -> void:
	pass


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
