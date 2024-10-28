extends Node2D
class_name Quadrante

var lista_de_rastros: Array[Rastro] = []


signal espalhar

func reparar():
	for rastroPrimario in lista_de_rastros:
		for rastroatual in lista_de_rastros:
			if rastroatual == rastroPrimario:
				pass
			elif rastroatual.nome == rastroPrimario.nome:
				if rastroatual.forca > rastroPrimario.forca:
					lista_de_rastros.erase(rastroPrimario)
				else:
					lista_de_rastros.erase(rastroatual)


func mouse_esta_em_cima() -> bool:
	if (
		(abs(get_global_mouse_position().x - global_position.x) <= 8) and 
		(abs(get_global_mouse_position().y - global_position.y) <= 8)
		):
			return true
	else:
		return false


func adicionar_rastro_com_click():
	var temrastrodeviado: bool = false
	for rastroinspec in lista_de_rastros:
		if rastroinspec.nome == "viado":
			temrastrodeviado = true
			rastroinspec.forca += 150
		
	if not temrastrodeviado:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.nome = "viado"
		rastronovo.decaimento = 50
		rastronovo.forca = 150
		adicionar_rastro(rastronovo)
	
	espalhar_rastros()

func _ready() -> void:
	get_parent().connect("fim_da_acao", Callable(self, "remover_todos_os_rastros"))

func _process(delta: float) -> void:
	if mouse_esta_em_cima():
		if Input.is_action_just_pressed("botaoesquerdo"):
			adicionar_rastro_com_click()
		
		elif Input.is_action_just_pressed("botaodireito"):
			print(str("\n")+str(name)+str(":"))
			for rastro in lista_de_rastros:
				print(str("Rastro: ")+str(rastro.nome)+str(" Força: ")+str(rastro.forca)+str("\n"))
		
		modulate = Color(0,0,1,1)
		$Label.text = ""
		for rastro in lista_de_rastros:
			$Label.text += str(str("\n")+str("Rastro: ")+str(rastro.nome)+str(" Força: ")+str(rastro.forca))
		$Label.visible = true
	else:
		modulate = Color(1,1,1,1)
		$Label.visible = false
	
	reparar()

func adicionar_rastro(rastroNovo:Rastro) -> void:
	for rastroatual in lista_de_rastros:
		if rastroatual.equals(rastroNovo):
			return
			
		elif rastroatual.nome == rastroNovo.nome:
			
			if rastroNovo.forca <= rastroatual.forca:
				return
			else:
				rastroatual.forca = rastroNovo.forca
				break
	
	lista_de_rastros.append(rastroNovo)
	reparar()
	espalhar_rastros()


func remover_todos_os_rastros() -> void:
	lista_de_rastros = []


func espalhar_rastros()  -> void:
	if lista_de_rastros.size() < 1:
		return
	
	for quadrante_proximo in $Area2D.get_overlapping_bodies():
		
		if quadrante_proximo is Quadrante and quadrante_proximo != self:
			
			for rastro in lista_de_rastros:
				
				if rastro.forca - rastro.decaimento > 0:
					
					var rastroNovo = Rastro.new()
					rastroNovo.forca = rastro.forca - rastro.decaimento
					rastroNovo.nome = rastro.nome
					rastroNovo.decaimento = rastro.decaimento
					
					quadrante_proximo.adicionar_rastro(rastroNovo)
