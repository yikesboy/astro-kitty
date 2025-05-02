extends Node

@onready var animation_player = $FadeIn/AnimationPlayer
@onready var parallax_background = $SpaceParallaxBackground
var next_scene_path: String

var asteroid_scene = preload("res://scenes/entities/asteroid-small.tscn")
var spawn_timer: Timer
var viewport_size: Vector2

func _ready():
	var play_button = get_node("Menu/HBoxContainer/Play")
	play_button.pressed.connect(_on_play_pressed)
	var quit_button = get_node("Menu/HBoxContainer/Quit")
	quit_button.pressed.connect(_on_quit_pressed)
	viewport_size = get_viewport().get_visible_rect().size
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_spawn_asteroid)
	add_child(spawn_timer)

func _process(delta):
	parallax_background.scroll_offset.y += 80 * delta
	for child in get_children():
		if child.is_in_group("asteroids"):
			child.position.y += 80 * delta
			if child.position.y > viewport_size.y + 50:
				child.queue_free()
	
func _on_play_pressed():
	next_scene_path = "res://scenes/level/level.tscn"
	animation_player.play("fade_in")
func _on_quit_pressed():
	next_scene_path = ""
	animation_player.play("fade_in")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			get_tree().quit()

func _on_tree_entered() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.add_to_group("asteroids")
	asteroid.scale = Vector2(2.0, 2.0)
	var random_x = randf_range(0, viewport_size.x)
	asteroid.position = Vector2(random_x, -50)
	
	add_child(asteroid)
