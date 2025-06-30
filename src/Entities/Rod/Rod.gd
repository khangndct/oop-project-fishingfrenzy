class_name Rod

extends Node2D

enum state { IDLE, THROW, PULL }

@export var rarity : String
@export var speed : int
@export var power : int
@export var min_length : int
@export var max_length : int
var rod_state := state.IDLE


func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	match rod_state:
		state.IDLE:
			if Input.is_action_just_pressed("spaceBar"):
				rod_state = state.THROW
		state.THROW:
			$Line.points[0].y += speed
			$Area2D.position = $Line.points[0]
			if Input.is_action_just_pressed("spaceBar"):
				rod_state = state.PULL
			if to_global($Line.points[0]).y >= screen_size.y:
				rod_state = state.PULL
		state.PULL:
			$Line.points[0].y -= speed
			$Area2D.position = $Line.points[0]
			if Input.is_action_just_pressed("spaceBar"):
				rod_state = state.THROW
			if abs($Line.points[1].y - $Line.points[0].y) <= 30:
				rod_state = state.IDLE
