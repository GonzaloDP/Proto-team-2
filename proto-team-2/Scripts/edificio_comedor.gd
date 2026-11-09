extends Edificio
class_name EdificioComedor

@export var tiempo_comida: float = 5.0
@export var distancia_para_comer: float = 3.0
@export var costo_alimentacion: int = 5

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

var unidades_comiendo: Array[Unidad] = []

func _ready() -> void:
	profundidad_inicial = -5.0	#Como el comedor es mucho más alto que los demás edificio, sobreescribimos el valor de la profundidad inicial.
	puntosDeSalida = [$PuntoRespawn, $PuntoRespawn2, $PuntoRespawn3]
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Unidad:
		var unidad := body as Unidad
		
		if unidad._isStarving() && completado:
			recibir_unidad(unidad)

#func _process(delta: float) -> void:
	#for unidad in get_tree().get_nodes_in_group("Unidades"):
		#if unidad.starving and not unidades_comiendo.has(unidad):
			#var distancia = global_position.distance_to(unidad.global_position)
			#
			#if distancia <= distancia_para_comer:
				#recibir_unidad(unidad)

func recibir_unidad(unidad: Unidad):
	if unidades_comiendo.has(unidad):
		return
	
	var cantidad_comida = inventario.get_recurso(Recurso.Tipo_Recurso.COMIDA)
	var comida_reservada = unidades_comiendo.size()
	
	if cantidad_comida - comida_reservada < costo_alimentacion:	#Chequeamos que haya suficiente comida para alimentar a la unidad.
		return
	
	unidades_comiendo.append(unidad)
	unidad.entrar_en_comedor()
	
	var timer := get_tree().create_timer(tiempo_comida)
	timer.timeout.connect(func(): terminar_comida(unidad))

func terminar_comida(unidad: Unidad):
	if not is_instance_valid(unidad):
		unidades_comiendo.erase(unidad)
		return
	
	inventario.reducir_recurso(Recurso.Tipo_Recurso.COMIDA, costo_alimentacion)	#Cuando la unidad termina de comer, descontamos la comida del inventario.
	
	unidad._resetSatiety()
	unidades_comiendo.erase(unidad)
	
	var objetivo_salida = $PuntoObjetivoSalida.global_position	#Expulsamos a la unidad del comedor, luego le pasamos el punto objetivo del comedor, para que se dirija hacia este.
	kickOutUnit(unidad)
	unidad.salir_del_comedor(objetivo_salida)

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = clamp(puntos_actuales / puntos_totales, 0.0, 1.0)
	
	#Edificio emerge
	if modelo_rojo: 
		modelo_rojo.position.y = lerp(profundidad_inicial, posicion_original_y, progreso)
		
	if puntos_actuales >= (puntos_totales - 0.1):
		completado = true
		$CleanUpTimer.start()
		add_to_group("Comedores")

		#Edificio construido se teletransporta hacia el edificio rojo desvanecido
		if modelo_rojo:
			modelo_rojo.queue_free()
			
		if modelo_terminado:
			modelo_terminado.position.y = posicion_original_y
		
		#mesh_instance.scale = Vector3(1, 1, 1)
		
		if barra_progreso:
			barra_progreso.hide()
		
func instaBuild(): #Con esta función, el comedor se construye instantáneamente, esto solo funciona para el primer comedor construido en la partida, a modo de facilitar el early game.
	puntos_totales = 1 #Setteando los puntos totales a uno, el comedor se construirá en cuanto una unidad le de el más mínimo esfuerzo.
