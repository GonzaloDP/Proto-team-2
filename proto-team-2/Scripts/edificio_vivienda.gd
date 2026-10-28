extends Edificio
class_name EdificioVivienda

@export var aumento_vivienda = 5

func _ready() -> void:
	pass

func construir():
	Level.aumentar_limite(aumento_vivienda)
	
#func checkForBuggedUnits():	#Chequeamos que no haya ninguna unidad dentro del edifico que no deba estar ahí (Pueden quedar buggeadas a veces). Si hay alguna unidad allí, entonces la movemos a otro lugar para liberarla.
	#print("Chequeando...")
	#for body in $Area3D.get_overlapping_bodies():
		#print("Tenemos uno.")
		#if(body.visible && body is Unidad):	#Chequeamos que la unidad esté visible. Las unidades que están comiendo o reproduciéndose se ocultan, así que estas no serán expulsadas por el método.
			#body.global_position = $PuntoRespawn.global_position
			#body.set_move_target($PuntoRespawn.global_position)
