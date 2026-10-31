extends Control
class_name HUD_Unidad

@onready var nombre_unidad: Label = $Panel/Margen/Contenido/NombreUnidad
@onready var estado_unidad: Label = $Panel/Margen/Contenido/EstadoUnidad
@onready var lista_rasgo: Label = $Panel/Margen/Contenido/ListaRasgo

@onready var valor_recoleccion: Label = $Panel/Margen/Contenido/Atributos/ValorRecoleccion
@onready var valor_reproduccion: Label = $Panel/Margen/Contenido/Atributos/ValorReproduccion
@onready var valor_movimiento: Label = $Panel/Margen/Contenido/Atributos/ValorMovimiento
@onready var valor_construccion: Label = $Panel/Margen/Contenido/Atributos/ValorConstruccion
@onready var valor_saciedad: Label = $Panel/Margen/Contenido/Atributos/ValorSaciedad

var unidad_actual: Unidad = null

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if not is_instance_valid(unidad_actual):
		ocultar_hud()
		return
	
	estado_unidad.text = obtener_estado(unidad_actual)
	valor_saciedad.text = "%d / %d" % [unidad_actual.satiety, unidad_actual.initialSatiety]

#func _configurar_tooltips():
	#$Panel/Margen/Contenido/Atributos/IconoRecoleccion.text = "Icono recoleccion"
	#$Panel/Margen/Contenido/Atributos/IconoReproduccion.text = "Icono reproduccion"
	#$Panel/Margen/Contenido/Atributos/IconoMovimiento.text = "Icono movimiento"
	#$Panel/Margen/Contenido/Atributos/IconoConstruccion.text = "Icono construccion"
	#$Panel/Margen/Contenido/Atributos/ValorSaciedad.text = "Icono Saciedad"

func mostrar_unidad(unidad: Unidad):
	if not is_instance_valid(unidad):
		ocultar_hud()
		return
	
	unidad_actual = unidad
	nombre_unidad.text = unidad.nombre
	estado_unidad.text = obtener_estado(unidad)
	
	valor_recoleccion.text = str(unidad.collectionSpeed)
	valor_reproduccion.text = str(unidad.breedingSpeed)
	valor_movimiento.text = str(unidad.moveSpeed)
	valor_construccion.text = str(unidad.constructionSpeed)
	valor_saciedad.text = "%d / %d" % [unidad.satiety, unidad.initialSatiety]
	
	_actualizar_rasgos(unidad)
	show()

func obtener_estado(unidad: Unidad) -> String:
	return "Estado: " + unidad.obtener_estado_actual()

func _actualizar_rasgos(unidad: Unidad):
	var textos: Array[String] = []
	
	for rasgo in unidad.traitList:
		if not is_instance_valid(rasgo):
			continue
		textos.append("%s (+%s)" % [rasgo.text, str(rasgo.traitValue)])
	
	if textos.is_empty():
		lista_rasgo.text = "Sin rasgos"
	else:
		lista_rasgo.text = "\n".join(textos)

func ocultar_hud():
	unidad_actual = null
	hide()
