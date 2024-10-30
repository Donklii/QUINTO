extends TileMapLayer

const QUADRANTE = preload("res://quadrante.tscn")
var tile_count:int = 0
var andavel_count: int = 0
var nao_andavel_count: int = 0

var quadrante_matrix: Array[Array] = []

func adicionar_quadrantes() -> void:

	# Define os limites da matriz para incluir todas as células do TileMap
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for cell in get_used_cells():
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	
	# Inicializa a matriz de quadrantes com tamanho baseado nas dimensões do TileMap
	quadrante_matrix.resize(max_x - min_x + 1)
	
	for i in range(quadrante_matrix.size()):
		quadrante_matrix[i] = []
		quadrante_matrix[i].resize(max_y - min_y + 1)
	
	
	for cell in get_used_cells():
		var cell_position = map_to_local(cell)
		var tile_data : TileData = get_cell_tile_data(cell)
		var andavel = tile_data.get_custom_data("Andavel")
		
		if andavel:
			andavel_count += 1
			var quadranteNovo: Quadrante = QUADRANTE.instantiate()
			quadranteNovo.global_position = cell_position
			quadranteNovo.name = "Quadrante X:" + str(quadranteNovo.global_position.x) + " Y:" + str(quadranteNovo.global_position.y)
			add_sibling(quadranteNovo)
			
			# Armazena o quadrante na matriz de quadrantes com o índice ajustado
			quadrante_matrix[cell.x - min_x][cell.y - min_y] = quadranteNovo ## ChatGpt Gênio
			quadranteNovo.posicao = Vector2(cell.x - min_x,cell.y - min_y)
		else:
			nao_andavel_count += 1
			# Marca como nulo na matriz onde não há quadrante
			quadrante_matrix[cell.x - min_x][cell.y - min_y] = null
		
		tile_count += 1
	
	for x in quadrante_matrix:
		for y in x:
			if y != null:
				y.quadrante_matrix = quadrante_matrix



func _ready() -> void:
	await get_tree().process_frame
	adicionar_quadrantes()
	print(tile_count)
	print("Andavel: "+str(andavel_count))
	print("Não andavel: "+str(nao_andavel_count))
	await get_tree().process_frame
	get_parent().pronto.emit()
