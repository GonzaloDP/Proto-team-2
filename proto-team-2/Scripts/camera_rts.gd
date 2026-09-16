extends Node3D

@onready var rotation_x = $CameraRotationX
@onready var zoom_pivot = $CameraRotationX/CameraZoomPivot
@onready var camara = $CameraRotationX/CameraZoomPivot/Camera3D2

var move_target : Vector3
var edge_size = 5.0
var scroll_speed = 200

func _ready() -> void:
	move_target = position
	
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	#edge scroll
	var scroll_direction = Vector3.ZERO
	if mouse_pos.x < edge_size:
		scroll_direction.x = -1
	elif mouse_pos.x > viewport_size.x - edge_size:
		scroll_direction.x = 1
	
	if mouse_pos.y < edge_size:
		scroll_direction.z = -1
	elif mouse_pos.y > viewport_size.y - edge_size:
		scroll_direction.z = 1
	move_target += transform.basis * scroll_direction * scroll_speed * delta
	
	
	position = lerp(position, move_target, 1.0 * delta)
