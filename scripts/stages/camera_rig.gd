extends Node2D

## 当前镜头跟随目标。
## 现在是Warrior，后面三职业时可以改成队伍中心点。
@export var target: Node2D

## 摄像机固定的垂直中心。
## 1280×720画面的中心Y为360。
@export var fixed_y: float = 360.0

## 摄像机比人物向右多看多少像素。
## 150会让人物大约位于屏幕宽度38%左右。
@export var look_ahead_x: float = 150.0

## 水平缓冲区。
## 目标在这个范围内小幅移动时，镜头不跟随，避免抖动。
@export var dead_zone_x: float = 40.0

## 镜头响应速度。
## 数值越大，追随越快。
@export var follow_response: float = 6.0

## 镜头每秒允许移动的最大距离。
## 防止位移技能导致镜头瞬间乱冲。
@export var max_follow_speed: float = 850.0

## 是否启用关卡左右限制。
@export var use_horizontal_limits: bool = false

## 摄像机允许到达的最小中心X。
@export var min_center_x: float = 640.0

## 摄像机允许到达的最大中心X。
## 正式关卡中设置为：关卡宽度 - 640。
@export var max_center_x: float = 9360.0


func _ready() -> void:
	if not is_instance_valid(target):
		push_warning("CameraRig没有指定Target。")
		return

	# 游戏开始时立即对准人物，不播放开场追赶过程。
	global_position = Vector2(
		_clamp_camera_x(target.global_position.x + look_ahead_x),
		fixed_y
	)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var desired_x := target.global_position.x + look_ahead_x
	var distance_x := desired_x - global_position.x

	# 人物只做小幅移动、待机抖动或受击晃动时，镜头保持稳定。
	if absf(distance_x) <= dead_zone_x:
		global_position.y = fixed_y
		return

	# 去除缓冲区距离，防止越过缓冲区时镜头突然跳动。
	desired_x -= signf(distance_x) * dead_zone_x
	desired_x = _clamp_camera_x(desired_x)

	# 与帧率无关的平滑追随。
	var smooth_weight := 1.0 - exp(-follow_response * delta)
	var movement_x := (
		desired_x - global_position.x
	) * smooth_weight

	# 限制单帧最大移动量。
	# 人物突然冲刺或传送时，镜头会稳定追上，而不是瞬间跳过去。
	var max_step := max_follow_speed * delta
	movement_x = clampf(movement_x, -max_step, max_step)

	global_position.x += movement_x
	global_position.y = fixed_y


func _clamp_camera_x(value: float) -> float:
	if not use_horizontal_limits:
		return value

	return clampf(value, min_center_x, max_center_x)
