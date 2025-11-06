extends EnemyState

@export var hide_duration := 3.0

func _enter():
	obj.change_animation("in_shell")
	await get_tree().create_timer(hide_duration).timeout
	fsm.change_state(fsm.states.emerge)

func take_damage(_dir, _dmg):
	# ignore damage when inside shell
	pass
