extends CharacterBody3D
class_name Unidad

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")

@export var moveSpeed: float = 6.0	#Esta variable controla la velocidad de desplazamiento de la unidad.
@export var constructionSpeed : int = 5	#La cantidad de puntos de construcción que la unidad aporta mientras construye. Mientras más, más rápido se crea el edificio.
@export var collectionSpeed: float = 10 #Igual que la constructionSpeed, pero afecta la recolección.
@export var breedingSpeed: int = 5 #Mientras más alta sea esta variable, menos tiempo tardará la unidad en salir del edificio de reproducción.
@export var initialSatiety: int = 10 #El valor inicial de saciedad de la unidad. Disminuye con el tiempo (debería), y al quedarse sin, la unidad no podrá trabajar.
var satiety	#Este es el valor de saciedad "real" de la unidad, es decir el que se modifica y se chequea para ver si tiene hambre o no.
var traitList: Array[Rasgo]	#Un array que contiene todos los rasgos de la unidad.
var target_resource : Recurso


var target_position: Vector3

func _ready() -> void:
#	traitList.append(Rasgo.new("Movement Speed", 10)) Esta línea de código es puramente de Debug. Es simplemente un rasgo de prueba para mostrar que el sistema funciona. Luego lo borramos, okay?
	satiety = initialSatiety
	target_position = global_position
	applyTraits()	#Al inicializar a la unidad, esta recorre su lista de rasgos y aplica las modificaciones correspondientes. Ya preveo que esto puede resultar en un bug, quizás sería prudente que la unidad aplique las modificaciones en un paso posterior a ser creada, para dar tiempo a cargarle sus rasgos.
	

func set_move_target(new_target: Vector3):
	target_position = Vector3(new_target.x, global_position.y, new_target.z)

func _physics_process(delta: float):
	var distance_to_target = global_position.distance_to(target_position)
	

	if distance_to_target > 0.1:
		var direction = (target_position - global_position).normalized()
		velocity = direction * moveSpeed
		
		
		var look_target = Vector3(target_position.x, global_position.y, target_position.z)
		if global_position != look_target:
			look_at(look_target, Vector3.UP)
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func modifyAttribute(attribute: String, value: int):	#Función que mejora los atributos de la unidad. Recibe un String (en inglés común), que se compara con un switch, y un value por el cual aumentar el valor de atributo.
	match(attribute):
		"Movement Speed":
			moveSpeed += value
		"Construction Speed":
			constructionSpeed += value
		"Collection Speed":
			collectionSpeed += value
		"Breeding Speed":
			breedingSpeed += value
		"Satiety":
			initialSatiety += value

func applyTraits():	#Recorre todos los rasgos en el array traitList, y pide a cada uno que aplique su efecto.
	for each in traitList:
		each.host = self
		each.applyTrait()
		
func seekResource(resource: Recurso):	#Al detectar un recurso, lo primero que hace es chequear que el recurso no esté vacío. Si lo está, no hace nada.
	if(resource.cantidad_variable == 0):
		pass
	else:		#Si el recurso aún tiene para dar, entonces comprobamos que no hayamos inicializado el timer de recurso todavía. Esto es para evitar una situación en la que un jugador impaciente reinicie el timer una y otra vez.
		if($CollectionTimer.is_stopped()):
			set_move_target(resource.position)
			$CollectionTimer.start(10/collectionSpeed)	#Inicializamos el timer. Por defecto la duración es 10/collectionSpeed. Lo que nos da por defecto 1 segundo entre recolecciones.
		target_resource = resource
		
func gatherResource():	#El Timer (CollectionTimer), al terminar nos lleva a esta función.
	if(target_resource):	#Si hay un recurso objetivo seguimos. Al dar otra orden, se borra el recurso objetivo, lo que podría causar un crash.
		if(target_resource.cantidad_variable > 0):	#¿Sigue habiendo recursos que recolectar?
			if(position.distance_to(target_resource.position) < 5):	#Si la unidad está lo suficientemente cerca, se detiene (target de movimiento a su propa posición), recoge 10 recursos.
				set_move_target(position)
				if target_resource is RecursoRespawn:
					var cantidad_recolectaba = target_resource.cantidad_variable
					var tipo_recurso = target_resource.obtener_tipo_recurso()
					target_resource.reduceQuantity(cantidad_recolectaba)
					inventario.agregar_recurso(tipo_recurso, cantidad_recolectaba)
				else:
					target_resource.reduceQuantity(10)
					inventario.agregar_recurso(target_resource.tipo, 10)
			else:
				set_move_target(target_resource.position)
			$CollectionTimer.start(10/collectionSpeed)	#De todos modos, se reinicia el timer.
		else:	#Si no hay más recursos, entonces ya no estamos haciendo nada. Acá es adonde mandaría una alerta al jugador de que está inactivo.
			target_resource = null
		
