extends CharacterBody3D

@export var speed: float = 6.0
var target_position: Vector3

func _ready() -> void:
	target_position = global_position

func set_move_target(new_target: Vector3) -> void:
	target_position = Vector3(new_target.x, global_position.y, new_target.z)

func _physics_process(delta: float) -> void:
	var distance_to_target = global_position.distance_to(target_position)
	

	if distance_to_target > 0.1:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		
		
		var look_target = Vector3(target_position.x, global_position.y, target_position.z)
		if global_position != look_target:
			look_at(look_target, Vector3.UP)
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO
