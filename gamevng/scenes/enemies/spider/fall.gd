extends EnemyState

## Fall state - Spider rơi xuống đất khi có động đất

func _enter():
	print("[Spider/Fall] Entering FALL state - Spider is falling!")

	# Đổi behavior mode
	obj.behavior_mode = Spider.BehaviorMode.GROUND

	# Bật HitArea2D khi rơi xuống (gây damage liên tục)
	obj.enable_hit_area()

	# Play falling animation (nếu có)
	if obj.animated_sprite.sprite_frames.has_animation("fall"):
		obj.change_animation("fall")
	else:
		# Fallback sang idle animation
		obj.change_animation("idle")

	# Gravity sẽ tự động apply từ BaseCharacter._update_movement()
	# Không cần làm gì thêm, chỉ cần đợi chạm đất


func _update(_delta: float):
	# Check xem đã chạm đất chưa
	if obj.is_on_floor():
		print("[Spider/Fall] Hit ground! Switching to RUN state...")

		# Chuyển sang state Run (di chuyển như cua)
		if fsm.states.has("run"):
			change_state(fsm.states.run)
		else:
			push_error("[Spider/Fall] Run state not found!")


func _exit():
	print("[Spider/Fall] Exiting FALL state")


## Override take_damage - Spider vẫn nhận damage khi đang rơi
func take_damage(_damage_dir, damage: int) -> void:
	obj.velocity.x = _damage_dir.x * 150
	obj.take_damage(damage)
	change_state(fsm.states.hurt)
