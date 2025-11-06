extends Path2D

@export var platform: AnimatableBody2D
@export_range(0.0, 1.0, 0.01) var process_ratio: float = 0.0

@onready var remote_transform: RemoteTransform2D = $PathFollow2D/RemoteTransform2D
@onready var path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	if platform:
		remote_transform.remote_path = platform.get_path()

func _physics_process(delta: float) -> void:
	path_follow.progress_ratio = process_ratio
