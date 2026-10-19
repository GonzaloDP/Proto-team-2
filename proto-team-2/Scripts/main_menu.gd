extends Control




func _on_jugar_pressed() -> void:
	await get_tree().create_timer(0.2).timeout
	Level.restart_level()
	get_tree().change_scene_to_file("res://Escenas/Level.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
