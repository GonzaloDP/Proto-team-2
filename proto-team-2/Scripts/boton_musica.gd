extends TextureButton

#Carga de Textura
var textura_on = preload("res://Assets/Gráficos 2D/Botones/Musica/Musica ON.png")
var textura_off = preload("res://Assets/Gráficos 2D/Botones/Musica/Musica OFF.png")

var bus_musica: int

#Busca la musica en la pestaña de audio
func _ready() -> void:
	bus_musica = AudioServer.get_bus_index("Musica")
	actualizar_icono()

#Invierte estado de silencio
func _on_pressed() -> void:
	var esta_muteado = AudioServer.is_bus_mute(bus_musica)
	AudioServer.set_bus_mute(bus_musica, not esta_muteado)
	actualizar_icono()

func actualizar_icono() -> void:
	if AudioServer.is_bus_mute(bus_musica):
		texture_normal = textura_off
	else:
		texture_normal = textura_on
