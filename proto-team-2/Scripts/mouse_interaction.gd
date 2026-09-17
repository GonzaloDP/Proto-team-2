extends Node

@onready var camera: Camera3D = $"../CameraPosition/CameraRotationX/CameraZoomPivot/Camera3D2"
@onready var tooltip = $"../UI/Tooltip"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#obtenemos posición del mouse en la pantalla
	var mouse_position = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_position)#creamos un origen a un raycast desde la posición del mouse
	var ray_direction = camera.project_ray_normal(mouse_position)#le damos una dirección a la que tiene que dirigirse el raycast
	
	var space_state = camera.get_world_3d().direct_space_state#esta linea es para detectar el espacio físico
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)#con este solamente le decimos al raycast que viaje mil unidades
	
	var result = space_state.intersect_ray(query)#acá nos dice con que chocó
	
	if result and result.collider is Recurso:
		var recurso: Recurso = result.collider
		
		tooltip.mostrar(recurso.get_names(), recurso.cantidad_variable)
		tooltip.position = mouse_position + Vector2(15,15)
	else:
		tooltip.ocultar()
