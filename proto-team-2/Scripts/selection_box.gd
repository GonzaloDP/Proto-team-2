extends Control#Script creado para el funcionamiento, quizás parcial, de la selección multiple de unidades

var seleccionando: bool = false
var posicion_inicio: Vector2
var posicion_actual: Vector2

func actualizar_rectangulo(inicio: Vector2, actual: Vector2) -> void:
	posicion_inicio = inicio
	posicion_actual = actual
	seleccionando = true
	queue_redraw()

func ocultar_rectangulo() -> void:
	seleccionando = false
	queue_redraw()

func _draw() -> void:
	if not seleccionando:
		return
	
	var rectangulo = Rect2(posicion_inicio, posicion_actual - posicion_inicio).abs()#con esto se construye un rectangulo tomando una posicion inicial y una actual que se va actualizando mediante arrastras el mouse
	
	draw_rect(rectangulo, Color(0.2, 0.6, 1.0, 0.2), true)
	draw_rect(rectangulo, Color(0.2, 0.6, 1.0, 0.8), false, 2.0)
