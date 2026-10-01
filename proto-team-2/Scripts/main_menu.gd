extends Control




func _on_jugar_pressed() -> void:
	Level.restart_level()
	get_tree().change_scene_to_file("res://Escenas/Level.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
