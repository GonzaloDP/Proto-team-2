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
var edificio_fantasma: Node3D = null
var materiales_fantasma: Array[MeshInstance3D] = []
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
					
					#var mat = edificio_fantasma.material_override as StandardMaterial3D
					if ubicacion_valida:
						for mesh in materiales_fantasma:
							mesh.material_override.albedo_color = Color(0,1,0,0.5)
						#mat.albedo_color = Color(0, 1, 0, 0.5)
					else:
						for mesh in materiales_fantasma:
							mesh.material_override.albedo_color = Color(1,0,0,0.5)
						#mat.albedo_color = Color(1, 0, 0, 0.5)

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
	
	query.collision_mask = 1 | 2 | 4
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
	
	#for nodo in escena_visual.find_children("*", "MeshInstance3D", true, false):
		#nodo.material_override = material
		#nodo.disabled = true
		#materiales_fantasma.append(nodo)
	
	#edificio_fantasma = MeshInstance3D.new()
	#var malla = BoxMesh.new()
	#malla.size = Vector3(2, 2, 2)
	#edificio_fantasma.mesh = malla
	#
	#var material = StandardMaterial3D.new()
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#edificio_fantasma.material_override = material
	#
	#area_fantasma = Area3D.new() 
	#area_fantasma.collision_layer = 0 
	#area_fantasma.collision_mask = 2 | 4
	#
	#var colision = CollisionShape3D.new()
	#var forma = BoxShape3D.new()
	#forma.size = Vector3(1.8, 1.8, 1.8) 
	#colision.shape = forma
	#
	
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
	
	#var escena_base = load("res://Escenas/Edificio.tscn")
	#var nuevo_edificio = escena_base.instantiate()
	
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
	
	nuevo_edificio.position = edificio_fantasma.global_position
	nuevo_edificio.rotation = edificio_fantasma.global_rotation
	
	get_tree().current_scene.add_child(nuevo_edificio)
	
	nuevo_edificio.configurar_edificio(id_del_edificio, puntos_req)
		
	for unidad in selected_units:
		if is_instance_valid(unidad) and unidad.has_method("asignar_edificio"):
			unidad.asignar_edificio(nuevo_edificio)
	
	_cancelar_construccion()
