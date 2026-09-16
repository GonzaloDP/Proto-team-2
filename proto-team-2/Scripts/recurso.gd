class_name Recurso
extends Node3D

#Este "enum" sirve para enumerar constantes del "0"(siendo el primer parametro) hasta el último parametro(en este caso el "3"), es para no hacer varias escenas de lo mismo y resumirlo en una sola lista
enum Tipo_Recurso{ MADERA, PIEDRA, COMIDA, METAL}

#Cantidad con la que van a iniciar los recursos(quizás más adelante cambie a ser random)
@export var cantidad_inicial = 100

var tipo: Tipo_Recurso#Variable del tipo de lo que contenga la lista
var cantidad_variable : int#Cantidad de recurso que va a mostrar cuando nos diga la información de cada uno

func _ready() -> void:
	tipo = Tipo_Recurso.values().pick_random()
	cantidad_variable = cantidad_inicial

func _process(delta: float) -> void:
	pass

func get_names() -> String:
	match tipo:
		Tipo_Recurso.MADERA:
			return "Madera"
		Tipo_Recurso.PIEDRA:
			return "Piedra"
		Tipo_Recurso.COMIDA:
			return "Comida"
		Tipo_Recurso.METAL:
			return "Metal"
	
	return "Desconocido"
	
func reduceQuantity(quantity: int):	#Recibe un int, y reduce la cantidad de recursos restantes por ese número. Si la cantidad de recursos restantes tras la operación fuese menor a 0, se redondea a 0.
	cantidad_variable -= quantity
	if(cantidad_variable < 0):
		cantidad_inicial = 0 
