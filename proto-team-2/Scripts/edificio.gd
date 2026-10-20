extends StaticBody3D
class_name Edificio

#@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var colision: CollisionShape3D = $CollisionShape3D
@onready var modelo: Node3D = get_node_or_null("Modelo")

@onready var barra_progreso = get_node_or_null("BarraProgreso")

@export var nombre_edificio: String = "Edificio"
@export var tipo_edificio: String = "General"
@export var completado: bool = false

var escenas_edificios = {
	"reproduccion": load("res://Escenas/Edificio_Reproducción.tscn"),
	"vivienda": preload("res://Escenas/Edificio_Vivienda.tscn"),
	"comedor": load("res://Escenas/Edificio_Comedor.tscn")
}

var puntos_totales: float = 100.0
var puntos_actuales: float = 0.0
var tipo_actual: String = ""

var base_instanciada: Node3D = null
var modelo_rojo: Node3D = null
var modelo_terminado: Node3D = null
var profundidad_inicial: float = -3.0
var posicion_original_y: float = 0.0

var costo_original: Dictionary = {}
var inventario_referencia: Inventario = null

var navigation3D: NavigationRegion3D = null
var camara_referencia: Node = null

func _ready() -> void:
	if completado:
		if barra_progreso:
			barra_progreso.hide()

func configurar_edificio(tipo_id: String, puntos_requeridos: float, 
	costo: Dictionary = {}, inventario_ref: Inventario = null, 
	navigation_ref: NavigationRegion3D = null, camara_ref: Node = null):
	tipo_actual = tipo_id
	puntos_totales = puntos_requeridos
	puntos_actuales = 0.0
	completado = false
	
	if modelo and escenas_edificios.has(tipo_id):
		for hijo in modelo.get_children():
			hijo.queue_free()
			
		var escena = escenas_edificios[tipo_id]
		base_instanciada = escena.instantiate()
		modelo.add_child(base_instanciada)
	else:
		base_instanciada = self 

	if base_instanciada:
		#Busqueda de variantes
		var variantes_encontradas = []
		for hijo in base_instanciada.get_children():
			if "Variante" in hijo.name:
				variantes_encontradas.append(hijo)
		
		#Elección al azar de variantes
		if variantes_encontradas.size() > 0:
			var variante_elegida = variantes_encontradas.pick_random()
			
			#Borrado de edificios que no salieron sorteados
			for v in variantes_encontradas:
				if v != variante_elegida:
					v.queue_free()
			
			#Enlazado de modelos del edificio elegido
			modelo_rojo = variante_elegida.get_node_or_null("Modelo_Rojo")
			modelo_terminado = variante_elegida.get_node_or_null("Modelo_Terminado")
		else:
			modelo_rojo = base_instanciada.get_node_or_null("Modelo_Rojo")
			modelo_terminado = base_instanciada.get_node_or_null("Modelo_Terminado")
		
		var nodo_referencia = modelo_rojo if modelo_rojo else modelo_terminado
		
		if nodo_referencia:
			posicion_original_y = nodo_referencia.position.y
			
			if modelo_rojo:
				modelo_rojo.visible = true
				modelo_rojo.position.y = profundidad_inicial
				
			if modelo_terminado:
				modelo_terminado.visible = true
				modelo_terminado.position.y = -50.0

	costo_original = costo.duplicate(true)
	inventario_referencia = inventario_ref
	navigation3D = navigation_ref
	camara_referencia = camara_ref
	
	#mesh_instance.scale = Vector3(1, 0.1, 1)
	
	if barra_progreso:
		barra_progreso.targetEdificio = self
		barra_progreso.show()

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = clamp(puntos_actuales / puntos_totales, 0.0, 1.0)
	
	#Edificio emerge
	if modelo_rojo: 
		modelo_rojo.position.y = lerp(profundidad_inicial, posicion_original_y, progreso)
		
	#mesh_instance.scale = Vector3(1, max(0.1, progreso), 1)
	
	if puntos_actuales >= (puntos_totales - 0.1):
		completado = true
		
		#Edificio construido se teletransporta hacia el edificio rojo desvanecido
		if modelo_rojo:
			modelo_rojo.queue_free()
			
		if modelo_terminado:
			modelo_terminado.position.y = posicion_original_y
		
		#mesh_instance.scale = Vector3(1, 1, 1)
		
		if barra_progreso:
			barra_progreso.hide()

func eliminar_edificio():
	if is_instance_valid(inventario_referencia):
		for tipo in costo_original.keys():
			var cantidad: int = int(floor(float(costo_original[tipo]) * 0.5))
			
			if cantidad > 0:
				inventario_referencia.agregar_recurso(tipo,cantidad)
	print("1. ANTES DE LIBERAR EL EDIFICIO")
	
	var camara := camara_referencia
	queue_free()
	
	print("2. DESPUÉS DE QUEUE FREE")
	
	if is_instance_valid(camara):
		camara.actualizar_navegacion_despues_de_demoler()
	else:
		print("ERROR: NO SE ENCONTRÓ LA CAMARA")
