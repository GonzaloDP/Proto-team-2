extends Camera3D

@onready var selection_box = $"../../../../UI/SelectionBox"
@onready var menu_construccion = $"../../../../UIConstruccion/MenuConstruccion"
@onready var hud_demolicion: HudDemolicion = $"../../../../HUDDemolicion"
@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")
@onready var navigation_region: NavigationRegion3D = get_tree().current_scene.get_node("NavigationRegion3D")
@onready var hud_unidad: HUD_Unidad = get_tree().current_scene.get_node_or_null("HUD_Unidad")

var area_fantasma: Area3D = null
var ubicacion_valida: bool = false

var selected_units: Array[CharacterBody3D] = []
var seleccionando: bool = false
var posicion_inicio_seleccion: Vector2
var posicion_actual_mouse: Vector2

enum EstadoCamara { NORMAL, CONSTRUYENDO }
var estado_actual = EstadoCamara.NORMAL
var edificio_fantasma: Node3D = null
var materiales_fantasma: Array[MeshInstance3D] = []
var datos_edificio_pendiente: Dictionary
var nombre_edificio_pendiente: String

var edificio_seleccionado: Edificio = null

func _ready() -> void:
	if menu_construccion:
		menu_construccion.iniciar_construccion.connect(_activar_modo_construccion)
	
	if is_instance_valid(navigation_region):
		if not navigation_region.bake_finished.is_connected(_on_navegacion_horneado):
			navigation_region.bake_finished.connect(_on_navegacion_horneado)

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
					
					if ubicacion_valida:
						for mesh in materiales_fantasma:
							mesh.material_override.albedo_color = Color(0,1,0,0.5)
					else:
						for mesh in materiales_fantasma:
							mesh.material_override.albedo_color = Color(1,0,0,0.5)

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
				var edificio: Edificio = obtener_edificio_bajo_mouse(posicion_actual_mouse)
				if edificio != null:
					edificio_seleccionado = edificio
					hud_demolicion.mostrar_edificio(edificio)
				else:
					_ocultar_hud_demolicion()
					seleccionar_unidad(posicion_actual_mouse)
			else:
				_ocultar_hud_demolicion()
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
	
	query.collision_mask = 1 | 2 | 4
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider is Edificio:
			var edificio: Edificio = collider
			if edificio.completado:
				return
			else:
				_ocultar_hud_demolicion()
				for unidad in selected_units:
					if is_instance_valid(unidad) and not unidad._isStarving():
						if unidad.has_method("asignar_edificio"):
							unidad.asignar_edificio(edificio)
		
		elif collider is Recurso:
			_ocultar_hud_demolicion()
			for unidad in selected_units:
				if is_instance_valid(unidad) and not unidad._isStarving():
					unidad.seekResource(collider)
		
		elif collider is Area3D and collider.get_parent() is EdificioReproduccion:
			_ocultar_hud_demolicion()
			var edificio: EdificioReproduccion = collider.get_parent()
			edificio.recibir_unidades(selected_units)
		
		elif result.collider is Area3D and result.collider.get_parent() is EdificioComedor: #Si el jugador hace clic sobre un edificio comedor, enviamos a las unidades allí a comer.
			if(inventario.get_recurso(Recurso.Tipo_Recurso.COMIDA) == 0): #Primero chequeamos que el jugador tenga comida, de no ser así, la función regresa. Esto evita que un jugador deje a sus unidades inutilizadas frente a un comedor que no tiene comida. Para un futuro, añadir algún tipo de feedback o mensaje.
				return
			var edificio: EdificioComedor = result.collider.get_parent()
			if(edificio.completado == false):	#Si el edificio no está terminado, entonces le pedimos a las unidades que lo construyan.
				for unidad in selected_units:
					if is_instance_valid(unidad) and (!unidad._isStarving()):
						if unidad.has_method("asignar_edificio"):
							unidad.asignar_edificio(edificio)
				return
			for unidad in selected_units:
				if is_instance_valid(unidad):
						unidad.starving = true
						unidad.hideProgressBar()
						unidad.target_edificio = null
						unidad.target_resource = null
						unidad.set_move_target(edificio.global_position)


		else:
			_ocultar_hud_demolicion()
			var click_world_position: Vector3 = result.position
			mover_unidades_en_formacion(click_world_position)

func seleccionar_unidad(mouse_pos: Vector2) -> void:
	deseleccionar_todas()
	
	var space_state = get_world_3d().direct_space_state
	var ray_origin = project_ray_origin(mouse_pos) 
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * 1000.0
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var objeto = result.collider
		if objeto is Unidad:
			selected_units.append(objeto)
			mostrar_indicador(objeto)
			objeto._getProgressBar()
			menu_construccion.toggle_hud_construccion(true, selected_units)
	actualizar_hudUnidad()

func seleccionar_unidades_en_rectangulo() -> void:
	deseleccionar_todas()
	var rectangulo = Rect2(posicion_inicio_seleccion, posicion_actual_mouse - posicion_inicio_seleccion).abs()
	var unidades = get_tree().get_nodes_in_group("unidades")
	
	for unidad in unidades:
		if not unidad is Unidad:
			continue
		
		var posicion_pantalla = unproject_position(unidad.global_position)
		if rectangulo.has_point(posicion_pantalla):
			selected_units.append(unidad)
			mostrar_indicador(unidad)
			unidad._getProgressBar()

	if selected_units.size() > 0:
		menu_construccion.toggle_hud_construccion(true, selected_units)
	
	actualizar_hudUnidad()

func deseleccionar_todas() -> void:
	for unidad in selected_units:
		ocultar_indicador(unidad)
	selected_units.clear()
	if menu_construccion:
		menu_construccion.toggle_hud_construccion(false, [])
	
	actualizar_hudUnidad()

