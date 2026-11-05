extends Node3D

@onready var titulo: Label = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Titulo"
@onready var descripcion: RichTextLabel = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Descripcion"
@onready var boton_continuar: Button = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Continuar"
@onready var camara = $"../CameraPosition/CameraRotationX/CameraZoomPivot/Camera3D2"
@onready var control_camara = $"../CameraPosition"

# Estapas del tutorial
enum TutorialStep {
	INTRODUCCION,
	OBJETIVO,
	SELECCION_UNIDADES,
	MANEJO_UNIDADES,
	CAMARA,
	RECOLECCION,
	INVENTARIO,
	CONSTRUCCION,
	ESTADISTICAS,
	PAGO_CUOTA,
	CONSECUENCIAS,
	FINALIZADO
}

var etapa_actual: TutorialStep = TutorialStep.INTRODUCCION # Etapa actual
var unidades_conectadas: Array[Unidad] = []

func _ready() -> void:
	boton_continuar.pressed.connect(siguiente_etapa)
	iniciar_tutorial()
	camara.seleccion_actualizada.connect(_on_seleccion_actualizada)
	camara.orden_movimiento_emitida.connect(_on_orden_movimiento_emitida)
	control_camara.camara_desplazada.connect(_on_camara_desplazada)

# Inicia el tutorial
func iniciar_tutorial():
	etapa_actual = TutorialStep.INTRODUCCION
	mostrar_etapa()

# Muestra la etapa correspondiente
func mostrar_etapa():
	if etapa_actual != TutorialStep.RECOLECCION:
		desconectar_unidades()
	
	match etapa_actual:
		TutorialStep.INTRODUCCION:
			titulo.text = "Bienvenido a la VOLUNTAD DE DIOS"
			descripcion.text = "A partir de ahora estarás a cargo de este asentamiento. Tu tarea será administrar tus unidades, conseguir recursos y mantener todo funcionando."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.OBJETIVO:
			titulo.text = "Tu Objetivo"
			descripcion.text = "Tu principal objetivo es conseguir los recursos necesarios para pagar la cuota. Tendrás un plazo determinado para cumplir con esta obligación."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.SELECCION_UNIDADES:
			titulo.text = "Señeccionar unidades"
			descripcion.text = "Aprende a seleccionar tus unidades para poder darles órdenes."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = true
		
		TutorialStep.MANEJO_UNIDADES:
			titulo.text = "Mover unidades"
			descripcion.text = "Ahora que seleccionaste una unidad, podés ordenarle que se mueva. Hacé clic derecho sobre el terreno para indicuale adónde ir."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = true
		
		TutorialStep.CAMARA:
			titulo.text = "Control de la cámara"
			descripcion.text = "Podés desplazarte por el escenario utilizando las teclas WASD o acercando el cursor a los bordes de la pantalla. Probá ambos métodos para familiarizarte con el control de la cámara."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = true
		
		TutorialStep.RECOLECCION:
			titulo.text = "Recolectar recursos"
			descripcion.text = "Los recusos son fundamentales para el desarrollo de tu aldea. Seleccioná una o varias unidades y hacé clic derecho sobre un recurso para ordenarles que lo recolecten."
			boton_continuar.text = "continuar"
			boton_continuar.disabled = true
			conectar_unidades_seleccionadas()
		
		TutorialStep.INVENTARIO:
			titulo.text = "Tu inventario"
			descripcion.text = "En la esquina superior izquierda de la pantalla podés consultar los recursos de tu inventario: madera, piedra, metal y comida. También podés observar tu población actual y el límite de habitantes. Todos los recursos recolectados se almacenan automáticamente."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		#TutorialStep.ESTADISTICAS:
			#print("Estadisticas de unidades")
		#
		#TutorialStep.PAGO_CUOTA:
			#print("Asi se paga")
		#
		#TutorialStep.CONSECUENCIAS:
			#print("Esto pasa si no pagas")
		
		TutorialStep.FINALIZADO:
			finalizar_tutorial()

func siguiente_etapa():
	if etapa_actual < TutorialStep.FINALIZADO:
		etapa_actual += 1
		mostrar_etapa()

func finalizar_tutorial():
	print("Tutorial completado")

func _on_seleccion_actualizada(cantidad: int):
	if etapa_actual == TutorialStep.SELECCION_UNIDADES:
		if cantidad > 0:
			boton_continuar.disabled = false
	
	if etapa_actual == TutorialStep.RECOLECCION:
		conectar_unidades_seleccionadas()

func _on_orden_movimiento_emitida():
	if etapa_actual == TutorialStep.MANEJO_UNIDADES:
		boton_continuar.disabled = false

func _on_camara_desplazada():
	if etapa_actual == TutorialStep.CAMARA:
		boton_continuar.disabled = false

func conectar_unidades_seleccionadas():
	desconectar_unidades()
	
	for unidad in camara.selected_units:
		if is_instance_valid(unidad):
			if not unidad.recurso_recolectado.is_connected(_on_recurso_recolectado):
				unidad.recurso_recolectado.connect(_on_recurso_recolectado)
			
			unidades_conectadas.append(unidad)

func desconectar_unidades():
	for unidad in unidades_conectadas:
		if is_instance_valid(unidad):
			if unidad.recurso_recolectado.is_connected(_on_recurso_recolectado):
				unidad.recurso_recolectado.disconnect(_on_recurso_recolectado)
	
	unidades_conectadas.clear()

func _on_recurso_recolectado():
	if etapa_actual == TutorialStep.RECOLECCION:
		boton_continuar.disabled = false
		desconectar_unidades()
