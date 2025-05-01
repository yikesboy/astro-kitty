extends Node

@export var rocket_path: NodePath

@onready var horizontal_speed_display = $HBoxContainer/horizontal_speed
@onready var vertical_speed_display = $HBoxContainer/vertical_speed

@onready var rocket = get_node(rocket_path)

func _physics_process(delta: float) -> void:
	var h_speed = abs(rocket.linear_velocity.x)
	var v_speed = abs(rocket.linear_velocity.y)
	
	horizontal_speed_display.text = "Horizontal Speed: %.2f" % h_speed
	vertical_speed_display.text = "Vertical Speed: %.2f" % v_speed
