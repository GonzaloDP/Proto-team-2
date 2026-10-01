extends Node
class_name Cuota

@export var deadline_increase : int
@export var difficulty_increase : int
var deadlineDay
var difficulty
@onready var day_manager = $"../DayManager"
@onready var inventario = $"../Inventario"
signal cuota_actualizada
signal cuota_incumplida
signal cuota_pagada

var quota = {
Recurso.Tipo_Recurso.MADERA: 0,
Recurso.Tipo_Recurso.PIEDRA: 0,
Recurso.Tipo_Recurso.COMIDA: 0,
Recurso.Tipo_Recurso.METAL: 0
}
# Called when the node enters the scene tree for the first time.
func _ready():
	deadlineDay = 0
	difficulty = 0
	day_manager.dia_cambio.connect(checkDeadline)
	setNewQuota()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func checkDeadline(dia_actual: int): #Chequeamos el día en el que se debe entregar la cuota contra el día actual. Si ha pasado el día de entrega, entonces cobramos.
	if(deadlineDay < dia_actual):
		collectQuota()
	
func collectQuota():
	for each in quota:	#Chequeamos primero que se pueda pagar toda la cuota al mismo tiempo. Si algún elemento de la cuota es mayor a la cantidad de recursos que tiene el jugador, aplicamos la penalización y nos detenemos.
		if(quota[each] > inventario.recursos[each]):
			print("Aquí es donde se aplicaría una penalización.")
			cuota_incumplida.emit()
			return
	
	for each in quota: #En este loop cobramos correctamente. No chequeamos nada ya que lo hicimos en el paso anterior, solo reducimos los recursos.
		inventario.reducir_recurso(each, quota[each])
	
	cuota_pagada.emit()
	difficulty += difficulty_increase #Aumentamos la dificultad con cada cuota pagada. Aquí también se enviaría una señal para indicar que el jugador ha pagado una cuota, para marcar su progreso.
	setNewQuota()
	
func setNewQuota():
	deadlineDay =  day_manager.dia_actual + deadline_increase
	var resource1 = randi_range(1,4)	#Estos números aleatorios determinan que recursos se pedirán en la próxima cuota.
	var resource2 = randi_range(1,4)
	
	match(resource1):
		1:
			quota[Recurso.Tipo_Recurso.MADERA] += 10 + difficulty
		2:
			quota[Recurso.Tipo_Recurso.PIEDRA] += 10 + difficulty
		3:
			quota[Recurso.Tipo_Recurso.COMIDA] += 10 + difficulty
		4: 
			quota[Recurso.Tipo_Recurso.METAL] += 5 + difficulty/2	#Ya que el metal es más difícil de conseguir, solo se pide la mitad relativo a los otros recursos.
	
	match(resource2):
		1:
			quota[Recurso.Tipo_Recurso.MADERA] += 10 + difficulty
		2:
			quota[Recurso.Tipo_Recurso.PIEDRA] += 10 + difficulty
		3:
			quota[Recurso.Tipo_Recurso.COMIDA] += 10 + difficulty
		4: 
			quota[Recurso.Tipo_Recurso.METAL] += 5 + difficulty/2	#Ya que el metal es más difícil de conseguir, solo se pide la mitad relativo a los otros recursos.

	cuota_actualizada.emit()
	
func applyPenalty(): #Método para aplicar la penalización si los recursos son insuficientes para pagar la cuota. Por ahora vacío.
	pass
