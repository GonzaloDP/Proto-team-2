extends Node3D
#Este script es solo para hacer unas validaciones, luego se puede borrar

signal poblacion_actualizada

var cantidad_maxima_unidades: int = 5
var unidades_actuales: int = 0
var limite_unidades: int = 10

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func puede_crear_unidad() -> bool:
	return unidades_actuales < limite_unidades

func agregar_unidad():
	if puede_crear_unidad():
		unidades_actuales += 1
		poblacion_actualizada.emit()

func quitar_unidades():
	if unidades_actuales > 0:
		unidades_actuales -= 1
		poblacion_actualizada.emit()

func aumentar_limite(cantidad: int):
	limite_unidades += cantidad
