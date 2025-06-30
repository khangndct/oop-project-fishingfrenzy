extends Node2D

var Player = preload("res://Entities/Player/Player.tscn")

func _ready():
	var player = Player.instantiate()
	player.position = $StartPoint.position
	add_child(player)

#func _process(delta):
	
		
