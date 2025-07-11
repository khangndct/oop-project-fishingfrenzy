class_name Player

extends Node2D


enum State { IDLE, MOVE_LEFT, MOVE_RIGHT, AT_LEFTBOUND, AT_RIGHTBOUND }


@export var speed : int = 10
var player_state : int = State.IDLE


func _ready():
	pass

func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	match player_state:
		State.IDLE:
			if Input.is_action_pressed("arrowRight"):
				player_state = State.MOVE_RIGHT
			if Input.is_action_pressed("arrowLeft"):
				player_state = State.MOVE_LEFT
		State.MOVE_LEFT:
			position.x -= speed
			if $LeftPoint.global_position.x <= 0:
				player_state = State.AT_LEFTBOUND
			elif not Input.is_action_pressed("arrowLeft"):
				player_state = State.IDLE
		State.MOVE_RIGHT:
			position.x += speed
			if $RightPoint.global_position.x >= screen_size.x:
				player_state = State.AT_RIGHTBOUND
			elif not Input.is_action_pressed("arrowRight"):
				player_state = State.IDLE
		State.AT_LEFTBOUND:
			if Input.is_action_pressed("arrowRight"):
				player_state = State.MOVE_RIGHT
		State.AT_RIGHTBOUND:
			if Input.is_action_pressed("arrowLeft"):
				player_state = State.MOVE_LEFT
			
