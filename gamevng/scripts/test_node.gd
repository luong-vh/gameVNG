extends Sprite2D

const SPEED = 100
var distance = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Con"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x+= SPEED*delta
	distance+= SPEED*delta
	$Label.text ="Đã di chuyển x: " + str(int(distance))
	
	if (distance > 300): queue_free()
	
