extends RigidBody2D

var thrust_force: float = 150.0
var rotation_speed: float = 100.0
var gravity: float = 40.0
var landing_speed_threshold: float = 50.0
var max_speed: float = 300.0

var is_thrusting: bool = false
var thrust_started: bool = false
var thrust_start_time: float = 0.0
const thrust_buil_duration: float = 1.0

func _ready() -> void:
	$RocketAnimatedSprite.play("landing")
	gravity_scale = 0
	
func _physics_process(delta: float) -> void:
	apply_force(Vector2(0, gravity * mass))
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(-rotation_speed * mass)
	if Input.is_action_pressed("rotate_right"):
		apply_torque(rotation_speed * mass)
	
	if Input.is_action_pressed("thrust"):
		if not is_thrusting:
			is_thrusting = true
			thrust_started = true
			thrust_start_time = Time.get_ticks_msec() / 1000
			$RocketAnimatedSprite.play("thrust_build")
		
		var thrust_vector = Vector2(0, -thrust_force).rotated(rotation)
		apply_force(thrust_vector)
	else:
		if is_thrusting:
			is_thrusting = false
			thrust_started = false
			if linear_velocity.length() < landing_speed_threshold:
				$RocketAnimatedSprite.play("landing")
			else:
				$RocketAnimatedSprite.play("idle")
				
	if is_thrusting and thrust_started:
		var elapsed = Time.get_ticks_msec() / 1000.0 - thrust_start_time
		if elapsed >= thrust_buil_duration:
			thrust_started = false
			$RocketAnimatedSprite.play("thrust_sustain")
		elif is_thrusting and not thrust_started:
			if $RocketAnimatedSprite.animation != "thrust_sustain":
				$RocketAnimatedSprite.play("thrust_sustain")
		elif not is_thrusting and linear_velocity.length() < landing_speed_threshold:
			if $RocketAnimatedSprite.animation != "landing":
				$RocketAnimatedSprite.play("landing")
				
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
