extends RigidBody2D

@export var deathParticle: PackedScene

var thrust_force: float = 150.0
var rotation_speed: float = 100.0
var gravity: float = 40.0
var landing_speed_threshold: float = 30.0
var max_speed: float = 300.0

var is_thrusting: bool = false
var thrust_started: bool = false
var thrust_start_time: float = 0.0
const thrust_buil_duration: float = 1.0

var is_touching_platform: bool = false
var contact_start_time: float = 0.0
var steady_landing_duration: float = 3.0
var is_bottom_contact: bool = false

var game_over_animation_player: AnimationPlayer
var game_won_animation_player: AnimationPlayer

func _ready() -> void:
	$RocketAnimatedSprite.play("landing")
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 3
	connect("body_entered", Callable(self, "_on_body_entered"))
	$GameOver.hide()
	$GameWon.hide()
	$GameOver/VBoxContainer/HBoxContainer/retry.connect("pressed", Callable(self, "_on_retry_pressed"))
	$GameOver/VBoxContainer/HBoxContainer/menu.connect("pressed", Callable(self, "_on_menu_pressed"))
	$GameWon/VBoxContainer/HBoxContainer/play_again.connect("pressed", Callable(self, "_on_retry_pressed"))
	$GameWon/VBoxContainer/HBoxContainer/menu.connect("pressed", Callable(self, "_on_menu_pressed"))
	
	game_over_animation_player = $GameOver/FadeIn/AnimationPlayer
	game_won_animation_player = $GameWon/FadeIn/AnimationPlayer
	
	
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
		
	if is_touching_platform:
		var speed = linear_velocity.y
		var is_slow_enough = speed < landing_speed_threshold
		
		is_bottom_contact = false
		var platform = get_node_or_null("../Entities/Goal")
		if platform and $BottomDetector/CollisionShape2D:
			for body in $BottomDetector.get_overlapping_areas():
				if body == platform:
					is_bottom_contact = true
					break

		if is_slow_enough:
			var elapsed = Time.get_ticks_msec() / 1000.0 - contact_start_time
			if elapsed >= steady_landing_duration:
				Win()
		else:
			is_touching_platform = false
		
func _on_body_entered(body) -> void:
	print("Collided with: ", body.name)
	if body.name.begins_with("Enemy"):
		Kill()
	elif body.name == "Goal":
		var speed = linear_velocity.y
		var is_slow_enough = speed < landing_speed_threshold
		
		is_bottom_contact = false
		for body_overlapping in $BottomDetector.get_overlapping_bodies():
			if body_overlapping == body:
				is_bottom_contact = true
				break
		
		if is_slow_enough and is_bottom_contact:
			is_touching_platform = true
			contact_start_time = Time.get_ticks_msec() / 1000.0
		else:
			Kill()

func _on_body_exited(body) -> void:
	if body.name == "Goal":
		is_touching_platform = false
		
func Kill():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	visible = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_physics_process(false)
	Lose()
	
func Win():
	print("WIN")
	$GameWon.show()
	
func Lose():
	print("LOSE")
	$GameOver.show()
	
func _on_retry_pressed():
	print("RETRY")
	get_tree().reload_current_scene()

func _on_menu_pressed():
	print("MENU")
	get_tree().change_scene_to_file("res://scenes/ui/titlescreen.tscn")
