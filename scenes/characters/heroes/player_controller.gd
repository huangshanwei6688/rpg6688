extends CharacterBody2D

@export var walk_speed: float = 180.0
@export var sprint_speed: float = 230.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1800.0
@export var jump_velocity: float = -380.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var active_action: StringName = &""
var action_time_remaining: float = 0.0

@onready var body_animation: AnimatedSprite2D = $VisualRoot/BodyAnimation


func _ready() -> void:
	_play_animation(&"idle")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_horizontal_movement(delta)
	_handle_jump()
	move_and_slide()
	_update_visuals(delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _handle_horizontal_movement(delta: float) -> void:
	var direction: float = Input.get_axis("left", "right")
	var current_speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_velocity_x: float = direction * current_speed

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, target_velocity_x, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


func _update_visuals(delta: float) -> void:
	if velocity.x < -1.0:
		body_animation.flip_h = true
	elif velocity.x > 1.0:
		body_animation.flip_h = false

	# Airborne state always uses the jump animation.
	if not is_on_floor():
		body_animation.speed_scale = 1.0
		_play_animation(&"jump")
		return

	# A triggered action continues until all of its frames have played.
	if action_time_remaining > 0.0:
		action_time_remaining -= delta
		_play_animation(active_action)
		return

	active_action = &""
	var requested_action: StringName = _get_pressed_action()
	if requested_action != &"":
		play_combat_animation(requested_action)
		return

	if absf(velocity.x) > 5.0:
		_play_animation(&"run")
		body_animation.speed_scale = 1.38 if Input.is_action_pressed("sprint") else 1.0
	else:
		body_animation.speed_scale = 1.0
		_play_animation(&"idle")


func _get_pressed_action() -> StringName:
	if Input.is_key_pressed(KEY_J):
		return &"attack1"
	if Input.is_key_pressed(KEY_K):
		return &"attack2"
	if Input.is_key_pressed(KEY_L):
		return &"attack3"
	if Input.is_key_pressed(KEY_U):
		return &"attackzj"
	if Input.is_key_pressed(KEY_I):
		return &"fangyu"
	if Input.is_key_pressed(KEY_O):
		return &"dengdai"
	return &""


# Future auto-battle code can call this method directly.
func play_combat_animation(animation_name: StringName) -> void:
	if body_animation.sprite_frames == null:
		return
	if not body_animation.sprite_frames.has_animation(animation_name):
		return

	active_action = animation_name
	body_animation.speed_scale = 1.0
	body_animation.stop()
	body_animation.frame = 0
	body_animation.frame_progress = 0.0
	body_animation.play(animation_name)

	var frame_count: int = body_animation.sprite_frames.get_frame_count(animation_name)
	var frames_per_second: float = body_animation.sprite_frames.get_animation_speed(animation_name)
	action_time_remaining = float(frame_count) / maxf(frames_per_second, 1.0)


func _play_animation(animation_name: StringName) -> void:
	if body_animation.sprite_frames == null:
		return
	if body_animation.sprite_frames.has_animation(animation_name):
		if body_animation.animation != animation_name:
			body_animation.play(animation_name)
		return

	if body_animation.sprite_frames.has_animation(&"idle"):
		if body_animation.animation != &"idle":
			body_animation.play(&"idle")
