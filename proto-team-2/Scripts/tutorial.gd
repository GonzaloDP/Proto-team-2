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
	REPRODUCCION_1,
	REPRODUCCION_2,
	PAGO_CUOTA,
	CONSECUENCIAS,
	FINALIZADO
}

var etapa_actual: TutorialStep = TutorialStep.INTRODUCCION # Etapa actual
var unidades_conectadas: Array[Unidad] = []
var edificio_reproduccion_actua: EdificioReproduccion = null
var reproduccion_completada: bool = false

func _ready() -> void:
	boton_continuar.pressed.connect(siguiente_etapa)
	iniciar_tutorial()
	camara.seleccion_actualizada.connect(_on_seleccion_actualizada)
	camara.orden_movimiento_emitida.connect(_on_orden_movimiento_emitida)
	control_camara.camara_desplazada.connect(_on_camara_desplazada)
	camara.comedor_colocado.connect(_on_comedor_colocado)

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
		
		TutorialStep.CONSTRUCCION:
			titulo.text = "Construccion"
			descripcion.text = "Podés hacer clic en el martillo que tienen sobre la cabeza de las unidades para desplegar el menú de construcción. Allí encontrarán los distintos edificios que pueden crear y que serán necesarios para sobrevivir. Construye un COMEDOR para que sus unidades puedan alimentarse."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = true
		
		TutorialStep.ESTADISTICAS:
			titulo.text = "Estadísticas de las unidades"
			descripcion.text = "Cada unidad tiene sus propias estadísticas, que determinan su rengimiento y sus capacidades.
*Velocidad de recolección: Determina qué tan rápido consigue recursos.
*Velocidad de reproducción: Determina qué tan rápido puede reproducirse.
*Velocidad de movimiento: Determina qué tan rápido se desplaza por el mapa.
*Velocidad de construcción: Determina qué tan rápido construye edificios.
*Saciedad: Reprensenta qué tan alimentada está la unidad."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.REPRODUCCION_1:
			titulo.text = "Edificio de reproducción"
			descripcion.text = "El edificio de reproducción permite generar nuevas unidades y mejorar las características de nuestra población. Para utilizarlo, primero deben construir un edificio de REPRODUCCIÓN."
			boton_continuar.text = "Continuar"
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
	
	if etapa_actual == TutorialStep.ESTADISTICAS:
		if cantidad > 0:
			boton_continuar.disabled = false

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

func _on_comedor_colocado(edificio: Edificio):
	if etapa_actual != TutorialStep.CONSTRUCCION:
		return
	
	print("Tutorial: comedor colocado, espeando construcción")
	
	while is_instance_valid(edificio) and not edificio.completado:
		await get_tree().create_timer(0.2).timeout
	
	if not is_instance_valid(edificio):
		return
	
	if etapa_actual == TutorialStep.CONSTRUCCION:
		print("Tutorial: comedor terminado")
		boton_continuar.disabled = false
