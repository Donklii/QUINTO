extends Object

class_name Action

var action_function: Callable

func execute() -> bool:
	if action_function:
		return await action_function.call()
	else:
		print("Action: Nenhuma função atribuída!")
		return false

func set_function(target: Object, method_name: String) -> void:
	action_function = Callable(target, method_name)
