extends Personagem
class_name Inimigo

var xpDrop: int = 1


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


func _on_acabou_acao() -> void:
	pass
