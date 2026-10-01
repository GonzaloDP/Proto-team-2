extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("ESC DETECTADO")
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func resume_game() -> void:
	print("REANUDANDO")
	hide()
	get_tree().paused = false

func pause_game() -> void:
	print("PAUSANDO")
	get_tree().paused = true
	show()

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Level.restart_level()
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	#Agregar acá ir a escena menu principal
