extends Node2D
class_name Quadrante

var posicao: Vector2
var quadrante_matrix: Array[Array]

var lista_de_rastros: Array[Rastro] = []

var setor: Vector2
var setoresAdjacentes: Array[Vector2]

var ocupado: bool = false
var donoAtual: Personagem = null
var entidade: Entidade = null
var fantasmas: Array[OcupacaoFantasma] = []

@onready var game_manager = $".."



func _process(_delta: float) -> void:
	cortar_rastros_bloqueaveis()



##➳➳➳ 𝐹𝑈𝑁𝐶̧𝑂̃𝐸𝑆 𝐵𝐴𝑆𝐸 ➳➳➳

func ocupar(ocupante: Entidade) -> void:
	if not ocupante is Personagem:
		ocupante.quadranteAtual = self
		entidade = ocupante
		await ocupante.configurarQuadrante()
		return
	
	ocupado = true
	
	if ocupante.quadranteAtual:
		await ocupante.quadranteAtual.desocupar() # -lag
		await get_tree().process_frame # -lag
	
	donoAtual = ocupante
	donoAtual.quadranteAtual = self
	
	await cortar_rastros_bloqueaveis() # -lag
	await get_tree().process_frame # -lag
	
	await donoAtual.configurarQuadrante() # -lag


func desocupar(ocupante: Entidade = donoAtual) -> void:
	
	for rastroDeixado in ocupante.rastrosDeixados:
		apagar_restos_de_rastro(rastroDeixado)
	
	if not ocupante is Personagem:
		entidade = null
		return
	
	ocupado = false
	
	for i in range(4):
		var quadrante_desejado: Quadrante = quadranteAoLado(i)
		
		if quadrante_desejado:
			quadrante_desejado.espalhar_rastros_bloqueaveis()
			await get_tree().process_frame # -lag
	
	donoAtual = null

##➳➳➳ 𝗔𝗗𝗜𝗖𝗜𝗢𝗡𝗔𝗥 𝗥𝗔𝗦𝗧𝗥𝗢𝗦 ➳➳➳



func adicionar_rastro(rastroNovo:Rastro) -> void:
	if ocupado:
		if !rastroNovo.passa_por_personagem and rastroNovo.emissor != donoAtual:
			rastroNovo.free()
			return
	
	for rastroatual in lista_de_rastros:
		if rastroatual.equals(rastroNovo):
			rastroNovo.free()
			return
			
		elif rastroatual.nome == rastroNovo.nome and rastroatual.emissor == rastroNovo.emissor:
			
			if  rastroatual.forca >= rastroNovo.forca:
				rastroNovo.free()
				return
			else:
				rastroatual.forca = rastroNovo.forca
				rastroNovo.free()
				espalhar_rastro(rastroatual)
				return
	
	lista_de_rastros.append(rastroNovo)
	
	espalhar_rastro(rastroNovo)



#➤➤➤ 𝗘𝗦𝗣𝗔𝗟𝗛𝗔𝗥 𝗥𝗔𝗦𝗧𝗥𝗢𝗦 ➤➤➤



func espalhar_rastro(rastro: Rastro) -> void:
	if !(rastro.forca - rastro.decaimento > 0) or !is_instance_valid(rastro.emissor):
		return
	
	for i in range(0,4):
		var quadrante_proximo: Quadrante = quadranteAoLado(i)
		
		if quadrante_proximo:
			var rastroNovo = Rastro.new()
			rastroNovo.copiar(rastro)
			rastroNovo.forca -= rastro.decaimento
			
			quadrante_proximo.adicionar_rastro(rastroNovo)


func espalhar_rastros_bloqueaveis():
	if lista_de_rastros.size() < 1:
		return
	
	for rastro in lista_de_rastros:
		
		if (!rastro.passa_por_personagem and
		rastro.forca - rastro.decaimento > 0 and 
		is_instance_valid(rastro.emissor)):
			
			for i in range(0,4):
				var quadrante_proximo: Quadrante = quadranteAoLado(i)
				
				if quadrante_proximo:
					if not quadrante_proximo.ocupado:
						var rastroNovo = Rastro.new()
						rastroNovo.copiar(rastro)
						rastroNovo.forca -= rastro.decaimento
						
						quadrante_proximo.adicionar_rastro(rastroNovo)


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



#═══◇◆◇ [ 𝗥𝗘𝗠𝗢𝗖̧𝗔̃𝗢 𝗗𝗘 𝗥𝗔𝗦𝗧𝗥𝗢𝗦 ] ◇◆◇═══



func remover_rastro(rastro: Rastro) -> void:
	var rastroPresente: Rastro = tem_rastro(rastro)
	
	if rastroPresente:
		apagar_rastro(rastroPresente)


func cortar_rastros_bloqueaveis():
	if ocupado:
		for rastro in lista_de_rastros:
			if !rastro.passa_por_personagem and rastro.emissor != donoAtual:
				var emissor: Entidade = rastro.emissor
				apagar_restos_de_rastro(rastro)
				
				emissor.quadranteAtual.espalhar_rastros_bloqueaveis()
				
				await get_tree().process_frame # -lag


func remover_rastros_por_emissor(emissor: Entidade) -> void:
	
	if lista_de_rastros.size() < 1:
		return
	
	for rastroPresente in lista_de_rastros:
		
		if rastroPresente.emissor == emissor:
			apagar_rastro(rastroPresente)


func apagar_restos_de_rastro(rastro: Rastro) -> void:
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


func remover_todos_os_rastros() -> void:
	for rastro in lista_de_rastros:
		lista_de_rastros.erase(rastro)
		rastro.queue_free()


func apagar_rastro(rastro: Rastro) -> void:
	lista_de_rastros.erase(rastro)
	rastro.free()





##✧✧✧  𝕌𝕋𝕀𝕃𝕊 ✧✧✧


func quadranteAoLado(indice: int) -> Quadrante:
	var quadrante_proximo: Quadrante
	match indice:
			0:
				if posicao.y > 0:
					quadrante_proximo = quadrante_matrix[posicao.x][posicao.y-1]
			1:
				if posicao.y+1 < quadrante_matrix[posicao.x].size():
					quadrante_proximo = quadrante_matrix[posicao.x][posicao.y+1]
			2:
				if posicao.x > 0:
					quadrante_proximo = quadrante_matrix[posicao.x-1][posicao.y]
			3:
				if posicao.x+1 < quadrante_matrix.size():
					quadrante_proximo = quadrante_matrix[posicao.x+1][posicao.y]
	
	return quadrante_proximo



func tem_rastro(rastro: Rastro) -> Rastro:
	for rastroAtual in lista_de_rastros:
		if rastroAtual.nome == rastro.nome and rastroAtual.emissor == rastro.emissor:
			return rastroAtual
	
	return null



func tem_residuos_do_rastro(rastro: Rastro) -> Rastro:
	for rastroAtual in lista_de_rastros:
		if rastro.nome == rastroAtual.nome and rastro.emissor == rastroAtual.emissor:
			if rastro.forca >= rastroAtual.forca:
				return rastroAtual
	
	return null



func estaNoLimite() -> bool:
	
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
	$Label.text += "\nSetor: "+ str(setor)
	for fantasma: OcupacaoFantasma in fantasmas:
		var nome:String 
		if fantasma.ocupante is PhantomProtagonista: nome = "Protagonista"
		else: nome = "Inimigo"
		$Label.text += str(str("\n")+str("Fan: ")+str(nome.substr(0,nome.length()/4))+str(" Ger: ")+str(fantasma.geracao))
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
