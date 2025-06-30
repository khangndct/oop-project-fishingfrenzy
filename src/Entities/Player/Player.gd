class_name Player

extends Node2D


enum state { IDLE, MOVE_LEFT, MOVE_RIGHT, AT_LEFTBOUND, AT_RIGHTBOUND }


@export var speed : int
var player_state : int


var Rod = preload("res://Entities/Rod/Rod.tscn")


func _ready():
	player_state = state.IDLE
	var rod = Rod.instantiate()
	rod.position = $HoldingPoint.position
	add_child(rod)
	

func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	match player_state:
		state.IDLE:
			if Input.is_action_pressed("arrowRight"):
				player_state = state.MOVE_RIGHT
			if Input.is_action_pressed("arrowLeft"):
				player_state = state.MOVE_LEFT
		state.MOVE_LEFT:
			position.x -= speed
			if global_position.x <= 0:
				player_state = state.AT_LEFTBOUND
			elif not Input.is_action_pressed("arrowLeft"):
				player_state = state.IDLE
		state.MOVE_RIGHT:
			position.x += speed
			if global_position.x >= screen_size.x:
				player_state = state.AT_RIGHTBOUND
			elif not Input.is_action_pressed("arrowRight"):
				player_state = state.IDLE
		state.AT_LEFTBOUND:
			if Input.is_action_pressed("arrowRight"):
				player_state = state.MOVE_RIGHT
		state.AT_RIGHTBOUND:
			if Input.is_action_pressed("arrowLeft"):
				player_state = state.MOVE_LEFT
			
