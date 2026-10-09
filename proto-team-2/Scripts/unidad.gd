extends CharacterBody3D
class_name Unidad

@onready var inventario: Inventario = get_tree().current_scene.get_node("Inventario")
@onready var penaltyManager = get_tree().current_scene.get_node("PenaltiesManager")
@onready var anim_player = $AnimationPlayer
@onready var casco = $Casco
@onready var martillo = $Martillo
@onready var hacha = $Hacha
@onready var pico = $Pico
@onready var canasto = $Canasto

@export var moveSpeed: float = 6.0	#Esta variable controla la velocidad de desplazamiento de la unidad.
@export var constructionSpeed : int = 5	#La cantidad de puntos de construcción que la unidad aporta mientras construye. Mientras más, más rápido se crea el edificio.
@export var collectionSpeed: float = 10 #Igual que la constructionSpeed, pero afecta la recolección.
@export var breedingSpeed: int = 5 #Mientras más alta sea esta variable, menos tiempo tardará la unidad en salir del edificio de reproducción.
@export var initialSatiety: int = 10 #El valor inicial de saciedad de la unidad. Disminuye con el tiempo (debería), y al quedarse sin, la unidad no podrá trabajar.
var satiety	#Este es el valor de saciedad "real" de la unidad, es decir el que se modifica y se chequea para ver si tiene hambre o no.
var starving = false #Starving es un boolean que controla si la unidad está siendo incapaz de comer. De ser verdadero, la unidad no obedecerá órdenes..
var traitList: Array[Rasgo]	#Un array que contiene todos los rasgos de la unidad.
var target_resource : Recurso
var target_edificio : Edificio

@onready var progressBar = $SubViewportContainer/SubViewport/BarraProgreso

var target_position: Vector3
var en_reproduccion: bool = false
var posicion_anterior: Vector3

func _ready():
#	traitList.append(Rasgo.new("Movement Speed", 10)) Esta línea de código es puramente de Debug. Es simplemente un rasgo de prueba para mostrar que el sistema funciona. Luego lo borramos, okay?
	Level.agregar_unidad()
	target_position = global_position
	applyTraits()	#Al inicializar a la unidad, esta recorre su lista de rasgos y aplica las modificaciones correspondientes. Ya preveo que esto puede resultar en un bug, quizás sería prudente que la unidad aplique las modificaciones en un paso posterior a ser creada, para dar tiempo a cargarle sus rasgos.
	satiety = initialSatiety
	$HungerTimer.start()
	progressBar.hide()
	
	if casco:
		casco.hide()
		martillo.hide()
	
	if hacha:
		hacha.hide()
	
	if pico:
		pico.hide()
	
	if canasto:
		canasto.hide()

	if anim_player:
		anim_player.play("idle")

	set_collision_mask_value(1, true)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)



func set_move_target(new_target: Vector3, es_orden_construccion: bool = false):
	if en_reproduccion:
		return
	
	target_position = Vector3(new_target.x, global_position.y, new_target.z)
	
	# Si le damos una orden de movimiento normal, debe olvidar el edificio para no quedarse atascado
	if not es_orden_construccion:
		target_edificio = null

