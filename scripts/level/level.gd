extends Node2D

const min_x = -2000
const max_x = 2000
const min_y = -2000
const max_y = 2000


func _ready() -> void:
	var platform = preload("res://scenes/entities/platform.tscn").instantiate()
	platform.position = Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y),
	)
	platform.rotation = 0.0
	platform.name = "Goal"
	$Entities.add_child(platform)
	
	var plat_pos = platform.global_position
	
	var asteroid_small = preload("res://scenes/entities/asteroid-small.tscn")
	for i in range(6):
		var ast = asteroid_small.instantiate()
		ast.name = "Enemy%d" % i
		ast.position = Vector2(randf_range(plat_pos.x - 50, plat_pos.x + 500), randf_range(plat_pos.y - 50, plat_pos.y + 400))
		$Entities.add_child(ast)
		print("Asteroid name: ", ast.name)
		
	for i in range(80):
		var ast = asteroid_small.instantiate()
		ast.name = "Enemy%d" % i
		ast.position = Vector2(randf_range(min_x, max_y), randf_range(min_y, max_y))
		$Entities.add_child(ast)
		print("Asteroid name: ", ast.name)
