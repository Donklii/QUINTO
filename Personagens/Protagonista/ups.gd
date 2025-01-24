extends CanvasLayer


signal buff_escolhido


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_button_pressed(escolha: String) -> void:
	match escolha:
			"mov":
				print("mov")
				$"..".MaxDeAcoes += 1
			"hp":
				$"..".set_meta("MaxHp", $"..".get_meta("MaxHp")+2)
			"dmg":
				$"..".set_meta("Dano", $"..".get_meta("Dano")+1)
	visible = false
	buff_escolhido.emit()

func _on_protagonista_level_up(level) -> void:
	visible = true
