extends Node
class_name Inventario

signal inventario_actualizado

var recursos = {
Recurso.Tipo_Recurso.MADERA: 0,
Recurso.Tipo_Recurso.PIEDRA: 0,
Recurso.Tipo_Recurso.COMIDA: 0,
Recurso.Tipo_Recurso.METAL: 0
}

func agregar_recurso(tipo: Recurso.Tipo_Recurso, cantidad:int):
	recursos[tipo] += cantidad
	inventario_actualizado.emit()

func get_recurso(tipo:Recurso.Tipo_Recurso) -> int:
	return recursos[tipo]

# Called when the node enters the scene tree for the first time.
