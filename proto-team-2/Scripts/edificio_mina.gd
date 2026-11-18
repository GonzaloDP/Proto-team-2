extends EdificioPasivo

@export var recursoGenerado2 : Recurso.Tipo_Recurso

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progressBar.hide()
	progressBar.targetTimer = $"TimerRecolección"
	ocupado = false
	puntosDeSalida = [$PuntoRespawn]
	if completado:
		if barra_progreso:
			barra_progreso.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generarRecurso():
	inventario.agregar_recurso(recursoGenerado, cantidadGenerada)
	inventario.agregar_recurso(recursoGenerado2, cantidadGenerada)
	if(ocupante._isStarving()):	
		expulsarOcupanteHambriento()
	else:
		reiniciarTimer()
