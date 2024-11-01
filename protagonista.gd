extends Personagem
class_name Protagonista


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
	rastrosDesejados = ["test", "tesouro", "inimigo", "vida"]



func _process(_delta: float) -> void:
	if abs(velocity.x) > 10 or abs(velocity.y) >10:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("Idle")


func _on_acabou_acao() -> void:
	pass
