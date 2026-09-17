extends Control

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

@onready var madera_label = $HBoxContainer/LabelMadera
@onready var piedra_label = $HBoxContainer/LabelPiedra
@onready var metal_label = $HBoxContainer/LabelMetal
@onready var comida_label = $HBoxContainer/LabelComida

func _ready() -> void:
	inventario.inventario_actualizado.connect(actualizar_ui)
	actualizar_ui()

func actualizar_ui():
	madera_label.text = "Madera: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.MADERA))
	piedra_label.text = "Piedra: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.PIEDRA))
	metal_label.text = "Metal: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.METAL))
	comida_label.text = "Comida: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.COMIDA))
