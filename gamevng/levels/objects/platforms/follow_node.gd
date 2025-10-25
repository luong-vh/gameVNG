extends AnimatableBody2D


@export var path_follow_node: PathFollow2D

func _physics_process(delta):
	if path_follow_node:
		global_position = path_follow_node.global_position
