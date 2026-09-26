class_name RecursoRespawn
extends Recurso

enum tipo_recurso{ ARBUSTO, PIEDRAS, ARBOLES}

@export var cantidad: int = 60
@export var timer: float = 60.0

var tipo_respawn: tipo_recurso
var agotado := false

func _ready() -> void:
	tipo_respawn = tipo_recurso.values().pick_random()
	cantidad_variable = cantidad

func _process(delta: float) -> void:
	pass

func get_names() -> String:
	match tipo_respawn:
		tipo_recurso.ARBUSTO:
			return "Abusto"
		tipo_recurso.PIEDRAS:
			return "Piedras"
		tipo_recurso.ARBOLES:
			return "Arboles"
	
	return "desconocido"

func obtener_tipo_recurso() -> Recurso.Tipo_Recurso:
	match tipo_respawn:
		tipo_recurso.ARBUSTO:
			return Recurso.Tipo_Recurso.COMIDA
		tipo_recurso.PIEDRAS:
			return Recurso.Tipo_Recurso.PIEDRA
		tipo_recurso.ARBOLES:
			return Recurso.Tipo_Recurso.MADERA
	
	return Recurso.Tipo_Recurso.COMIDA

func reduceQuantity(quantity: int):
	if agotado:
		return
	
	cantidad_variable -= quantity
	
	if cantidad_variable <= 0:
		cantidad_variable = 0
		agotado = true
		respawn()

func respawn():
	await get_tree().create_timer(timer).timeout
	
	cantidad_variable = cantidad
	agotado = false
