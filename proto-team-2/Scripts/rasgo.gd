class_name Rasgo

var host: Unidad	#A que unidad afecta el rasgo.
var text: String	#El texto que indica que atributo modifica el rasgo. Por ejemplo "Movement Speed"
var traitValue		#Cuanto modifica el rasgo al atributo correspondiente.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init(traitText: String, value: int):	#Este es un constructor para la clase rasgo. En teoría, esto no habría que usarlo luego, ya que los rasgos pueden ser sus propias clases (Y tener un _init no nos deja instanciar normalmente). Quitar luego.
	text = traitText
	traitValue = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setHost(newHost: Unidad):
	host = newHost
	

func applyTrait():	#Llamamos al método modifyAttribute del host, el cual chequea el texto del rasgo y suma el valor de este a su atributo correspondiente. MUY IMPORTANTE: SOLO USAR UNA VEZ POR RASGO POR UNIDAD.
	host.modifyAttribute(text, traitValue)
