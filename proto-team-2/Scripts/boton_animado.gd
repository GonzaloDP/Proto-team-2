extends Button
class_name botonAnimado

@export_category("Hover")
@export var escala_hover: Vector2 = Vector2(1.1,1.1)
@export var duración_animación_hover: float = 0.1
@export var duración_animación_salir_hover: float = 0.1

@export_category("Press")
@export var escala_press: Vector2 = Vector2(0.95,0.95)
@export var duracion_animación_press: float = 0.1
@export var duracion_animación_press_2: float = 0.1

var tweenAnimacion: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(presionar)
	
	mouse_entered.connect(hover)
	mouse_exited.connect(salirDeHover)
	
	pivot_offset_ratio = Vector2.ONE / 2.0
	
func presionar():
	if tweenAnimacion:
		tweenAnimacion.kill()
	tweenAnimacion = create_tween().set_trans(Tween.TRANS_SINE)
	
	tweenAnimacion.tween_property(self, "scale", escala_press, duracion_animación_press)
	tweenAnimacion.chain().tween_property(self, "scale", escala_hover, duracion_animación_press_2)
	
func hover():
	if tweenAnimacion:
		tweenAnimacion.kill()
	tweenAnimacion = create_tween().set_trans(Tween.TRANS_SINE)
	
	tweenAnimacion.tween_property(self, "scale", escala_hover, duración_animación_hover)
	
func salirDeHover():
	if tweenAnimacion:
		tweenAnimacion.kill()
	tweenAnimacion = create_tween().set_trans(Tween.TRANS_SINE)

	tweenAnimacion.tween_property(self, "scale", Vector2.ONE, duración_animación_salir_hover)
