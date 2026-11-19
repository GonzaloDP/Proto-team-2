extends Edificio
class_name EdificioPasivo

var ocupante : Unidad
@export var recursoGenerado : Recurso.Tipo_Recurso
@export var cantidadGenerada : int
var ocupado : bool

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")
@onready var progressBar = $SubViewportContainer/SubViewport/BarraProgreso

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

func recibirUnidad(unidad: Unidad):	#Al ingresar una unidad al edificio pasivo, esta se pondrá invisible y se quedará quieta. El edificio entonces comenzará a generar recursos.
	if unidad == ocupante:
		ocupante.entrar_en_edificio()
		ocupado = true
		$"TimerRecolección".start(100/ocupante.get_collection_speed()*2) #Multiplicamos el CollectionSpeed del ocupante por 2, para que aumentos en la velocida de recolección tengan más impacto.
		progressBar.show()
	
func generarRecurso():
	inventario.agregar_recurso(recursoGenerado, cantidadGenerada)
	if(ocupante._isStarving()):	
		expulsarOcupanteHambriento()
	else:
		reiniciarTimer()
	
func expulsarOcupanteHambriento():
	kickOutUnit(ocupante)
	#Acá hacemos que la unidad respawnee en otro lado y se vaya a comer. No la quitamos como ocupante porque después vuelve.
	ocupante.target_edificio = self
	ocupante.saveTask()
	ocupante.goEat()
	ocupante.show()

func reiniciarTimer():
	$"TimerRecolección".start(100/ocupante.get_collection_speed()*2)

func kickOutUnit(unidad: Unidad):
	ocupado = false
	progressBar.hide()
	$"TimerRecolección".stop()
	ocupante._salir_de_edificio()
	unidad.global_position = $PuntoRespawn.global_position
	unidad.set_move_target($PuntoRespawn.global_position)


#Idea: Hacer que cuando digamos a una unidad que vaya a trabajar al Edificio Pasivo, que se le envíe un mensaje al edificio diciéndole que esa unidad quiere trabajar allí, de tal modo que la auto-acepte.
#Plan: Unidad entra al edificio pasivo. Una vez dentro, comienza un timer (afectado por el CollectionSpeed de la unidad), el cual al finalizar genera recursos. Debería tener el mismo Iconito que la unidad tiene cuando trabaja. Eso se acopla después.


func _on_area_3d_body_entered(body: Node3D) -> void:
		if body is Unidad:
			var unidad := body as Unidad
		
			if (unidad._isStarving() == false && ocupado == false):
				recibirUnidad(unidad)
