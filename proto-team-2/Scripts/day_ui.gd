extends Control

@onready var day_manager = $"../../DayManager"
@onready var label_dia = $VBoxContainer/Dias
@onready var barra_dias = $VBoxContainer/ProgresoDia


func _ready() -> void:
	day_manager.dia_cambio.connect(actualizar_dia)
	day_manager.progreso_dia_actualizado.connect(actualizar_progreso)
	
	label_dia.text = "Día " + str(day_manager.dia_actual)




func _process(delta: float) -> void:
	pass

func actualizar_dia(nuevo_dia):
	label_dia.text = "Día " + str(nuevo_dia)

func actualizar_progreso(progreso):
	barra_dias.value = progreso * 100
