extends Edificio
class_name EdificioComedor

@export var tiempo_comida: float = 5.0
@export var distancia_para_comer: float = 3.0

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

var unidades_comiendo: Array[Unidad] = []

func _ready() -> void:
	pass
	
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
	
	if cantidad_comida - comida_reservada < 1:
		return
	
	unidades_comiendo.append(unidad)
	unidad.entrar_en_comedor()
	
	var timer := get_tree().create_timer(tiempo_comida)
	timer.timeout.connect(func(): terminar_comida(unidad))

func terminar_comida(unidad: Unidad):
	if not is_instance_valid(unidad):
		unidades_comiendo.erase(unidad)
		return
	
	inventario.reducir_recurso(Recurso.Tipo_Recurso.COMIDA, 1)
	
	unidad._resetSatiety()
	unidades_comiendo.erase(unidad)
	
	var posicion_salida = $PuntoRespawn.global_position	#Tomamos los puntos de spawn y de objetivo del comedor para darselos a la unidad. Estos determinarán, respectivamente, donde aparecerá la unidad al salir, y hacia donde se moverá.
	var objetivo_salida = $PuntoObjetivoSalida.global_position
	unidad.salir_del_comedor(posicion_salida, objetivo_salida)

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = clamp(puntos_actuales / puntos_totales, 0.0, 1.0)
	
#	mesh_instance.scale = Vector3(1, max(0.1,progreso), 1)
	#mesh_instance.scale = Vector3(1, max(0.1, progreso), 1)
	
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
