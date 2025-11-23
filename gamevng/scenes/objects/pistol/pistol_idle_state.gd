extends ObjectState


func _enter() -> void:
	var pistol = obj as Pistol
	pistol.show_idle()

func _on_player_entered(player) -> void:
	var pistol = obj as Pistol

	if player is CharacterBody2D and player.velocity.y >= 0:
		pistol.push_player(player)
		change_state(fsm.states.extended)
