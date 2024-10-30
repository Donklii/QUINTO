extends Node
class_name Rastro

var nome: String
var forca:int
var decaimento: int
var emissor: Personagem

func equals(rastro:Rastro) -> bool:
	if nome == rastro.nome and forca == rastro.forca and decaimento == rastro.decaimento:
		return true
	else:
		return false

func copiar(rastro: Rastro):
	nome = rastro.nome
	forca = rastro.forca
	decaimento = rastro.decaimento
	emissor = rastro.emissor
