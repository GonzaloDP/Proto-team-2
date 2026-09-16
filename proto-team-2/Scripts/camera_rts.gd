extends Node3D

@onready var rotation_x = $CameraRotationX
@onready var zoom_pivot = $CameraRotationX/CameraZoomPivot
@onready var camara = $CameraRotationX/CameraZoomPivot/Camera3D2

var move_target : Vector3
var edge_size = 5.0
var scroll_speed = 20
var zoom_speed = 3.0
var zoom_target : float
var min_zoom = -5
var max_zoom = 20

func _ready() -> void:
	move_target = position
	zoom_target = camara.position.z
	
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom_dir = (int(Input.is_action_just_released("camara_zoom_out")) -
					int(Input.is_action_just_released("camara_zoom_in")))
	
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
	
	zoom_target += zoom_dir * zoom_speed
	zoom_target = clamp(zoom_target,min_zoom,max_zoom)
	
	position = move_target
	camara.position.z = lerp(camara.position.z, zoom_target, 0.10)
