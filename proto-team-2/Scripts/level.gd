extends Node3D
#Este script es solo para hacer unas validaciones, luego se puede borrar

@onready var tooltip = $UI/Tooltip

func _ready() -> void:
	tooltip.mostrar("Madera ", 25)

func _process(delta: float) -> void:
	pass


func _on_alimentar_debug_pressed():		#Este método (Y el grupo que utiliza) son enteramente para propósitos de Debug. Una vez se haya implementado el edificio comedor, este se encargará de decirle a las unidades que reinicien su hambre.
	for each in get_tree().get_nodes_in_group("Unidades"):
		each._resetSatiety()
