extends Node3D
#Este script es solo para hacer unas validaciones, luego se puede borrar

@onready var tooltip = $UI/Tooltip

func _ready() -> void:
	tooltip.mostrar("Madera ", 25)

func _process(delta: float) -> void:
	pass
