extends Object

class_name Condition

var condition_function: Callable

func execute() -> bool:
	if condition_function:
		return await condition_function.call()
	else:
		print("Condition: Nenhuma função de condição atribuída!")
		return false

func set_function(target: Object, method_name: String) -> void:
	condition_function = Callable(target, method_name)
