extends Edificio
class_name EdificioVivienda

@export var aumento_vivienda = 5

func _ready() -> void:
	construir()

func construir():
	Level.aumentar_limite(aumento_vivienda)
