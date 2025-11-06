extends Node2D

@export var respawn_player: bool = true
@export var respawn_delay: float = 0.4

func _on_hit_area_2d_hitted(area: Variant) -> void:
	if respawn_player:
		SceneTransition.fade_to_black()
		await get_tree().create_timer(respawn_delay).timeout
		GameManager.respawn_at_ground_checkpoint()
