extends Camera3D

@onready var selection_box = $"../../../../UI/SelectionBox"
@onready var menu_construccion = $"../../../../UIConstruccion/MenuConstruccion"
@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")


var area_fantasma: Area3D = null
var ubicacion_valida: bool = false

var selected_units: Array[CharacterBody3D] = []
var seleccionando: bool = false
var posicion_inicio_seleccion: Vector2
var posicion_actual_mouse: Vector2


enum EstadoCamara { NORMAL, CONSTRUYENDO }
var estado_actual = EstadoCamara.NORMAL
var edificio_fantasma: MeshInstance3D = null
var datos_edificio_pendiente: Dictionary
var nombre_edificio_pendiente: String

func _ready() -> void:
	if menu_construccion:
		menu_construccion.iniciar_construccion.connect(_activar_modo_construccion)

func _process(delta: float) -> void:
	if estado_actual == EstadoCamara.CONSTRUYENDO and is_instance_valid(edificio_fantasma):
		var mouse_pos = get_viewport().get_mouse_position()
		var space_state = get_world_3d().direct_space_state
		var ray_origin = project_ray_origin(mouse_pos)
		var ray_end = ray_origin + project_ray_normal(mouse_pos) * 1000.0
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		
		query.collision_mask = 1 
		
		var result = space_state.intersect_ray(query)
		
		if result:
					var tamano_grilla = 2.0
					var pos_grid = result.position
					pos_grid.x = snapped(pos_grid.x, tamano_grilla)
					pos_grid.z = snapped(pos_grid.z, tamano_grilla)
					
					pos_grid.y = result.position.y
					
					edificio_fantasma.global_position = pos_grid
					
					if is_instance_valid(area_fantasma):
						ubicacion_valida = area_fantasma.get_overlapping_bodies().is_empty()
					else:
						ubicacion_valida = false
					
					var mat = edificio_fantasma.material_override as StandardMaterial3D
					if ubicacion_valida:
						mat.albedo_color = Color(0, 1, 0, 0.5)
					else:
						mat.albedo_color = Color(1, 0, 0, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if estado_actual == EstadoCamara.CONSTRUYENDO:
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			if is_instance_valid(edificio_fantasma):
				edificio_fantasma.rotate_y(deg_to_rad(90))
				
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_confirmar_construccion()
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				_cancelar_construccion()
		return

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
	
	query.collision_mask = 1 | 2
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		if result.collider is Edificio and not result.collider.completado:
			for unidad in selected_units:
				if is_instance_valid(unidad) and (!unidad._isStarving()):
					if unidad.has_method("asignar_edificio"):
						unidad.asignar_edificio(result.collider)
		elif (result.collider is Recurso):
			for unidad in selected_units:
				if is_instance_valid(unidad) and (!unidad._isStarving()):
					unidad.seekResource(result.collider)
		elif result.collider is Area3D and result.collider.get_parent() is EdificioReproduccion:
			var edificio: EdificioReproduccion = result.collider.get_parent()
			edificio.recibir_unidades(selected_units)
		
		else:
			var click_world_position: Vector3 = result.position
			for unidad in selected_units:
				if is_instance_valid(unidad) and (!unidad._isStarving()):
					unidad.target_resource = null
					unidad.hideProgressBar()
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
			menu_construccion.toggle_hud_construccion(true, selected_units)

func seleccionar_unidades_en_rectangulo() -> void:
	deseleccionar_todas()
	var rectangulo = Rect2(posicion_inicio_seleccion, posicion_actual_mouse - posicion_inicio_seleccion).abs()
	var unidades = get_tree().get_nodes_in_group("unidades")
	
	for unidad in unidades:
		var posicion_pantalla = unproject_position(unidad.global_position)
		if rectangulo.has_point(posicion_pantalla):
			selected_units.append(unidad)
			mostrar_indicador(unidad)
	
	if selected_units.size() > 0:
		menu_construccion.toggle_hud_construccion(true, selected_units)

func deseleccionar_todas() -> void:
	for unidad in selected_units:
		ocultar_indicador(unidad)
	selected_units.clear()
	if menu_construccion:
		menu_construccion.toggle_hud_construccion(false, [])

func mostrar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = true

func ocultar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = false


func _activar_modo_construccion(nombre: String, datos: Dictionary):
	estado_actual = EstadoCamara.CONSTRUYENDO
	nombre_edificio_pendiente = nombre
	datos_edificio_pendiente = datos
	
	edificio_fantasma = MeshInstance3D.new()
	var malla = BoxMesh.new()
	malla.size = Vector3(2, 2, 2)
	edificio_fantasma.mesh = malla
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	edificio_fantasma.material_override = material
	
	area_fantasma = Area3D.new() 
	area_fantasma.collision_layer = 0 
	area_fantasma.collision_mask = 2 
	
	var colision = CollisionShape3D.new()
	var forma = BoxShape3D.new()
	forma.size = Vector3(1.8, 1.8, 1.8) 
	colision.shape = forma
	
	area_fantasma.add_child(colision)
	edificio_fantasma.add_child(area_fantasma)
	
	get_tree().current_scene.add_child(edificio_fantasma)

func _cancelar_construccion():
	estado_actual = EstadoCamara.NORMAL
	if is_instance_valid(edificio_fantasma):
		edificio_fantasma.queue_free()

func _confirmar_construccion():
	if not ubicacion_valida:
		print("Ubicación inválida. Hay obstáculos.")
		return
		
	var costo = datos_edificio_pendiente["costo"]
	
	for tipo in costo.keys():
		if inventario.get_recurso(tipo) < costo[tipo]:
			print("Recursos insuficientes de último momento.")
			_cancelar_construccion()
			return
			
	for tipo in costo.keys():
		inventario.agregar_recurso(tipo, -costo[tipo])
		
	var escena_base = load("res://Escenas/Edificio.tscn")
	var nuevo_edificio = escena_base.instantiate()
	
	nuevo_edificio.position = edificio_fantasma.global_position
	nuevo_edificio.rotation = edificio_fantasma.global_rotation
	
	get_tree().current_scene.add_child(nuevo_edificio)
	
	var id_del_edificio = datos_edificio_pendiente["tipo_id"]
	var puntos_req = datos_edificio_pendiente["puntos_construccion_requeridos"]
	
	nuevo_edificio.configurar_edificio(id_del_edificio, puntos_req)
		
	for unidad in selected_units:
		if is_instance_valid(unidad) and unidad.has_method("asignar_edificio"):
			unidad.asignar_edificio(nuevo_edificio)
	
	_cancelar_construccion()
