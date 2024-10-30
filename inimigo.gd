extends Personagem
class_name Inimigo

func set_rastrosDeixados():
	var rastronovo2: Rastro = Rastro.new()
	rastronovo2.nome = "inimigo"
	rastronovo2.decaimento = 5
	rastronovo2.forca = 100
	rastronovo2.emissor = self
	
	rastrosDeixados.append(rastronovo2)

func set_rastrosDesejados():
	rastrosDesejados = ["protagonista"]


func _process(_delta: float) -> void:
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.stop()


func _on_acabou_acao() -> void:
	pass
