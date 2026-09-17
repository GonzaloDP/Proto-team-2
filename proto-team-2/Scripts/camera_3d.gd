extends Camera3D

@onready var selection_box = $"../../../../UI/SelectionBox"


#@export var unidad: CharacterBody3D

var selected_units: Array[CharacterBody3D] = []
var seleccionando: bool = false
var posicion_inicio_seleccion: Vector2
var posicion_actual_mouse: Vector2


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			seleccionando = true
			posicion_inicio_seleccion = event.position
			posicion_actual_mouse = event.position
			
			selection_box.actualizar_rectangulo(posicion_inicio_seleccion, posicion_actual_mouse)
		else:
			if posicion_inicio_seleccion == posicion_actual_mouse:
				seleccionar_unidad(posicion_actual_mouse)
			else:
				seleccionar_unidades_en_rectangulo()
			
			seleccionando = false
			selection_box.ocultar_rectangulo()
		
	if event is InputEventMouseMotion and seleccionando:
		posicion_actual_mouse = event.position
		selection_box.actualizar_rectangulo(posicion_inicio_seleccion, posicion_actual_mouse)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		raycast_to_ground(event.position)

func raycast_to_ground(mouse_pos: Vector2) -> void:
	var space_state = get_world_3d().direct_space_state
	var ray_origin = project_ray_origin(mouse_pos) 
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * 1000.0
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	
	if result:
		
		if (result.collider is Recurso):	#Si hacemos clic derecho sobre un recurso, envía a las unidades la señal de ir a recolectarlo. El resto de la lógica la realiza la unidad misma.
			for unidad in selected_units:
				if is_instance_valid(unidad):
					unidad.seekResource(result.collider)
		
		else:
			var click_world_position: Vector3 = result.position
			for unidad in selected_units:
				if is_instance_valid(unidad):
					unidad.target_resource = null	#Al dar una orden de movimiento, se anulan los objetivos anteriores de la unidad. Esto podría transformarse en un método luego, el cual anule TODOS los objetivos (Como construir, recolectar o reproducirse)
					unidad.set_move_target(click_world_position)

func seleccionar_unidad(mouse_pos: Vector2) -> void:
	deseleccionar_todas()
	
	var space_state = get_world_3d().direct_space_state
	var ray_origin = project_ray_origin(mouse_pos) 
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * 1000.0
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var objeto = result.collider
		
		if objeto is CharacterBody3D:
			selected_units.append(objeto)
			mostrar_indicador(objeto)

func seleccionar_unidades_en_rectangulo() -> void:
	deseleccionar_todas()
	var rectangulo = Rect2(posicion_inicio_seleccion, posicion_actual_mouse - posicion_inicio_seleccion).abs()
	var unidades = get_tree().get_nodes_in_group("unidades")
	
	for unidad in unidades:
		var posicion_pantalla = unproject_position(unidad.global_position)
		
		if rectangulo.has_point(posicion_pantalla):
			selected_units.append(unidad)
			mostrar_indicador(unidad)

func mostrar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = true
func ocultar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = false

func deseleccionar_todas() -> void:
	for unidad in selected_units:
		ocultar_indicador(unidad)
	
	selected_units.clear()
