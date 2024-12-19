extends Object

class_name Sequence

var children: Array = []

func execute() -> bool:
	for child in children:
		if not await child.execute():
			return false
	return true

func add_child(child) -> void:
	children.append(child)
