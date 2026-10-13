extends StaticBody3D
class_name Edificio

#@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var colision: CollisionShape3D = $CollisionShape3D
@onready var modelo: Node3D = get_node_or_null("Modelo") #Era: #@onready var modelo: Node3D = $Modelo

@onready var barra_progreso = get_node_or_null("BarraProgreso")

@export var nombre_edificio: String = "Edificio"
@export var tipo_edificio: String = "General"
@export var completado: bool = false

var escenas_edificios = {
	#"reproduccion": preload("res://Escenas/Edificio_Reproducción.tscn"),
	"vivienda": preload("res://Escenas/Edificio_Vivienda.tscn"),
	#"comedor": preload("res://Escenas/Edificio_Comedor.tscn")
}

var puntos_totales: float = 100.0
var puntos_actuales: float = 0.0
var tipo_actual: String = ""

var base_instanciada: Node3D = null
var modelo_rojo: Node3D = null
var modelo_terminado: Node3D = null
var profundidad_inicial: float = -3.0
var posicion_original_y: float = 0.0

func _ready() -> void:
	if completado:
		if barra_progreso:
			barra_progreso.hide()

func configurar_edificio(tipo_id: String, puntos_requeridos: float):
	tipo_actual = tipo_id
	puntos_totales = puntos_requeridos
	puntos_actuales = 0.0
	completado = false
	
	#for hijo in modelo.get_children():
		#hijo.queue_free()
	# Acá se cambian los assets de los edificios, como prueba se estableció un mesh instance (quitarlo*)
	#match tipo_id:
		#"reproduccion":
		## Usar mesh_instance.mesh = load("res://modelo_super_jelou")
			#mesh_instance.mesh = BoxMesh.new() # <-- Quitar esta mierda una vez con los modelos
			#mesh_instance.mesh.size = Vector3(2, 2, 2)
			#
			#colision.shape = BoxShape3D.new()
			#colision.shape.size = Vector3(2, 2, 2)
			#
		#"vivienda":
			#mesh_instance.mesh = PrismMesh.new() 
			#mesh_instance.mesh.size = Vector3(2, 2, 2)
			#
			#colision.shape = BoxShape3D.new()
			#colision.shape.size = Vector3(2, 2, 2)
			#
		#"comedor":
			#mesh_instance.mesh = CylinderMesh.new()
			#mesh_instance.mesh.height = 2.0
			#
			#colision.shape = CylinderShape3D.new()
			#colision.shape.height = 2.0
#
	
	if modelo and escenas_edificios.has(tipo_id):
		for hijo in modelo.get_children():
			hijo.queue_free()
			
		var escena = escenas_edificios[tipo_id]
		base_instanciada = escena.instantiate()
		modelo.add_child(base_instanciada)
	else:
		base_instanciada = self #Por si se ejecuta la escena suelta en debug

	if base_instanciada:
		#Se buscan ambos modelos
		modelo_rojo = base_instanciada.get_node_or_null("Modelo_Rojo")
		modelo_terminado = base_instanciada.get_node_or_null("Modelo_Terminado")
		
		var nodo_referencia = modelo_rojo if modelo_rojo else modelo_terminado
		
		if nodo_referencia:
			posicion_original_y = nodo_referencia.position.y
			
			if modelo_rojo:
				modelo_rojo.position.y = profundidad_inicial
				modelo_rojo.show()
			if modelo_terminado:
				modelo_terminado.position.y = profundidad_inicial
				modelo_terminado.hide()

	#if escenas_edificios.has(tipo_id):
		#var escena = escenas_edificios[tipo_id]
		#var edificio_visual = escena.instantiate()
		
		#modelo.add_child(edificio_visual)
	
	#modelo.scale = Vector3(1,0.1,1)
	
	if barra_progreso:
		barra_progreso.targetEdificio = self
		barra_progreso.show()

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = clamp(puntos_actuales / puntos_totales, 0.0, 1.0)
	var nueva_altura = lerp(profundidad_inicial, posicion_original_y, progreso)
	
	#Ambos modelos suben juntos al mismo tiempo
	if modelo_rojo: modelo_rojo.position.y = nueva_altura
	if modelo_terminado: modelo_terminado.position.y = nueva_altura
		
	#mesh_instance.scale = Vector3(1, max(0.1, progreso), 1)
	
	if puntos_actuales >= puntos_totales:
		completado = true
		
		print("\n--- EDIFICIO TERMINADO ---")
		
		#Se acuerda la altura, se apaga el holograma rojo y se muestra la construcción terminada
		if modelo_rojo:
			modelo_rojo.position.y = posicion_original_y
			modelo_rojo.hide()
			print("Éxito: Holograma rojo apagado.")
		else:
			print("Error: No se encontró el Modelo_Rojo para apagarlo.")
			
		if modelo_terminado:
			modelo_terminado.position.y = posicion_original_y
			modelo_terminado.show()
			print("Éxito: Modelo_Terminado encendido y mostrado.")
		else:
			print("ERROR CRÍTICO: La variable 'modelo_terminado' está vacía (null). Revisa si escribiste exactamente igual el nombre del nodo o si olvidaste guardar la escena.")
		#mesh_instance.scale = Vector3(1, 1, 1)
		
		if barra_progreso:
			barra_progreso.hide()
