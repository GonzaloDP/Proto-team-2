extends Node

signal dia_cambio(nuevo_dia)
signal progreso_dia_actualizado(progreso_dia)
signal actualizar_ui(nuevo_dia)

@onready var timer : Timer = $Timer

@export var duracion_dia : float = 3.0

var dia_actual : int = 1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = duracion_dia
	timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progreso_dia = 1.0 - (timer.time_left / duracion_dia)
	progreso_dia_actualizado.emit(progreso_dia)
	pass


func _on_timer_timeout() -> void:
	dia_actual += 1
	print("DayManager emitió dia_cambio: ", dia_actual)
	dia_cambio.emit(dia_actual)
	pass # Replace with function body.
	
func _update_day_manually():
	actualizar_ui.emit(dia_actual)
	print("actualizando manualmente... ", dia_actual)
	#Este método actualiza manualmente la UI. Lo utiliza la cuota cuando perdona, así se actualiza correctamente cuota_ui. También afecta al day_ui por razones de consistencia.
