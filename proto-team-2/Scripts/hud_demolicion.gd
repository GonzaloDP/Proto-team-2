extends CanvasLayer
class_name  HudDemolicion

@onready var panel: PanelContainer = $PanelDemolicion
@onready var titulo: Label = $PanelDemolicion/Label
@onready var boton_demoler: Button = $PanelDemolicion/Button
@onready var confirmacion: ConfirmationDialog = $ConfirmationDialog

var edificio_seleccionado: Edificio = null

func _ready() -> void:
	hide()
	
	boton_demoler.text = "Demoler Edificio"
	
	boton_demoler.pressed.connect(_al_pulsar_demoler)
	confirmacion.confirmed.connect(_confirmar_demolicion)

func mostrar_edificio(edificio: Edificio):
	if not is_instance_valid(edificio):
		return
	
	edificio_seleccionado = edificio
	
	if edificio.completado:
		titulo.text = edificio.nombre_edificio
		boton_demoler.text = "Demoler Edificio"
	else:
		titulo.text = edificio.nombre_edificio + " (En construcción)"
		boton_demoler.text = "Cancelar construcción"
	show()

func ocultar_hud():
	edificio_seleccionado = null
	hide()
	confirmacion.hide()

func _al_pulsar_demoler():
	if not is_instance_valid(edificio_seleccionado):
		ocultar_hud()
		return
	
	confirmacion.dialog_text = (
		"Estás seguro que querés demoler" + 
		edificio_seleccionado.nombre_edificio + 
		"?")
	
	confirmacion.ok_button_text = "Sí"
	confirmacion.cancel_button_text = "No"
	confirmacion.popup_centered()

func _confirmar_demolicion():
	if not is_instance_valid(edificio_seleccionado):
		ocultar_hud()
		return
	
	var edificio := edificio_seleccionado
	
	ocultar_hud()
	edificio.eliminar_edificio()
