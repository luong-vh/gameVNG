extends EnemyCharacter
class_name Spider

## Spider - Enemy/Hazard
## Có 2 behaviors: Treo trên trần kéo player (HANG) hoặc rơi xuống chạy như cua (GROUND)

## Behavior modes
enum BehaviorMode { HANGING, GROUND }

## Export variables (cho hang behavior)
@export var pull_speed: float = 300.0  ## Tốc độ kéo player lên (pixels/giây)
@export var hold_duration: float = 0.5  ## Giữ player bao lâu trước khi thả (giây)
@export var cooldown_duration: float = 2.0  ## Cooldown sau khi thả (giây)
@export var pull_offset: Vector2 = Vector2(0, 16)  ## Offset từ vị trí player (nhện ở phía trên player bao nhiêu)
@export var descend_speed: float = 0.3  ## Tốc độ nhện hạ xuống/lên (giây)

## Export variables (cho ground behavior)
const SPEED = 170.0

## Signals
signal player_pulled(player: Node2D)
signal player_released(player: Node2D)

## State variables
var behavior_mode: BehaviorMode = BehaviorMode.HANGING
var initial_hang_position: Vector2  ## Vị trí treo ban đầu

## Node references (thêm vào EnemyCharacter đã có)
@onready var pull_detector: RayCast2D = $PullDetector
@onready var grab_area: Area2D = $GrabArea2D if has_node("GrabArea2D") else null
@onready var web_line: Line2D = $WebLine if has_node("WebLine") else null
@onready var hit_area: Area2D = $Direction/HitArea2D if has_node("Direction/HitArea2D") else null
@onready var hit_collision: CollisionShape2D = $Direction/HitArea2D/CollisionShape2D if has_node("Direction/HitArea2D/CollisionShape2D") else null


func _ready() -> void:
	# QUAN TRỌNG: Phải set type TRƯỚC khi gọi super._ready()
	# Vì EnemyCharacter._ready() sẽ gọi _add_into_enemy_manager() cần type
	type = "SPIDER"

	# Gọi parent _ready() (EnemyCharacter sẽ gọi _add_into_enemy_manager())
	super._ready()

	# Init FSM SAU khi parent ready
	fsm = FSM.new(self, $States, $States/Hang)  # Default state: Hang

	print("[Spider] Initialized at position: ", global_position)

	# Lưu vị trí treo ban đầu
	initial_hang_position = position

	# Setup web line (ẩn ban đầu)
	if web_line:
		web_line.visible = false
		print("[Spider] WebLine found! Width: ", web_line.width, " Color: ", web_line.default_color)
	else:
		print("[Spider] WARNING: WebLine node NOT found!")

	# Tắt HitArea2D khi khởi tạo (đang treo)
	disable_hit_area()

	# Kết nối earthquake signal
	GameManager.earthquake_triggered.connect(_on_earthquake)




## Override movement để disable gravity khi HANGING
func _update_movement(delta: float) -> void:
	# Chỉ apply gravity khi ở GROUND mode
	if behavior_mode == BehaviorMode.GROUND:
		velocity.y += gravity * delta
		move_and_slide()
	else:
		# HANGING mode: không có gravity
		# Spider di chuyển bằng tween (trong hang.gd), không dùng velocity
		# Chỉ cần move_and_slide() để update collision
		velocity = Vector2.ZERO
		move_and_slide()


## Implement abstract methods từ EnemyCharacter
func _add_into_enemy_manager():
	EnemyManager.add_enemy(self, type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self, type)

func change_to_day_behavior():
	print("[Spider] Changed behavior to DAY")
	# Spider không thay đổi behavior theo ngày/đêm

func change_to_night_behavior():
	print("[Spider] Changed behavior to NIGHT")
	# Spider không thay đổi behavior theo ngày/đêm


## Earthquake handler
func _on_earthquake(strength, duration):
	# Chỉ trigger nếu spider đang HANGING và trong vùng camera
	if behavior_mode == BehaviorMode.HANGING and _is_in_camera():
		print("[Spider] Earthquake detected! Falling down...")
		behavior_mode = BehaviorMode.GROUND

		# Chuyển sang state Fall
		if fsm and fsm.states.has("fall"):
			fsm.change_state(fsm.states.fall)

func _is_in_camera() -> bool:
	"""Check xem spider có trong vùng camera không"""
	if not GameManager.main_camera:
		return false

	var camera = GameManager.main_camera
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.global_position

	# Tính khoảng cách từ spider tới camera
	var distance = global_position.distance_to(camera_pos)

	# Check nếu trong tầm camera (viewport width/2 + buffer)
	return distance < (viewport_size.x / 2.0) + 100


## Helper functions để control HitArea2D
func enable_hit_area() -> void:
	"""Bật HitArea2D để gây damage"""
	if hit_collision:
		hit_collision.disabled = false
		print("[Spider] HitArea2D ENABLED - Can deal damage")

func disable_hit_area() -> void:
	"""Tắt HitArea2D để không gây damage"""
	if hit_collision:
		hit_collision.disabled = true
		print("[Spider] HitArea2D DISABLED - Cannot deal damage")
