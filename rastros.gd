extends Node
class_name Rastro

var nome: String
var forca:int
var decaimento: int

func equals(rastro:Rastro) -> bool:
	if nome == rastro.nome and forca == rastro.forca and decaimento == rastro.decaimento:
		return true
	else:
		return false
