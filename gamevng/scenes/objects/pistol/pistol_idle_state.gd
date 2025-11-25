extends ObjectState


func _enter() -> void:
	var pistol = obj as Pistol
	pistol.show_idle()

func _on_player_entered(player) -> void:
	var pistol = obj as Pistol

	if not player is CharacterBody2D:
		return

	# Check trigger condition
	var should_trigger = false
	match pistol.trigger_condition:
		0:  ## Always
			should_trigger = true
		1:  ## Falling Only (velocity.y >= 0)
			should_trigger = player.velocity.y >= 0
		2:  ## Rising Only (velocity.y < 0)
			should_trigger = player.velocity.y < 0

	if should_trigger:
		pistol.push_player(player)
		change_state(fsm.states.extended)
