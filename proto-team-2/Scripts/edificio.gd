extends StaticBody3D
class_name Edificio

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var colision: CollisionShape3D = $CollisionShape3D

@onready var barra_progreso = get_node_or_null("BarraProgreso")

@export var nombre_edificio: String = "Edificio"
@export var tipo_edificio: String = "General"

var puntos_totales: float = 100.0
var puntos_actuales: float = 0.0
var completado: bool = false
var tipo_actual: String = ""

var costo_original: Dictionary = {}
var inventario_referencia: Inventario = null

func configurar_edificio(tipo_id: String, puntos_requeridos: float, costo: Dictionary = {}, inventario_ref: Inventario = null):
	tipo_actual = tipo_id
	puntos_totales = puntos_requeridos
	puntos_actuales = 0.0
	completado = false
	
	costo_original = costo.duplicate(true)
	inventario_referencia = inventario_ref
	
	mesh_instance.scale = Vector3(1, 0.1, 1)
	
	if barra_progreso:
		barra_progreso.targetEdificio = self
		barra_progreso.show()

func recibir_trabajo(cantidad: float):
	if completado: return
	
	puntos_actuales += cantidad
	var progreso = puntos_actuales / puntos_totales
	
	mesh_instance.scale = Vector3(1, max(0.1,progreso), 1)
	
	if puntos_actuales >= puntos_totales:
		completado = true
		mesh_instance.scale = Vector3(1, 1, 1)
		
		if barra_progreso:
			barra_progreso.hide()

func eliminar_edificio():
	if not completado:
		return
	
	if is_instance_valid(inventario_referencia):
		for tipo in costo_original.keys():
			var cantidad: int = int(floor(float(costo_original[tipo]) * 0.5))
			
			if cantidad > 0:
				inventario_referencia.agregar_recurso(tipo,cantidad)
	queue_free()
