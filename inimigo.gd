extends Personagem
class_name Inimigo

func set_rastrosDeixados() -> void:
	var rastronovo: Rastro = Rastro.new()
	rastronovo.nome = "inimigo"
	rastronovo.decaimento = 5
	rastronovo.forca = 100
	rastronovo.emissor = self
	rastronovo.passa_por_personagem = false
	
	rastrosDeixados.append(rastronovo)

func set_rastrosDesejados() -> void:
	rastrosDesejados = ["protagonista"]


func _process(_delta: float) -> void:
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.stop()


func _on_acabou_acao() -> void:
	pass
