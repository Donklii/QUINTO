extends Fantasma
class_name PhantomInimigo

var arvore: Selector

func _init(_geracao: String, inspiracao: Object) -> void:
	super._init(_geracao, inspiracao)
	acoes = ["agir"]
	arvore = criar_arvore_decisao()

func agir():
	arvore.execute()




func criar_arvore_decisao() -> Selector:
	var root_selector = Selector.new()
	
	#--------------inimigo_sequence--------------
	var inimigo_sequence = Sequence.new()
	
	var detectar_inimigo_condition = Condition.new()
	detectar_inimigo_condition.set_function(self, "_detectar_inimigos")
	inimigo_sequence.add_child(detectar_inimigo_condition)
	
	var causar_dano_action = Action.new()
	causar_dano_action.set_function(self, "_causar_dano")
	inimigo_sequence.add_child(causar_dano_action)
	
	
	root_selector.add_child(inimigo_sequence)
	
	#--------------busca_sequence--------------
	var busca_sequence = Sequence.new()
	
	var mover_ate_quadrante_action = Action.new()
	mover_ate_quadrante_action.set_function(self, "mov")
	busca_sequence.add_child(mover_ate_quadrante_action)
	
	
	root_selector.add_child(busca_sequence)
	
	
	return root_selector


func _detectar_inimigos() -> bool:
	return !detectarInimigos().is_empty()


func _causar_dano() -> bool:
	atacar()
	return true
