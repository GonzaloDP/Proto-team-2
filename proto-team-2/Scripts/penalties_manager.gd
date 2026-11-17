extends Node
class_name PenaltiesManager

enum PenaltyType {
	TAX,
	UNIT_KILL,
	DEFEAT
}

@onready var cuota = $"../Cuota"
@onready var daymanager = $"../DayManager"
@onready var inventario = $"../Inventario"

signal penalty_apllied(penalty)
signal penalty_removed()
signal units_killed()

var recolection_multiplier := 1.0
var construction_multiplier := 1.0
var breeding_multiplier := 1.0
var actual_penalty = null
var cuota_fail := false
var penalty_level: int = 0
var penalties = [
	{
		"dias": 1,
		"tipo": PenaltyType.TAX,
		"valor": 0.5
	},
	{
		"dias": 2,
		"tipo": PenaltyType.UNIT_KILL,
		"valor": 0.20
	},
	{
		"dias": 3,
		"tipo": PenaltyType.DEFEAT,
		"valor": 1
	}
	
	
]


func _ready() -> void:
	cuota.cuota_incumplida.connect(start_failed_cuota)
	cuota.cuota_pagada.connect(end_penalty)
	daymanager.dia_cambio.connect(dia_cambio)
	
func start_failed_cuota():
	if cuota_fail:
		return
	cuota_fail = true
	
func end_penalty():
	cuota_fail = false
	penalty_removed.emit()

func dia_cambio(dia_actual : int):
	if not cuota_fail:
		return
	check_penalty()

func check_penalty():
	if penalty_level >= 0 && penalty_level < 3:
		apply_penalty(penalties[penalty_level])
		penalty_level += 1
		
func apply_penalty(penalty):
	var tipo = penalty["tipo"]
	var valor = penalty["valor"]
	
	match tipo:
		PenaltyType.TAX:
			inventario._reducir_inventario_a_la_mitad()
			print("1ra penalización: Cuota perdonada, a cambio de la mitad de tus recursos." )
			cuota._forgive_quota()
			#Okay! Esta es la parte donde aparecería Dios con su diálogo sobre quitarte la mitad del inventario a cambio de perdonarte la cuota.
		PenaltyType.UNIT_KILL:
			units_killed.emit()
			Level._matar_unidades()	#Llamamos, no al level que conocemos de toda la vida si no a un super Level con mayúscula.
			print("2da penalización: Dios elimina a algunas de tus unidades.")
			#Y en esta parte, mataría a algunas de tus unidades.
		PenaltyType.DEFEAT:
			$"../UI/DefeatScreen"._showDefeatScreen()
	penalty_apllied.emit(penalty)
	
