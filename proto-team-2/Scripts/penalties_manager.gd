extends Node
class_name PenaltiesManager

enum PenaltyType {
	RECOLECTION,
	CONTRUCTION,
	BREEDING,
	UNITY_KILL,
	DEFEAT
}

@onready var cuota = $"../Cuota"
@onready var daymanager = $"../DayManager"

signal penalty_apllied(penalty)
signal penalty_removed()

var recolection_multiplier := 1.0
var construction_multiplier := 1.0
var breeding_multiplier := 1.0
var actual_penalty = null
var cuota_fail := false
var dias_sin_pagar := 0 
var penalty_level: int = -1
var penalties = [
	{
		"dias": 1,
		"tipo": PenaltyType.RECOLECTION,
		"valor": 0.10
	},
	{
		"dias": 3,
		"tipo": PenaltyType.RECOLECTION,
		"valor": 0.20
	},
	{
		"dias": 5,
		"tipo": PenaltyType.CONTRUCTION,
		"valor": 0.30
	},
	{
		"dias": 7,
		"tipo": PenaltyType.BREEDING,
		"valor": 0.30
		
	},
	{
		"dias": 10,
		"tipo": PenaltyType.UNITY_KILL,
		"valor": 1
	},
	{
		"dias": 12,
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
	dias_sin_pagar = 0
	
func end_penalty():
	cuota_fail = false
	dias_sin_pagar = 0
	penalty_level = -1
	
	recolection_multiplier = 1.0
	construction_multiplier = 1.0
	breeding_multiplier = 1.0

func dia_cambio(dia_actual : int):
	if not cuota_fail:
		return
	dias_sin_pagar += 1
	check_penalty()

func check_penalty():
	var new_level := -1
	for i in range(penalties.size()):
		if dias_sin_pagar >= penalties[i]["dias"]:
			new_level = i
	if new_level == penalty_level:
		return
	penalty_level = new_level
	if penalty_level >= 0:
		apply_penalty(penalties[penalty_level])
	
func apply_penalty(penalty):
	var tipo = penalty["tipo"]
	var valor = penalty["valor"]
	
	match tipo:
		PenaltyType.RECOLECTION:
			recolection_multiplier = 1.0 - valor
			print("Penalización de Recolección: -", valor * 100, "%" )
		PenaltyType.CONTRUCTION:
			construction_multiplier = 1.0 - valor
			print("Penalización de Construcción: -", valor * 100, "%" )
		PenaltyType.BREEDING:
			breeding_multiplier = 1.0 - valor
			print("Penalización de Reproducción: -", valor * 100, "%" )
		PenaltyType.UNITY_KILL:
			print("se ha muerto una unidad" )
		PenaltyType.DEFEAT:
			print("FIN DEL JUEGO: PERDISTE")
	
