extends TextureProgressBar
var targetTimer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if(visible):
		if(targetTimer):
			self.value = ((1 - targetTimer.time_left/ targetTimer.wait_time) * 100)
