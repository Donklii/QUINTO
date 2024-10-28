extends CharacterBody2D
class_name Protagonista

var movendo: bool = false

signal acabou_acao

func _process(delta: float) -> void:
	var quadrantebusca: Quadrante = null
	var forca: int = 0
	for quadrante in $Area2D.get_overlapping_bodies():
		if quadrante is Quadrante:
			for rastro in quadrante.lista_de_rastros:
				if rastro.nome == "viado":
					if rastro.forca > forca:
						quadrantebusca = quadrante
						forca = rastro.forca
	
	if quadrantebusca and not movendo:
		mover_ate_quadrante(quadrantebusca)
	
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("Idle")
		
	

func mover_ate_quadrante(quadrantebusca):
	movendo = true
	print("comecou a mover")
	while quadrantebusca.global_position.distance_to(global_position) > 5:
		var direction = (quadrantebusca.global_position - position).normalized()
		velocity = direction * 100
		
		move_and_slide()
		await get_tree().process_frame
	
	velocity = Vector2(0,0)
	movendo = false
	acabou_acao.emit()
	get_parent().fim_da_acao.emit()
