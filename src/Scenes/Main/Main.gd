extends Node2D

func _ready():
	print("hello")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Play/Play.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
