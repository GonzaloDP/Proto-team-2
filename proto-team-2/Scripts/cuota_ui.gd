extends Control

@onready var cuota: Cuota = get_tree().current_scene.get_node("Cuota")
@onready var day_manager = $"../../DayManager"

@onready var dias_label = $VBoxContainer/DiasRestantes
@onready var madera_label = $VBoxContainer/Madera
@onready var piedra_label = $VBoxContainer/Piedra
@onready var metal_label = $VBoxContainer/Metal
@onready var comida_label = $VBoxContainer/Comida

func _ready():
	cuota.cuota_actualizada.connect(actualizar_recursos)
	day_manager.dia_cambio.connect(actualizar_dias)
	actualizar_recursos()
	actualizar_dias(1)

func actualizar_recursos():
	madera_label.text = "Madera: " + str(cuota.quota[Recurso.Tipo_Recurso.MADERA])
	piedra_label.text = "Piedra: " + str(cuota.quota[Recurso.Tipo_Recurso.PIEDRA])
	metal_label.text = "Metal: " + str(cuota.quota[Recurso.Tipo_Recurso.METAL])
	comida_label.text = "Comida: " + str(cuota.quota[Recurso.Tipo_Recurso.COMIDA])

func actualizar_dias(dia_actual: int):
	var dias_restantes = cuota.deadlineDay - dia_actual
	if(dias_restantes < 0):
		dias_restantes = 0
	dias_label.text = "Días restantes: " + str(dias_restantes)
