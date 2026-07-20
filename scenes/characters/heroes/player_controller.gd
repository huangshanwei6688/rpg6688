extends CharacterBody2D

## 普通行走速度，单位为像素/秒。
@export var walk_speed: float = 180.0

## 按住sprint后的跑动速度。
@export var sprint_speed: float = 230.0

## 开始移动时的加速度。
@export var acceleration: float = 1200.0

## 松开按键后的减速度。
@export var deceleration: float = 1800.0

## 跳跃初速度。Godot中Y轴负方向代表向上。
@export var jump_velocity: float = -380.0

## 使用项目设置里的2D默认重力。
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var body_animation: AnimatedSprite2D = $VisualRoot/BodyAnimation


func _ready() -> void:
	_play_animation(&"idle")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_horizontal_movement(delta)
	_handle_jump()

	# 根据velocity移动角色，并处理地面、墙壁和平台碰撞。
	move_and_slide()

	_update_visuals()


func _apply_gravity(delta: float) -> void:
	# 没有站在地面上时持续下落。
	if not is_on_floor():
		velocity.y += gravity * delta


func _handle_horizontal_movement(delta: float) -> void:
	# left返回-1，right返回1，没有输入返回0。
	var direction: float = Input.get_axis("left", "right")

	var current_speed: float = walk_speed

	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	var target_velocity_x: float = direction * current_speed

	if direction != 0.0:
		velocity.x = move_toward(
			velocity.x,
			target_velocity_x,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			deceleration * delta
		)


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


func _update_visuals() -> void:
	# 根据移动方向翻转角色。
	if velocity.x < -1.0:
		body_animation.flip_h = true
	elif velocity.x > 1.0:
		body_animation.flip_h = false

	# 目前只使用idle和run。
	if absf(velocity.x) > 5.0:
		_play_animation(&"run")

		if Input.is_action_pressed("sprint"):
			body_animation.speed_scale = 1.38
		else:
			body_animation.speed_scale = 1.0
	else:
		body_animation.speed_scale = 1.0
		_play_animation(&"idle")


func _play_animation(animation_name: StringName) -> void:
	if body_animation.sprite_frames == null:
		return

	if body_animation.sprite_frames.has_animation(animation_name):
		if body_animation.animation != animation_name:
			body_animation.play(animation_name)
		return

	# run尚未导入时，用idle代替，防止报错。
	if body_animation.sprite_frames.has_animation(&"idle"):
		if body_animation.animation != &"idle":
			body_animation.play(&"idle")
