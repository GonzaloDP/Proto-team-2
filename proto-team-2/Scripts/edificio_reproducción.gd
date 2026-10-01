extends Edificio
class_name EdificioReproduccion

@onready var penalty_manager = get_tree().current_scene.get_node("PenaltiesManager")

@export var tiempo_reproduccion: float = 30.0
@export var escena_unidad: PackedScene

var padre_1: Unidad = null
var padre_2: Unidad = null
var reproduciendo: bool = false
var unidades_objetivo: Array[Unidad] = []

func _ready() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Unidad:
		return
	
	var unidad: Unidad = body
	
	if unidad not in unidades_objetivo:
		return
	if unidad.en_reproduccion:
		return
	if reproduciendo:
		return
	if not Level.puede_crear_unidad():
		return
	
	if padre_1 == null:
		padre_1 = unidad
		unidad.entrar_en_reproduccion(self)
		print("primer padre llego")
	elif padre_2 == null:
		padre_2 = unidad
		unidad.entrar_en_reproduccion(self)
		print("segundo padre llego")
		
		iniciar_coito()
func iniciar_coito():
	if reproduciendo:
		return
	
	reproduciendo = true
	
	var velocidad_reproduccion = penalty_manager.breeding_multiplier
	$Timer.wait_time = tiempo_reproduccion / velocidad_reproduccion
	$Timer.start()
	print("reproduciendose")
func _on_timer_timeout() -> void:
	print("terminó el follaje")
	
	if padre_1:
		padre_1.salir_de_reproduccion(padre_1.posicion_anterior)
	if padre_2:
		padre_2.salir_de_reproduccion(padre_2.posicion_anterior)
	
	crear_nueva_unidad()
	
	padre_1 = null
	padre_2 = null
	unidades_objetivo.clear()
	reproduciendo = false

func recibir_unidades(unidades: Array[CharacterBody3D]):
	if reproduciendo:
		print("Ya estan fornicando")
		return
	if unidades.size() != 2:
		print("Ya está lleno")
		return
	if not Level.puede_crear_unidad():
		print("Ya hay mucha gente")
		return
	
	unidades_objetivo.clear()
	
	for unidad in unidades:
		if unidad is Unidad and not unidad.en_reproduccion:
			unidades_objetivo.append(unidad)
	if unidades_objetivo.size() != 2:
		print("No se completo el coito")
		unidades_objetivo.clear()
		return
	
	print("Entraron a qlear")
	
	for unidad in unidades_objetivo:
		unidad.set_move_target(global_position)
func crear_nueva_unidad():
	if escena_unidad == null:
		print("ERROR no hay unidad")
		return
	
	var nueva_unidad = escena_unidad.instantiate()
	get_tree().current_scene.add_child(nueva_unidad)
	
	nueva_unidad.global_position = global_position
