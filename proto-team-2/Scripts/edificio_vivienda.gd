extends Edificio

@export var aumento_vivienda = 5

func _ready() -> void:
	pass

func construir():
	Level.aumentar_limite(aumento_vivienda)
