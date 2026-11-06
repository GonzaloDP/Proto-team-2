extends Node3D

@onready var titulo: Label = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Titulo"
@onready var descripcion: RichTextLabel = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Descripcion"
@onready var boton_continuar: Button = $"../UITuto/TutorialPanel/PanelContainer/Contenido/Continuar"
@onready var camara = $"../CameraPosition/CameraRotationX/CameraZoomPivot/Camera3D2"
@onready var control_camara = $"../CameraPosition"
@onready var boton_skip: Button = $"../UITuto/SkipTuto"

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
	TUTO_COMPLETADO,
	FINALIZADO
}

var etapa_actual: TutorialStep = TutorialStep.INTRODUCCION # Etapa actual
var unidades_conectadas: Array[Unidad] = []
var edificio_reproduccion_actual: EdificioReproduccion = null
var reproduccion_completada: bool = false

func _ready() -> void:
	boton_continuar.pressed.connect(siguiente_etapa)
	iniciar_tutorial()
	camara.seleccion_actualizada.connect(_on_seleccion_actualizada)
	camara.orden_movimiento_emitida.connect(_on_orden_movimiento_emitida)
	control_camara.camara_desplazada.connect(_on_camara_desplazada)
	camara.comedor_colocado.connect(_on_comedor_colocado)
	camara.reproduccion_colocada.connect(_on_reproduccion_colocada)
	boton_skip.pressed.connect(finalizar_tutorial)

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
			descripcion.text = "A partir de ahora estarás a cargo de estas unidades. Tu tarea será administrarlas, conseguir recursos y mantener todo funcionando. 
Si ya sabes jugar, en la esquina inferior derecha podrás skipear el tutorial."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.OBJETIVO:
			titulo.text = "Tu Objetivo"
			descripcion.text = "Tu principal objetivo es conseguir los recursos necesarios para pagar la cuota. Tendrás un plazo determinado para cumplir con esta obligación."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.SELECCION_UNIDADES:
			titulo.text = "Señeccionar unidades"
			descripcion.text = "Aprende a seleccionar tus unidades para poder darles órdenes. Haz clic primario a una unidad para seleccionarla o manten apretado el clic y arrastra el ratón para desplegar una ventana azul donde podrás seleccione a varias unidades."
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
			boton_continuar.disabled = true
		
		TutorialStep.REPRODUCCION_2:
			titulo.text = "Reproducción"
			descripcion.text = "¡Ahora podemos reproducir nuestras unidades! Seleccionen dos unidades y envíenlas juntas al edificio de reproducción. Cuando el proceso termine, aparecerá una nueva unidad con características mejoradas."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = true
		
		TutorialStep.PAGO_CUOTA:
			titulo.text = "Cuota"
			descripcion.text = "Para mantener a nuestra aldea funcionando, debemos pagar cuotas periódicamente. En el HUD de la derecha pueden consultar qué cantidad de cada recusso nos exige la próxima cupta y cuántas días quedan para pagarla. La barra de progreso indica cuánto avanzó el día, tanto visualmente como mediante un porcentaje. Cuando llegue la fecha de vencimiento, la cuota se cobrará automáticamente si contamos con todos los recursos necesarios."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.CONSECUENCIAS:
			titulo.text = "Consecuencias del incumplimiento"
			descripcion.text = "¡Cuidado con las cuotas! Si no contamos con los recursos necesarios al llegar el vencimiento, comenzaremos a recibir penalizaciones. Cuantos más días pasen sin pagar, más graves serán las consecuencias:
* La recolección de recursos será más lenta.
* La construcción de edificios llevará más tiempo.
* La reproducción de unidades será menos eficiente.
* Si no pagas la cuota por 3 días, sin la necesidad de ser consecutivos, pierdes.
¡Administren bien los recursos y prioricen el pago de las cuotas, sino DIOS se enojará!"
			boton_continuar.text = "Avanzar al Nivel"
			boton_continuar.disabled = false
		
		TutorialStep.TUTO_COMPLETADO:
			titulo.text = "¡Felicidades completaste el tutorial!"
			descripcion.text = "Ahora ya sabes cómo jugar a la Voluntad de Dios. Para avanzar aprieta el botón Continuar que está debajo y comenzarás con el nivel que tenemos preparado para vos."
			boton_continuar.text = "Continuar"
			boton_continuar.disabled = false
		
		TutorialStep.FINALIZADO:
			finalizar_tutorial()

func siguiente_etapa():
	if etapa_actual < TutorialStep.FINALIZADO:
		etapa_actual += 1
		mostrar_etapa()

func finalizar_tutorial():
	print("Tutorial completado")
	get_tree().change_scene_to_file("res://Escenas/Level.tscn")

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

func _on_reproduccion_colocada(edificio: EdificioReproduccion):
	if etapa_actual != TutorialStep.REPRODUCCION_1:
		return
	
	edificio_reproduccion_actual = edificio
	
	while is_instance_valid(edificio) and not edificio.completado:
		await get_tree().create_timer(0.2).timeout
	
	if not is_instance_valid(edificio):
		return
	
	if etapa_actual == TutorialStep.REPRODUCCION_1:
		boton_continuar.disabled = false
		conectar_eventos_reproduccion()

func conectar_eventos_reproduccion():
	if not is_instance_valid(edificio_reproduccion_actual):
		return
	
	edificio_reproduccion_actual.reproduccion_iniciada.connect(_on_reproduccion_iniciada)
	edificio_reproduccion_actual.nueva_unidad_creada.connect(_on_nueva_unidad_creada)

func _on_reproduccion_iniciada():
	if etapa_actual != TutorialStep.REPRODUCCION_2:
		return
	print("tuto las unidades se reproducen")

func _on_nueva_unidad_creada(unidad: Unidad):
	if etapa_actual != TutorialStep.REPRODUCCION_2:
		return
	
	reproduccion_completada = true
	boton_continuar.disabled = false
