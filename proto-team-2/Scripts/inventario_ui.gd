extends Control

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")
@onready var unidad_maxima: int

@onready var madera_label = $VBoxContainer/HBoxContainer/LabelMadera
@onready var piedra_label = $VBoxContainer/HBoxContainer2/LabelPiedra
@onready var metal_label = $VBoxContainer/HBoxContainer3/LabelMetal
@onready var comida_label = $VBoxContainer/HBoxContainer4/LabelComida
@onready var poblacion_label = $"VBoxContainer/LabelPoblación"

func _ready() -> void:
	inventario.inventario_actualizado.connect(actualizar_ui)
	Level.poblacion_actualizada.connect(actualizar_ui)
	actualizar_ui()

func actualizar_ui():
	madera_label.text = "Madera: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.MADERA))
	piedra_label.text = "Piedra: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.PIEDRA))
	metal_label.text = "Metal: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.METAL))
	comida_label.text = "Comida: " + str(inventario.get_recurso(Recurso.Tipo_Recurso.COMIDA))
	poblacion_label.text = "Población: " + str(Level.unidades_actuales," / ", Level.limite_unidades)
