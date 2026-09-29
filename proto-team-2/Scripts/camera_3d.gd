extends Camera3D

@onready var selection_box = $"../../../../UI/SelectionBox"
@onready var menu_construccion = $"../../../../UIConstruccion/MenuConstruccion"
@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

var selected_units: Array[CharacterBody3D] = []
var seleccionando: bool = false
var posicion_inicio_seleccion: Vector2
var posicion_actual_mouse: Vector2

# Agregado supernice para constuccion (estados de unidad)
enum EstadoCamara { NORMAL, CONSTRUYENDO }
var estado_actual = EstadoCamara.NORMAL
var edificio_fantasma: MeshInstance3D = null # El edificio fantasma es esa estructura temporal que se mostrará, o no, hasta que se termine la construcción
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
		var result = space_state.intersect_ray(query)
		
		if result:
			edificio_fantasma.global_position = result.position

func _unhandled_input(event: InputEvent) -> void:
	if estado_actual == EstadoCamara.CONSTRUYENDO:
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
	var result = space_state.intersect_ray(query)
	
	if result:
		if (result.collider is Recurso):
			for unidad in selected_units:
				if is_instance_valid(unidad) and (!unidad._isStarving()):
					unidad.seekResource(result.collider)
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


# A partir de acá empieza el codigo para la UI de construcción
func _activar_modo_construccion(nombre: String, datos: Dictionary):
	estado_actual = EstadoCamara.CONSTRUYENDO
	nombre_edificio_pendiente = nombre
	datos_edificio_pendiente = datos
	
	edificio_fantasma = MeshInstance3D.new()
	var malla = BoxMesh.new()
	malla.size = Vector3(2, 2, 2)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1, 0, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	malla.material = material
	edificio_fantasma.mesh = malla
	
	get_tree().current_scene.add_child(edificio_fantasma)

func _cancelar_construccion():
	estado_actual = EstadoCamara.NORMAL
	if is_instance_valid(edificio_fantasma):
		edificio_fantasma.queue_free()

func _confirmar_construccion():
	var costos = datos_edificio_pendiente["costos"]
	for tipo_recurso in costos.keys():
		inventario.agregar_recurso(tipo_recurso, -costos[tipo_recurso])
	
	var posicion_final = edificio_fantasma.global_position
	
	_cancelar_construccion()
	
	print("Edificio confirmado en: ", posicion_final)
