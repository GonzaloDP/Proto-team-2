extends Panel

@onready var label: Label = $MarginContainer/Label

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func mostrar(nombre: String, cantidad: int):
	label.text = nombre  + "\nCantidad: " + str(cantidad)
	show()

func ocultar():
	hide()
