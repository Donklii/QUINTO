extends Object

class_name Selector

var children: Array = []

func execute() -> bool:
	for child in children:
		if await child.execute():
			return true
	return false

func add_child(child) -> void:
	children.append(child)
