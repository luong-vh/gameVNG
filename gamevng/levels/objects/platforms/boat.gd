extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_moved: bool = false
var is_movable:bool = true
func _on_interactive_area_2d_interacted() -> void:
	if not is_movable:
		return
	if not is_moved:
		animation_player.play("move")
	else:
		animation_player.play("return")

	is_moved = !is_moved
	
func movable():
	is_movable = true

func unmovable():
	is_movable = false
