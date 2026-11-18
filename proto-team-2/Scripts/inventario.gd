extends Node
class_name Inventario

signal inventario_actualizado

@onready var day_manager = $"../DayManager"

var recursos = {
Recurso.Tipo_Recurso.MADERA: 25,
Recurso.Tipo_Recurso.PIEDRA: 25,
Recurso.Tipo_Recurso.COMIDA: 20,
Recurso.Tipo_Recurso.METAL: 0
}

var comida_recolectada_dia: int = 0
var ordenes_comida_dia: int = 0

func _ready() -> void:
	day_manager.dia_cambio.connect(_on_dia_cambio)

func agregar_recurso(tipo: Recurso.Tipo_Recurso, cantidad:int):
	recursos[tipo] += cantidad
	
	if tipo == Recurso.Tipo_Recurso.COMIDA:
		Metrics.record_add("comida_recolectada_total", cantidad)
		comida_recolectada_dia += cantidad
	
	inventario_actualizado.emit()

func get_recurso(tipo:Recurso.Tipo_Recurso) -> int:
	return recursos[tipo]

func reducir_recurso(tipo: Recurso.Tipo_Recurso, cantidad:int):
	recursos[tipo] -= cantidad
	inventario_actualizado.emit()

func _on_dia_cambio(_nuevo_dia: int):
	Metrics.record_add("comida_recolectada_diaria", comida_recolectada_dia)
	comida_recolectada_dia = 0
	
	Metrics.record_add("ordenes_comida_diarias", ordenes_comida_dia)
	ordenes_comida_dia = 0
	
	Metrics.record_add("comida_inventario_diario", get_recurso(Recurso.Tipo_Recurso.COMIDA))
	
func _reducir_inventario_a_la_mitad():	#Reducimos los valores de los recursos a la mitad.
	for each in recursos:
		#if(recursos[each]%10 && recursos[each] > 0):	 Para los que terminen en 5 (determinado como no ser divisibles por 10), les quitamos 5 más, ya que de otro modo quedarían con 2, lo que no sirve para nada.
		#	recursos[each] -= 5	#Me di cuenta de que ya la cuota nos va a dar números horribles. Que se jodan.
		recursos[each] /= 2
	inventario_actualizado.emit()
