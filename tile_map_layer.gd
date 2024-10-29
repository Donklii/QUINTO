extends TileMapLayer

const QUADRANTE = preload("res://quadrante.tscn")
var tile_count:int = 0
var andavel_count: int = 0
var nao_andavel_count: int = 0

func adicionar_quadrantes() -> void:
	
	# Itera sobre todas as células do TileMap
	for cell in get_used_cells():
		var cell_position = map_to_local(cell)
		
		var tile_data : TileData = get_cell_tile_data(cell)
		
		var andavel = tile_data.get_custom_data("Andavel")
		
		if andavel:
			andavel_count += 1
			var quadranteNovo: Quadrante = QUADRANTE.instantiate()
			quadranteNovo.global_position = cell_position
			quadranteNovo.name = "Quadrante X:"+ str(quadranteNovo.global_position.x) +str(" Y:") + str(quadranteNovo.global_position.y)
			add_sibling(quadranteNovo)
		else:
			nao_andavel_count += 1
		
		tile_count += 1

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	await get_tree().process_frame
	adicionar_quadrantes()
	print(tile_count)
	print("Andavel: "+str(andavel_count))
	print("Não andavel: "+str(nao_andavel_count))
	await get_tree().process_frame
	get_parent().pronto.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
