extends CanvasLayer

@onready var mapa: Node = $".."

func ordenar_lista_de_turnos():
	for child in $Imagens.get_children():
		child.queue_free()
	var turno_atual_index = mapa.lista_de_acao.find(mapa.dono_do_turno)
	
	
	var lista_ordenada = []
	for i in range(mapa.lista_de_acao.size()):
		var indice = (turno_atual_index + i) % mapa.lista_de_acao.size()
		lista_ordenada.append(mapa.lista_de_acao[indice])
	
	
	var posicao_y: int = 0
	for personagem in lista_ordenada:
		var imagemnova: AnimatedSprite2D = AnimatedSprite2D.new()
		imagemnova.sprite_frames = personagem.get_node("AnimatedSprite2D").sprite_frames
		imagemnova.frame = 0
		imagemnova.position.y = posicao_y
		$Imagens.add_child(imagemnova)
		posicao_y += 30
		
		if personagem == lista_ordenada[-1]:
			imagemnova.modulate.a = 0
			imagemnova.position.x -= 150
			
			for i in range(80):
				imagemnova.position.x += 1.875
				imagemnova.modulate.a += 0.0125
				await get_tree().process_frame

func fim_do_turno():
	for i in range(20):
		$Imagens.get_child(0).position.x -= 10
		$Imagens.get_child(0).modulate.a -= 0.05
		await get_tree().process_frame
	
	for i in range(30):
		for child in $Imagens.get_children():
			child.position.y -= 1
		await get_tree().process_frame
	
	
