extends StaticBody3D
class_name Edificio

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var colision: CollisionShape3D = $CollisionShape3D

@onready var barra_progreso = get_node_or_null("BarraProgreso")

var puntos_totales: float = 100.0
var puntos_actuales: float = 0.0
var completado: bool = false
var tipo_actual: String = ""

func configurar_edificio(tipo_id: String, puntos_requeridos: float):
	tipo_actual = tipo_id
	puntos_totales = puntos_requeridos
	puntos_actuales = 0.0
	completado = false
	
	# Acá se cambian los assets de los edificios, como prueba se estableció un mesh instance (quitarlo*)
	match tipo_id:
		"reproduccion":
		# Usar mesh_instance.mesh = load("res://modelo_super_jelou")
			mesh_instance.mesh = BoxMesh.new() # <-- Quitar esta mierda una vez con los modelos
			mesh_instance.mesh.size = Vector3(2, 2, 2)
			
			colision.shape = BoxShape3D.new()
			colision.shape.size = Vector3(2, 2, 2)
			
		"vivienda":
			mesh_instance.mesh = PrismMesh.new() 
			mesh_instance.mesh.size = Vector3(2, 2, 2)
			
			colision.shape = BoxShape3D.new()
			colision.shape.size = Vector3(2, 2, 2)
			
		"comedor":
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = 2.0
			
			colision.shape = CylinderShape3D.new()
			colision.shape.height = 2.0

	mesh_instance.scale = Vector3(1, 0.1, 1)
	
	if barra_progreso:
		barra_progreso.targetEdificio = self
		barra_progreso.show()

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = puntos_actuales / puntos_totales
	
	mesh_instance.scale = Vector3(1, max(0.1, progreso), 1)
	
	if puntos_actuales >= puntos_totales:
		completado = true
		mesh_instance.scale = Vector3(1, 1, 1)
		
		if barra_progreso:
			barra_progreso.hide()
