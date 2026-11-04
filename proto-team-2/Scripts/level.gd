extends Node3D
#Este script es solo para hacer unas validaciones, luego se puede borrar

signal poblacion_actualizada

#var cantidad_maxima_unidades: int = 5
var unidades_actuales: int
var limite_unidades: int = 5
var voucherComedor

func _ready() -> void:
	#print("Level encontrado: ", Level)
	voucherComedor = true	#Al iniciar el nivel, tenemos un voucher del comedor. Este se usa para que el primer comedor se construya inmediatamente.

func _process(delta: float) -> void:
	pass

func puede_crear_unidad() -> bool:
	return unidades_actuales < limite_unidades

func agregar_unidad():
	if puede_crear_unidad():
		unidades_actuales += 1
		poblacion_actualizada.emit()

func quitar_unidades():
	if unidades_actuales > 0:
		unidades_actuales -= 1
		poblacion_actualizada.emit()

func aumentar_limite(cantidad: int):
	limite_unidades += cantidad
	poblacion_actualizada.emit()
	

func _on_alimentar_debug_pressed():		#Este método (Y el grupo que utiliza) son enteramente para propósitos de Debug. Una vez se haya implementado el edificio comedor, este se encargará de decirle a las unidades que reinicien su hambre.
	for each in get_tree().get_nodes_in_group("Unidades"):
		each._resetSatiety()

func restart_level():
	unidades_actuales = 0
	
func checkVoucher(comedor: EdificioComedor):	#Este método es llamado cuando se construye un nuevo comedor en una ubicación válida. Chequea si el voucher está activo, si lo está, el comedor se construye inmediatamente y el voucher se consume.
	if(voucherComedor):
		comedor.instaBuild()
		voucherComedor = false
