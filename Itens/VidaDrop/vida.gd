extends Entidade
class_name VidaDrop

func set_rastrosDeixados() -> void:
	var rastronovo2: Rastro = Rastro.new()
	rastronovo2.nome = "vida"
	rastronovo2.decaimento = 20
	rastronovo2.forca = 400
	rastronovo2.emissor = self
	rastronovo2.passa_por_personagem = true
	rastrosDeixados.append(rastronovo2)

func _ready() -> void:
	await game_manager.pronto
	
	set_rastrosDeixados()
	
	calcularDistanciaDoMaiorRastro()
	
	set_quadrante()

func usar(personagem: Personagem) -> void:
	personagem.recuperar_vida(3)
	quadranteAtual.desocupar(self)
	queue_free()