func _process(delta: float):
	if target_edificio and is_instance_valid(target_edificio) and not starving:
		if not target_edificio.completado:
			var distancia = global_position.distance_to(target_edificio.global_position)			# Ampliamos un poco el rango para que no se empujen entre varias unidades y cancelen el trabajo
			if distancia < 4.0: 
				set_move_target(global_position, true)
				target_edificio.recibir_trabajo(constructionSpeed * delta)
				
				if casco and not casco.visible:
					casco.show()
					martillo.show()
				
				if anim_player and anim_player.current_animation != "construir":
					anim_player.play("construir")
				
			else:
				if casco and casco.visible:
					casco.hide()
					martillo.hide()
		else:
			target_edificio = null
			if casco and casco.visible:
				casco.hide()
				martillo.hide()
	else:
		if casco and casco.visible:
			casco.hide()
			martillo.hide()
	
	# Todo este choclo para animaciones de recolección
	if target_resource and is_instance_valid(target_resource) and not starving:
		var distancia_recurso = global_position.distance_to(target_resource.global_position)
		
		if distancia_recurso < 5.0:
			if target_resource.has_method("get_names"):
				var nombre_recurso = target_resource.get_names()
				
				if nombre_recurso == "Madera":
					if pico and pico.visible:
						pico.hide()
					if canasto and canasto.visible:
						canasto.hide()
					if hacha and not hacha.visible:
						hacha.show()
					if anim_player and anim_player.current_animation != "talar":
						anim_player.play("talar")
				
				elif nombre_recurso == "Piedra" or nombre_recurso == "Metal":
					if hacha and hacha.visible:
						hacha.hide()
					if canasto and canasto.visible:
						canasto.hide()
					if pico and not pico.visible:
						pico.show()
					if anim_player and anim_player.current_animation != "picar":
						anim_player.play("picar")
				
				elif nombre_recurso == "Comida":
					if hacha and hacha.visible:
						hacha.hide()
					if pico and pico.visible:
						pico.hide()
					if canasto and not canasto.visible:
						canasto.show()
					if anim_player and anim_player.current_animation != "recolectar comida":
						anim_player.play("recolectar comida")
				
			else:
				if hacha and hacha.visible:
					hacha.hide()
				if pico and pico.visible:
					pico.hide()
				if canasto and canasto.visible:
					canasto.hide()
		else:
			if hacha and hacha.visible:
				hacha.hide()
			if pico and pico.visible:
				pico.hide()
			if canasto and canasto.visible:
				canasto.hide()
	else:
		if hacha and hacha.visible:
			hacha.hide()
		if pico and pico.visible:
			pico.hide()
		if canasto and canasto.visible:
			canasto.hide()


func _physics_process(delta: float):
	if en_reproduccion:
		return
	
	var distance_to_target = global_position.distance_to(target_position)

	if distance_to_target > 0.1:
		var direction = (target_position - global_position).normalized()
		velocity = direction * moveSpeed
		
		var look_target = Vector3(target_position.x, global_position.y, target_position.z)
		if global_position != look_target:
			look_at(look_target, Vector3.UP)
		
		move_and_slide()
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		velocity = Vector3.ZERO
		if anim_player and anim_player.current_animation != "idle" and not casco.visible and not hacha.visible and not pico.visible and not canasto.visible:
			anim_player.play("idle")

func asignar_edificio(edificio_a_construir: Edificio):
	target_resource = null
	progressBar.targetTimer = null
	progressBar.hide()
	if not $CollectionTimer.is_stopped():
		$CollectionTimer.stop()
		
	target_edificio = edificio_a_construir
	set_move_target(target_edificio.global_position, true)

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
	if en_reproduccion:
		return
	
	if(resource.cantidad_variable == 0):
		pass
	else:		#Si el recurso aún tiene para dar, entonces comprobamos que no hayamos inicializado el timer de recurso todavía. Esto es para evitar una situación en la que un jugador impaciente reinicie el timer una y otra vez.
		if($CollectionTimer.is_stopped()):
			set_move_target(resource.position)
			$CollectionTimer.start(10/get_collection_speed())	#Inicializamos el timer. Por defecto la duración es 10/collectionSpeed. Lo que nos da por defecto 1 segundo entre recolecciones.
			progressBar.targetTimer = $CollectionTimer
		target_resource = resource

func gatherResource():	#El Timer (CollectionTimer), al terminar nos lleva a esta función.
	if en_reproduccion:
		$CollectionTimer.stop()
		target_resource = null
		return
	
	if(target_resource && !starving):	#Si hay un recurso objetivo seguimos. Al dar otra orden, se borra el recurso objetivo, lo que podría causar un crash.
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
			if(target_resource.cantidad_variable == 0):
				target_resource = null
				progressBar.targetTimer = null
				progressBar.hide()
				$CollectionTimer.stop()
			else:
				$CollectionTimer.start(10/get_collection_speed())	#De todos modos, se reinicia el timer.
				progressBar.show()
		else:	#Si no hay más recursos, entonces ya no estamos haciendo nada. Acá es adonde mandaría una alerta al jugador de que está inactivo.
			target_resource = null
			progressBar.targetTimer = null
			progressBar.hide()

func entrar_en_reproduccion(Edificio: Node3D):
	en_reproduccion = true
	
	posicion_anterior = global_position
	
	velocity = Vector3.ZERO
	set_move_target(global_position)
	
	$CollectionTimer.stop()
	target_resource = null
	
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	
	hide()

func salir_de_reproduccion(posicion: Vector3):
	en_reproduccion = false
	
	global_position = posicion
	target_position = posicion
	velocity = Vector3.ZERO
	
	set_collision_layer_value(1,true)
	
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	
	show()

