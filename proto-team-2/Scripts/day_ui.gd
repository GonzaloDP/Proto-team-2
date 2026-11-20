extends Control

@onready var day_manager = $"../../DayManager"
@onready var label_dia = $VBoxContainer/Dias
@onready var barra_dias = $VBoxContainer/ProgresoDia
@onready var cuota: Cuota = $"../../Cuota"

var tween_parpadeo: Tween
var parpadeo_ultimo_dia := false
var progreso_actual := 0.0

func _ready() -> void:
	day_manager.dia_cambio.connect(actualizar_dia)
	day_manager.progreso_dia_actualizado.connect(actualizar_progreso)
	day_manager.actualizar_ui.connect(actualizar_dia)
	label_dia.text = "Día " + str(day_manager.dia_actual)

func _process(delta: float) -> void:
	pass

func actualizar_dia(nuevo_dia):
	label_dia.text = "Día " + str(nuevo_dia)
	
	detener_parpadeo()
	
	var dias_restantes = cuota.deadlineDay - nuevo_dia
	
	if dias_restantes == 1:
		parpadeo_temporal()
	elif dias_restantes == 0:
		comprobar_ultimo_dia()

func actualizar_progreso(progreso):
	progreso_actual = progreso
	barra_dias.value = progreso * 100
	
	comprobar_ultimo_dia()

func comprobar_ultimo_dia():
	if cuota.deadlineDay - day_manager.dia_actual != 0:
		return
	
	var duracion_dia = day_manager.duracion_dia
	
	var momento_alerta = (duracion_dia - 20.0) / duracion_dia
	
	if progreso_actual >= momento_alerta:
		if not parpadeo_ultimo_dia:
			parpadeo_ultimo_dia = true
			iniciar_parpadeo()

func parpadeo_temporal():
	iniciar_parpadeo()
	
	await get_tree().create_timer(2.0, true).timeout
	
	if not parpadeo_ultimo_dia:
		detener_parpadeo()

func iniciar_parpadeo():
	if tween_parpadeo and tween_parpadeo.is_running():
		return
	
	tween_parpadeo = create_tween().set_loops()
	
	tween_parpadeo.tween_property(self, "modulate:a", 0.25, 0.4)
	tween_parpadeo.tween_property(self, "modulate:a", 1.0, 0.4)

func detener_parpadeo():
	if tween_parpadeo and tween_parpadeo.is_running():
		tween_parpadeo.kill()
	
	tween_parpadeo = null
	modulate.a = 1.0
	parpadeo_ultimo_dia = false
