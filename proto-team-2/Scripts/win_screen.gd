extends Control

@onready var cuota: Cuota = get_tree().current_scene.get_node("Cuota")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	cuota.victoria.connect(showWinScreen)
	hide()
	$Panel.hide()
	$Panel/WinTitle.hide()
	$Panel/WinText.hide()
	$Panel/QuitButton.hide()

func showWinScreen():
	show()
	$Panel.show()
	showText()	#Activamos el método de mostrar texto, el cual hará que el texto aparezca de forma gradual.
	showButton()
	get_tree().paused = true #Al mostrar la pantalla de victoria, pausamos el juego.

func showText():
	var tween = create_tween()
	$Panel/WinTitle.show()
	tween.tween_property($Panel/WinTitle,"visible_ratio",1.0,0.5)
	$Panel/WinText.show()
	tween.tween_property($Panel/WinText,"visible_ratio",1.0,3.0)
	showButton()

func showButton():
	await get_tree().create_timer(1.0).timeout
	$Panel/QuitButton.show()
	
func _on_quit_button_pressed():	#Al apretar el botón de salir, volvemos al menú principal. En versiones futuras, si es que añadimos más mapas, esto debería comunicar al menú principal que el mapa actual ha sido superado.
	get_tree().paused = false
	Level.restart_level()
	get_tree().change_scene_to_file("res://Escenas/Main_Menu.tscn")
