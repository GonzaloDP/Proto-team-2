extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$Panel.hide()
	$Panel/DefeatTitle.hide()
	$Panel/DefeatText.hide()
	$Panel/RestartButton.hide()
	$Panel/QuitButton.hide()

func _showDefeatScreen():
	show()
	$Panel.show()
	showText()	#Activamos el método de mostrar texto, el cual hará aparecer gradualmente el texto.
	get_tree().paused = true #Al mostrar la pantalla de derrota, pausamos el juego.
	showButtons()

func showText():
	var tween = create_tween()
	$Panel/DefeatTitle.show()
	tween.tween_property($Panel/DefeatTitle,"visible_ratio",1.0,0.5)
	$Panel/DefeatText.show()
	tween.tween_property($Panel/DefeatText,"visible_ratio",1.0,3.0)

func showButtons():
	await get_tree().create_timer(4.0).timeout
	$Panel/RestartButton.show()
	$Panel/QuitButton.show()
	
func _on_restart_button_pressed():
	get_tree().paused = false
	Level.restart_level()
	get_tree().reload_current_scene()

func _on_quit_button_pressed():	#Al apretar el botón de salir, volvemos al menú principal.
	get_tree().paused = false
	Level.restart_level()
	get_tree().change_scene_to_file("res://Escenas/Main_Menu.tscn")
