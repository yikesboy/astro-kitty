extends Node2D

const min_x = 200
const max_x = 1000
const min_y = 200
const max_y = 1000


func _ready() -> void:
	var platform = preload("res://scenes/entities/platform.tscn").instantiate()
	platform.position = Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y),
	)
	platform.rotation = 0.0
	platform.name = "Goal"
	$Entities.add_child(platform)