func mostrar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = true

func ocultar_indicador(unidad: CharacterBody3D) -> void:
	var indicador = unidad.get_node("SelectionMesh")
	indicador.visible = false
	unidad.progressBar.hide()

func _activar_modo_construccion(nombre: String, datos: Dictionary):
	estado_actual = EstadoCamara.CONSTRUYENDO
	nombre_edificio_pendiente = nombre
	datos_edificio_pendiente = datos
	
	var id_del_edificio = datos["tipo_id"]
	
	var escenas_edificios = {
		"reproduccion": preload("res://Escenas/Edificio_Reproducción.tscn"),
		"vivienda": preload("res://Escenas/Edificio_Vivienda.tscn"),
		"comedor": preload("res://Escenas/Edificio_Comedor.tscn")
	}
	
	if not escenas_edificios.has(id_del_edificio):
		print("No existe una escena del edificio fantasma", id_del_edificio)
		return
	
	edificio_fantasma = Node3D.new()
	
	var escena = escenas_edificios[id_del_edificio]
	var escena_visual = escena.instantiate()
	
	edificio_fantasma.add_child(escena_visual)
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.2, 1.0, 0.3, 0.5)
	
	materiales_fantasma.clear()
	
	var mallas = escena_visual.find_children("*","MeshInstance3D",true,false)
	
	for nodo in mallas:
		var mesh = nodo as MeshInstance3D
		if mesh:
			mesh.material_override = material
			materiales_fantasma.append(mesh)
	
	var colisiones = escena_visual.find_children("*","CollisionShape3D",true,false)
	
	for nodo in colisiones:
		var colision = nodo as CollisionShape3D
		if colision:
			colision.disabled = true
	
	area_fantasma = Area3D.new()
	area_fantasma.collision_layer = 0
	area_fantasma.collision_mask = 2 | 4
	
	var colision = CollisionShape3D.new()
	var forma = BoxShape3D.new()
	forma.size = Vector3(1.8,1.8,1.8)
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
	
	var id_del_edificio = datos_edificio_pendiente["tipo_id"]
	var puntos_req = datos_edificio_pendiente["puntos_construccion_requeridos"]
	
	var escenas_edificios = {
		"reproduccion": preload("res://Escenas/Edificio_Reproducción.tscn"),
		"vivienda": preload("res://Escenas/Edificio_Vivienda.tscn"),
		"comedor": preload("res://Escenas/Edificio_Comedor.tscn")
	}
	
	if not escenas_edificios.has(id_del_edificio):
		print("No existe escena de edificio", id_del_edificio)
		_cancelar_construccion()
		return
	
	var escena = escenas_edificios[id_del_edificio]
	var nuevo_edificio = escena.instantiate()
	
	var posicion_mundo = edificio_fantasma.global_position
	var rotacion_mundo = edificio_fantasma.global_rotation
	
	navigation_region.add_child(nuevo_edificio)
	
	nuevo_edificio.position = posicion_mundo
	nuevo_edificio.rotation = rotacion_mundo
	
	nuevo_edificio.configurar_edificio(id_del_edificio, puntos_req, costo, inventario, navigation_region, self)
	
	await get_tree().physics_frame
	
	actualizar_navegacion()
	
	for unidad in selected_units:
		if is_instance_valid(unidad) and unidad.has_method("asignar_edificio"):
			unidad.asignar_edificio(nuevo_edificio)
	
	_cancelar_construccion()

func mover_unidades_en_formacion(destino: Vector3):
	var unidades_validas: Array[CharacterBody3D] = []
	
	for unidad in selected_units:
		if is_instance_valid(unidad) and not unidad._isStarving():
			unidades_validas.append(unidad)
	
	if unidades_validas.is_empty():
		return
	
	var columnas := int(ceil(sqrt(float(unidades_validas.size()))))
	var filas := int(ceil(float(unidades_validas.size()) / columnas))
	var separacion := 1.5
	
	for i in range(unidades_validas.size()):
		var columna := i % columnas
		var fila := int(i / columnas)
		
		var desplazamiento_x := (columna - (columnas - 1) / 2.0) * separacion
		var desplazamiento_y := (fila - (filas - 1) / 2.0) * separacion
		
		var posicion_objetivo := destino + Vector3(desplazamiento_x,0.0,desplazamiento_y)
		var unidad := unidades_validas[i]
		
		unidad.target_resource = null
		unidad.hideProgressBar()
		unidad.set_move_target(posicion_objetivo)

func actualizar_navegacion():
	if not is_instance_valid(navigation_region):
		push_warning("No se encontró el NavigationRegion3D")
		return
	
	navigation_region.bake_navigation_mesh(true)

func _on_navegacion_horneado():
	print("navegacion actualizada")

func _ocultar_hud_demolicion():
	if is_instance_valid(hud_demolicion):
		hud_demolicion.ocultar_hud()
	edificio_seleccionado = null

func obtener_edificio_bajo_mouse(mouse_pos: Vector2):
	var space_state = get_world_3d().direct_space_state
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	query.collision_mask = 1 | 2 | 4
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Edificio:
		return result.collider as Edificio
	
	return null

func actualizar_navegacion_despues_de_demoler():
	await get_tree().process_frame
	print("EDIFICIO ELIMINADO, ACTUALIZANDO NAVEGACION")
	actualizar_navegacion()

func actualizar_hudUnidad():
	if not is_instance_valid(hud_unidad):
		return
	
	if selected_units.size() == 1 and selected_units[0] is Unidad:
		hud_unidad.mostrar_unidad(selected_units[0])
	else:
		hud_unidad.ocultar_hud()
