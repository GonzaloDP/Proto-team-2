extends Control

@onready var cuota: Cuota = get_tree().current_scene.get_node("Cuota")
@onready var day_manager = $"../../DayManager"

@onready var dias_label = $VBoxContainer/DiasRestantes
@onready var madera_label = $VBoxContainer/Madera
@onready var piedra_label = $VBoxContainer/Piedra
@onready var metal_label = $VBoxContainer/Metal
@onready var comida_label = $VBoxContainer/Comida
@onready var notificacion: Label = $"cuota pago"
@onready var penalties_manager: PenaltiesManager = get_tree().current_scene.get_node("PenaltiesManager")
@onready var notificacion_penalizacion: RichTextLabel = $"../Panel/VBoxContainer/RichTextLabel"
@onready var boton_continuar: Button = $"../Panel/VBoxContainer/Button"
@onready var panel_penalizacion: Panel = $"../Panel"

var tween_penalizacion: Tween
var mostrando_penalizacion := false 

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_penalizacion.process_mode = Node.PROCESS_MODE_ALWAYS
	
	panel_penalizacion.hide()
	boton_continuar.hide()
	
	boton_continuar.pressed.connect(continuar_juego)
	
	cuota.cuota_actualizada.connect(actualizar_recursos)
	penalties_manager.penalty_apllied.connect(mostrar_penalizacion)
	cuota.cuota_incumplida.connect(mostrar_penalizacion)
	day_manager.dia_cambio.connect(actualizar_dias)
	day_manager.actualizar_ui.connect(actualizar_dias)
	
	actualizar_recursos()
	actualizar_dias(1)

func actualizar_recursos():
	madera_label.text = "Madera: " + str(cuota.quota[Recurso.Tipo_Recurso.MADERA])
	piedra_label.text = "Piedra: " + str(cuota.quota[Recurso.Tipo_Recurso.PIEDRA])
	metal_label.text = "Metal: " + str(cuota.quota[Recurso.Tipo_Recurso.METAL])
	comida_label.text = "Comida: " + str(cuota.quota[Recurso.Tipo_Recurso.COMIDA])

func actualizar_dias(dia_actual: int):
	var dias_restantes = cuota.deadlineDay - dia_actual
	if(dias_restantes < 0):
		dias_restantes = 0
	dias_label.text = "Días restantes: " + str(dias_restantes)

func mostrar_cuota_pagada():
	notificacion.visible = true
	notificacion.modulate = Color("#A6C45B")
	notificacion.scale = Vector2.ONE

	var tween = create_tween()

	tween.tween_property(notificacion,"scale",Vector2(1.2, 1.2),0.15)
	tween.tween_property(notificacion,"scale",Vector2.ONE,0.15)
	tween.tween_interval(1.5)
	tween.tween_property(notificacion,"modulate:a",0.0,0.4)
	tween.tween_callback(func(): notificacion.visible = false)

func mostrar_penalizacion(penalty: Dictionary):
	if mostrando_penalizacion:
		return
	
	mostrando_penalizacion = true
	
	var tipo = penalty["tipo"]
	
	match tipo:
		PenaltiesManager.PenaltyType.TAX:
			notificacion_penalizacion.text = "¡La mitad de tu inventario fue cobrado!"
		PenaltiesManager.PenaltyType.UNIT_KILL:
			notificacion_penalizacion.text = "¡Haz perdido una unidad!"
		PenaltiesManager.PenaltyType.DEFEAT:
			notificacion_penalizacion.text = "¡Derrota!"
	
	panel_penalizacion.show()
	notificacion_penalizacion.modulate = Color("#B94B45")
	notificacion_penalizacion.modulate.a = 1.0
	notificacion_penalizacion.scale = Vector2.ONE
	
	boton_continuar.hide()
	
	get_tree().paused = true
	
	var tween = create_tween()
	tween.tween_property(
		notificacion_penalizacion,
		"scale",
		Vector2(1.2, 1.2),
		0.15
	)
	tween.tween_property(
		notificacion_penalizacion,
		"scale",
		Vector2.ONE,
		0.15
	)
	
	await get_tree().create_timer(3.0, true).timeout
	
	boton_continuar.show()

func animar_penalizacion():
	
	if tween_penalizacion and tween_penalizacion.is_running():
		tween_penalizacion.kill()
	notificacion_penalizacion.visible = true
	notificacion_penalizacion.modulate = Color("#B94B45")
	notificacion_penalizacion.scale = Vector2.ONE
	tween_penalizacion = create_tween()
	tween_penalizacion.tween_property(notificacion_penalizacion, "scale", Vector2(1.2, 1.2), 0.15)
	tween_penalizacion.tween_property(notificacion_penalizacion, "scale", Vector2.ONE, 0.15)
	tween_penalizacion.tween_interval(2.0)
	tween_penalizacion.tween_property(notificacion_penalizacion, "modulate:a", 0.0, 0.4)
	tween_penalizacion.tween_callback(func(): notificacion_penalizacion.visible = false)

func continuar_juego():
	panel_penalizacion.hide()
	boton_continuar.hide()
	
	mostrando_penalizacion = false
	
	get_tree().paused = false
