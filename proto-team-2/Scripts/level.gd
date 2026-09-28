extends Node3D
#Este script es solo para hacer unas validaciones, luego se puede borrar

@onready var tooltip = $UI/Tooltip
@onready var cantidad_maxima_unidades: int

var unidades_actuales: int = 0
var limite_unidades: int = 10

func _ready() -> void:
	tooltip.mostrar("Madera ", 25)
	cantidad_maxima_unidades = 5

func _process(delta: float) -> void:
	pass

func puede_crear_unidad() -> bool:
	return unidades_actuales < limite_unidades

func agregar_unidad():
	if puede_crear_unidad():
		unidades_actuales += 1

func aumentar_limite(cantidad: int):
	limite_unidades += cantidad
