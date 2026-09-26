extends Node

signal dia_cambio(nuevo_dia)
signal progreso_dia_actualizado(progreso_dia)

@onready var timer : Timer = $Timer

@export var duracion_dia : float = 10.0

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
	dia_cambio.emit(dia_actual)
	pass # Replace with function body.
