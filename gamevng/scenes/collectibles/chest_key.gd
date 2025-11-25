extends BaseCollectible

# Số lượng chìa khóa nhặt được (thường là 1)
@export var key_amount: int = 1 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called, which connects interaction_available
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_collect():
	# Ngắt tương tác ngay
	monitoring = false 

	# GỌI HÀM THÊM CHÌA KHÓA VÀO HỆ THỐNG
	GameManager.inventory_system.add_key(key_amount) 

	print("Đã thu thập " + str(key_amount) + " chìa khóa!")

	# BẮT ĐẦU CHẠY ANIMATION
	animated_sprite_2d.play("collected")

func _on_animation_finished():
	if animated_sprite_2d.animation == "collected":
		queue_free() # Tự hủy sau khi animation "collected" chạy xong
