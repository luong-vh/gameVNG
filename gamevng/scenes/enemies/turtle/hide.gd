extends EnemyState

var anim: AnimatedSprite2D   

func _enter() -> void:
	if anim == null:
		anim = obj.get_node_or_null("Direction/AnimatedSprite2D")
		if anim == null:
			push_error("[Hide] AnimatedSprite2D not found at 'Direction/AnimatedSprite2D'. Check the path!")
			return
	obj.change_animation("hide")

	if not anim.is_connected("animation_finished", Callable(self, "_on_anim_finished")):
		anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _on_anim_finished():
	if anim.animation == "hide":
		if anim.is_connected("animation_finished", Callable(self, "_on_anim_finished")):
			anim.disconnect("animation_finished", Callable(self, "_on_anim_finished"))
		
		fsm.change_state(fsm.states.inshell)  

func take_damage(_dir, _dmg):
	# ignore damage when inside shell
	pass
