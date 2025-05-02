extends Node

@onready var animation_player = $FadeIn/AnimationPlayer
var next_scene_path: String

func _ready():
	var play_button = get_node("Menu/HBoxContainer/Play")
	play_button.pressed.connect(_on_play_pressed)
	var quit_button = get_node("Menu/HBoxContainer/Quit")
	quit_button.pressed.connect(_on_quit_pressed)
	
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
