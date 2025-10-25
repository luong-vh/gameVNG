extends Area2D

# Hàm này sẽ tự động được gọi khi có một PhysicsBody2D (như Player) đi vào
func _on_body_entered(body):
	body.call("collected_blade")
	queue_free()
