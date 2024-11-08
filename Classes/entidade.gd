extends CharacterBody2D
class_name Entidade

var rastrosDeixados: Array[Rastro] = []
var rastro_mais_longo: Rastro
var distancia_do_maior_rastro: int = 0

var quadranteAtual: Quadrante = null

@onready var game_manager: Node = $".."



func set_rastrosDeixados() -> void:
	pass



func configurarQuadrante() -> void:
	for rastro in rastrosDeixados:
		var rastronovo: Rastro = Rastro.new()
		rastronovo.copiar(rastro)
		
		quadranteAtual.adicionar_rastro(rastronovo)
		await get_tree().process_frame # -lag


func calcularDistanciaDoMaiorRastro() -> void:
	for rastro in rastrosDeixados:
		if rastro_mais_longo == null:
			rastro_mais_longo = rastro
		if  rastro.calcularDistanciaDoRastro() >  rastro_mais_longo.calcularDistanciaDoRastro():
			rastro_mais_longo = rastro
	
	distancia_do_maior_rastro = rastro_mais_longo.calcularDistanciaDoRastro()


func set_quadrante() -> void:
	var quadranteDesejado: Quadrante = null
	
	for quadrante in get_parent().get_children():
		if quadrante is Quadrante:
			if (not quadrante.ocupado and 
			quadrante.global_position.distance_to(global_position) < 100
			):
				if not quadranteDesejado:
					quadranteDesejado = quadrante
				elif global_position.distance_to(quadranteDesejado.global_position) > global_position.distance_to(quadrante.global_position):
					quadranteDesejado = quadrante
	
	global_position = quadranteDesejado.global_position
	quadranteDesejado.ocupar(self)
