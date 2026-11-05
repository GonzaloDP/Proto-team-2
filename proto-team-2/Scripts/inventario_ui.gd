extends Control

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")
@onready var unidad_maxima: int

@onready var madera_label = $VBoxContainer/HBoxContainer/LabelMadera
@onready var piedra_label = $VBoxContainer/HBoxContainer2/LabelPiedra
@onready var metal_label = $VBoxContainer/HBoxContainer3/LabelMetal
@onready var comida_label = $VBoxContainer/HBoxContainer4/LabelComida
@onready var poblacion_label = $"VBoxContainer/LabelPoblación"
@onready var icono_madera: TextureRect = $VBoxContainer/HBoxContainer/IconMadera
@onready var icono_piedra: TextureRect = $VBoxContainer/HBoxContainer2/IconPiedra
@onready var icono_metal: TextureRect = $VBoxContainer/HBoxContainer3/IconMetal
@onready var icono_comida: TextureRect = $VBoxContainer/HBoxContainer4/IconComida

var valores_anteriores: Dictionary = {}

func _ready() -> void:
	inventario.inventario_actualizado.connect(actualizar_ui)
	Level.poblacion_actualizada.connect(actualizar_ui)
	actualizar_ui()

func actualizar_ui() -> void:
	actualizar_recurso(
		Recurso.Tipo_Recurso.MADERA,
		madera_label,
		icono_madera
	)

	actualizar_recurso(
		Recurso.Tipo_Recurso.PIEDRA,
		piedra_label,
		icono_piedra
	)

	actualizar_recurso(
		Recurso.Tipo_Recurso.METAL,
		metal_label,
		icono_metal
	)

	actualizar_recurso(
		Recurso.Tipo_Recurso.COMIDA,
		comida_label,
		icono_comida
	)

	poblacion_label.text = "Población: " + str(
		Level.unidades_actuales, " / ", Level.limite_unidades
	)

func actualizar_recurso(tipo, label, icono) -> void:
	var cantidad = inventario.get_recurso(tipo)

	label.text = str(cantidad)

	if valores_anteriores.has(tipo):
		var anterior = valores_anteriores[tipo]

		if cantidad != anterior:
			animar_recurso(label, icono, cantidad > anterior)

	valores_anteriores[tipo] = cantidad

func animar_recurso(label: Label, icono: TextureRect, aumento: bool) -> void:
	# Color según el cambio
	var color = Color("#A6C45B") if aumento else Color("#B94B45")
	# Animación del icono
	var tween_icono = create_tween()
	tween_icono.tween_property(icono, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_icono.tween_property(icono, "scale", Vector2.ONE, 0.18)
	# Animación del número
	var tween_label = create_tween()
	tween_label.tween_property(label, "modulate", color, 0.1)

	tween_label.tween_interval(0.35)

	tween_label.tween_property(label, "modulate", Color.WHITE, 0.3)
