extends Path2D
#0: move
#1: back
var state: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = 0


func _on_interactive_area_2d_interacted() -> void:
	if state == 0:
		$AnimationPlayer.play("move")
		state = 1
	else:
		$AnimationPlayer.play("back")
		state = 0


func _on_interactive_area_2d_interaction_available() -> void:
	print("available")


func _on_interactive_area_2d_interaction_unavailable() -> void:
	print("unvailable")