func hideProgressBar():
	progressBar.hide()

func _on_hunger_timer_timeout():	#Al acabarse el timer de la comida, la saciedad de la unidad disminuye en 1, y esta chequea si se ha agotado.
	satiety -= 1
	if(satiety < 1):	#Si se ha agotado la saciedad, la unidad se declara "hambrienta", por lo que ya no obedecerá al jugador. Luego comprueba si existe algún comedor.
		starving = true
		hideProgressBar()
		
		# Si tiene hambre, deja de construir y recolectar
		target_edificio = null
		target_resource = null
		
		if(get_tree().get_nodes_in_group("Comedores").is_empty()):	#Si no hay ningún comedor, la unidad se pondrá en rojo y setteara su propia posición como destino. (Es decir, se quedará quieta en el lugar)
			$MeshInstance3D.mesh.material.albedo_color = Color("DARK_RED")
			set_move_target(global_position)
		else:	#Si existen comedores, empezará a evaluarlos para encontrar el más cercano.
			goEat()

func goEat():
	if(get_tree().get_nodes_in_group("Comedores").size() == 1):	#Primero chequeamos si hay un solo comedor. De ser así, obviamos las comparativas y nos dirigimos directamente allí.
		set_move_target(get_tree().get_first_node_in_group("Comedores").global_position)
	else:
		var bestCandidate = get_tree().get_first_node_in_group("Comedores")
		var referenceDistance = global_position.distance_to(bestCandidate.global_position)	#Tomamos al iniciar la distancia con el primer comedor para usar de referencia en comparativas.
		
		for each in get_tree().get_nodes_in_group("Comedores"):	#Comparamos cada comedor en el array con el valor de referencia, si la distancia es menor, entonces se vuelve la nueva referencia.
			var distance = global_position.distance_to(each.global_position)
			
			if distance < referenceDistance:
				referenceDistance = distance
				bestCandidate =  each
		set_move_target(bestCandidate.global_position)	#Al haber evaluado todos los comedores, nos dirigimos al mejor.

func _resetSatiety():	#Este método reinicia la saciedad de la unidad y la devuelve a su color normal.
	satiety = initialSatiety
	starving = false

func _isStarving():
	return starving

func _setInheritance(parent1: Unidad, parent2: Unidad):	#Este método, llamado para las unidades que creadas a través de la reproducción, toma los mejores atributos de los padres a la hora de spawnear a la unidad, y luego llama a un método para determinar su rasgo.
	moveSpeed = maxf(parent1.moveSpeed,parent2.moveSpeed)
	constructionSpeed = maxi(parent1.constructionSpeed, parent2.constructionSpeed)
	collectionSpeed = maxf(parent1.collectionSpeed, parent2.collectionSpeed)
	breedingSpeed = maxi(parent1.breedingSpeed,parent2.breedingSpeed)
	initialSatiety = maxi(parent1.initialSatiety,parent2.initialSatiety)
	generateTrait()
	applyTraits()
	satiety = initialSatiety

func generateTrait():	#Esta función genera un rasgo aleatorio, y lo añade a la lista de rasgos de la unidad.
	var newTrait = Rasgo.new("",0)
	var random = randi_range(1,5)
	match random:
		1:
			newTrait.text = "Movement Speed"
			newTrait.traitValue = 2
		2:
			newTrait.text = "Construction Speed"
			newTrait.traitValue = 2
		3:
			newTrait.text = "Collection Speed"
			newTrait.traitValue = 4
		4:
			newTrait.text = "Breeding Speed"
			newTrait.traitValue = 2
		5:
			newTrait.text = "Satiety"
			newTrait.traitValue = 4
	traitList.append(newTrait)

func get_collection_speed() -> float:
	return collectionSpeed * penaltyManager.recolection_multiplier

func get_construction_speed() -> float:
	return constructionSpeed * penaltyManager.construction_multiplier

func get_breeding_speed() -> float:
	return breedingSpeed * penaltyManager.breeding_multiplier
func entrar_en_comedor():
	posicion_anterior = global_position
	
	velocity = Vector3.ZERO
	$CollectionTimer.stop()
	target_resource = null
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	hide()

func salir_del_comedor(posicion: Vector3):
	global_position = posicion_anterior
	target_position = posicion_anterior
	velocity = Vector3.ZERO
	
	set_collision_layer_value(1, true)
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	show()
