class_name Player

extends Node2D

signal energy_changed(new_energy)

enum State { IDLE, MOVE_LEFT, MOVE_RIGHT, AT_LEFTBOUND, AT_RIGHTBOUND }

@export var speed : int = 10
@export var max_energy : int = 100
@export var energy_cost_per_fish : int = 2

var player_state : int = State.IDLE
var energy : int = 100 : set = set_energy


func _ready():
	energy = max_energy  # Initialize energy to max

func set_energy(new_energy: int):
	energy = clamp(new_energy, 0, max_energy)
	energy_changed.emit(energy)

func reduce_energy_for_fish():
	energy -= energy_cost_per_fish
	if energy <= 0:
		print("Player is exhausted!")

func restore_energy(amount: int):
	energy += amount

func _physics_process(_delta):
	var screen_size = get_viewport_rect().size
	
	# Apply speed potion effect
	var current_speed = speed
	if GlobalVariable.has_speed_potion:
		current_speed = int(speed * 1.2)  # 20% speed increase
	
	match player_state:
		State.IDLE:
			if Input.is_action_pressed("arrowRight"):
				player_state = State.MOVE_RIGHT
			if Input.is_action_pressed("arrowLeft"):
				player_state = State.MOVE_LEFT
		State.MOVE_LEFT:
			position.x -= current_speed
			if $LeftPoint.global_position.x <= 0:
				player_state = State.AT_LEFTBOUND
			elif not Input.is_action_pressed("arrowLeft"):
				player_state = State.IDLE
		State.MOVE_RIGHT:
			position.x += current_speed
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
			
