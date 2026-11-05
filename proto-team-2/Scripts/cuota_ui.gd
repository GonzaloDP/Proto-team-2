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
@onready var notificacion_penalizacion: Label =$"cuota impago"
var tween_penalizacion: Tween

func _ready():
	cuota.cuota_actualizada.connect(actualizar_recursos)
	penalties_manager.penalty_apllied.connect(mostrar_penalizacion)
	cuota.cuota_incumplida.connect(mostrar_penalizacion)
	day_manager.dia_cambio.connect(actualizar_dias)
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
	var tipo = penalty["tipo"]    
	var valor = penalty["valor"]    
	match tipo:        
		PenaltiesManager.PenaltyType.RECOLECTION:            
			notificacion_penalizacion.text = "¡Recolección reducida un " + str(int(valor * 100)) + "%!"        
		PenaltiesManager.PenaltyType.CONTRUCTION:            
			notificacion_penalizacion.text = "¡Construcción reducida un " + str(int(valor * 100)) + "%!"        
		PenaltiesManager.PenaltyType.BREEDING:           
			notificacion_penalizacion.text = "¡Reproducción reducida un " + str(int(valor * 100)) + "%!"      
		PenaltiesManager.PenaltyType.UNITY_KILL:            
			notificacion_penalizacion.text = "¡Has perdido una unidad!"
		PenaltiesManager.PenaltyType.DEFEAT:
			notificacion_penalizacion.text = "¡Derrota!"
	animar_penalizacion()


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
