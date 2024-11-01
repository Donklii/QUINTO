extends Node
class_name Rastro

var nome: String
var forca:int
var decaimento: int
var passa_por_personagem: bool = true
var emissor: Personagem

func equals(rastro:Rastro) -> bool:
	return (nome == rastro.nome and
	forca == rastro.forca and
	decaimento == rastro.decaimento and
	emissor == rastro.emissor and
	passa_por_personagem == rastro.passa_por_personagem)

func copiar(rastro: Rastro):
	nome = rastro.nome
	forca = rastro.forca
	decaimento = rastro.decaimento
	emissor = rastro.emissor
	passa_por_personagem = rastro.passa_por_personagem
