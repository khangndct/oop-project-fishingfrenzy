class_name FishFactory
extends Node2D

@export var fish_scene : PackedScene
@export var fish_data_list : Array[FishData]
@export var spawn_interval: float = 2.0

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_timer_timeout() -> void:
	spawn_fish()
	
func get_random_fish_data() -> FishData:
	return fish_data_list.pick_random()

func spawn_fish():
	print("🐟 Spawning fish")
	var fish = fish_scene.instantiate()
	print("🎯 Fish instance created:", fish)
	print("🎯 Fish script path:", fish.get_script().resource_path)


	var data = get_random_fish_data()
	
	fish.fish_data = data
	
	
	var direction = "left" if randf() > 0.5 else "right"
	var spawn_y = randf_range($MinPoint.global_position.y, $MaxPoint.global_position.y)
	var screen_size = get_viewport_rect().size
	
	fish.position = Vector2(screen_size.x, spawn_y) if (direction == "left") else Vector2(0, spawn_y)
	fish.velocity = Vector2(-1, 0) if (direction == "left") else Vector2(1, 0)
	
	get_tree().current_scene.call_deferred("add_child", fish)
