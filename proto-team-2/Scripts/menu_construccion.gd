extends Control
class_name MenuConstruccion

signal iniciar_construccion(nombre_edificio, datos_edificio)

@onready var boton_martillo: Button = $BotonMartillo
@onready var panel_edificios: PanelContainer = $PanelEdificios
@onready var grid_edificios: GridContainer = $PanelEdificios/GridContainer
@onready var boton_cerrar: Button = $BotonCerrar
@onready var tooltip_ui: PanelContainer = $TooltipUI
@onready var label_tooltip: Label = $TooltipUI/MarginContainer/LabelTooltip
@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

# Acá para quién quiera se puede modificar los costes de los edificios
var lista_edificios = {
	"Edificio de Reproducción": {
		"costo": {Recurso.Tipo_Recurso.COMIDA: 50, Recurso.Tipo_Recurso.MADERA: 20},
		"icono": "res://icon.svg" # Placeholder*
	},
	"Edificio de Vivienda": {
		"costo": {Recurso.Tipo_Recurso.MADERA: 50},
		"icono": "res://icon.svg" # Placeholder*
	},
	"Edificio Comedor": {
		"costo": {Recurso.Tipo_Recurso.MADERA: 30, Recurso.Tipo_Recurso.PIEDRA: 20},
		"icono": "res://icon.svg" # Placeholder*
	}
}

func _ready() -> void:
	panel_edificios.hide()
	boton_martillo.hide()
	tooltip_ui.hide()
	boton_cerrar.hide()
	tooltip_ui.top_level = true
	boton_martillo.pressed.connect(_on_boton_martillo_pressed)
	boton_cerrar.pressed.connect(_on_boton_cerrar_pressed)
	crear_botones_edificios()
	inventario.inventario_actualizado.connect(_actualizar_botones_disponibles)

func crear_botones_edificios():
	for nombre_edificio in lista_edificios.keys():
		var btn = Button.new()
		btn.text = nombre_edificio
		btn.custom_minimum_size = Vector2(150, 120) 
		var ruta_icono = lista_edificios[nombre_edificio].get("icono", "")
		if ruta_icono != "":
			btn.icon = load(ruta_icono)
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP 
		btn.mouse_entered.connect(_on_edificio_mouse_entered.bind(nombre_edificio, btn))
		btn.mouse_exited.connect(_on_edificio_mouse_exited)
		btn.pressed.connect(_on_edificio_seleccionado.bind(nombre_edificio))
		grid_edificios.add_child(btn)

func _actualizar_botones_disponibles():
	if not panel_edificios.visible: return
	for i in grid_edificios.get_child_count():
		var btn = grid_edificios.get_child(i)
		var nombre = btn.text
		btn.disabled = false
		if _puede_costear(lista_edificios[nombre].costo):
			btn.modulate = Color(1, 1, 1, 1)
		else:
			btn.modulate = Color(0.5, 0.2, 0.2, 1)

func _puede_costear(costo_edificio: Dictionary) -> bool:
	for tipo in costo_edificio.keys():
		if inventario.get_recurso(tipo) < costo_edificio[tipo]:
			return false
	return true

func _on_boton_martillo_pressed():
	panel_edificios.show()
	boton_cerrar.show()
	_actualizar_botones_disponibles()

func _on_boton_cerrar_pressed():
	panel_edificios.hide()
	boton_cerrar.hide()
	tooltip_ui.hide()

func _on_edificio_mouse_entered(nombre_edificio: String, btn: Button):
	var datos = lista_edificios[nombre_edificio]
	var texto = nombre_edificio + "\nCosto:\n" 
	
	for tipo in datos.costo.keys():
		var nombre_recurso = _obtener_nombre_recurso(tipo)
		texto += "- " + nombre_recurso + ": " + str(datos.costo[tipo]) + "\n"
		
	label_tooltip.text = texto
	tooltip_ui.global_position = btn.global_position + Vector2(10, btn.size.y + 10)
	tooltip_ui.show()

func _on_edificio_mouse_exited():
	tooltip_ui.hide()

func _on_edificio_seleccionado(nombre_edificio: String):
	if not _puede_costear(lista_edificios[nombre_edificio].costo):
		return 
		
	panel_edificios.hide()
	boton_cerrar.hide()
	tooltip_ui.hide()
	iniciar_construccion.emit(nombre_edificio, lista_edificios[nombre_edificio])

func _obtener_nombre_recurso(tipo: Recurso.Tipo_Recurso) -> String:
	match tipo:
		Recurso.Tipo_Recurso.MADERA: return "Madera"
		Recurso.Tipo_Recurso.PIEDRA: return "Piedra"
		Recurso.Tipo_Recurso.COMIDA: return "Comida"
		Recurso.Tipo_Recurso.METAL: return "Metal"
	return "Desconocido"

var unidades_seguidas: Array = []

func toggle_hud_construccion(activar: bool, unidades: Array = []):
	if activar:
		unidades_seguidas = unidades
		boton_martillo.show()
	else:
		unidades_seguidas.clear()
		boton_martillo.hide()
		panel_edificios.hide()
		boton_cerrar.hide() # NUEVO
		tooltip_ui.hide()

func _process(delta: float) -> void:
	if boton_martillo.visible and unidades_seguidas.size() > 0:
		var centro_3d = Vector3.ZERO
		var cantidad_validas = 0
		for unidad in unidades_seguidas:
			if is_instance_valid(unidad):
				centro_3d += unidad.global_position
				cantidad_validas += 1
		
		if cantidad_validas > 0:
			centro_3d = centro_3d / cantidad_validas
			centro_3d.y += 2.6 
			var camara = get_viewport().get_camera_3d()
			if camara and not camara.is_position_behind(centro_3d):
				var posicion_pantalla = camara.unproject_position(centro_3d)
				boton_martillo.position = posicion_pantalla - (boton_martillo.size / 2)
