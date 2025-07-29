class_name Player

extends Node2D

signal energy_changed(new_energy)

enum State { IDLE, MOVE_LEFT, MOVE_RIGHT, AT_LEFTBOUND, AT_RIGHTBOUND }

@export var speed : int = 10
@export var max_energy : int = 100
@export var energy_cost_per_fish : int = 2

# Player Stats
@export var strength : int = 1 : set = set_strength
@export var speed_stat : int = 1 : set = set_speed_stat
@export var vitality : int = 1 : set = set_vitality
@export var luck : int = 1 : set = set_luck

# Fractional stats for gradual progression
var fractional_strength : float = 0.0
var fractional_speed : float = 0.0
var fractional_vitality : float = 0.0
var fractional_luck : float = 0.0

var player_state : int = State.IDLE
var energy : int = 100 : set = set_energy


func _ready():
	# Load stats from GlobalVariable (persistent across scenes)
	strength = GlobalVariable.player_strength
	speed_stat = GlobalVariable.player_speed_stat
	vitality = GlobalVariable.player_vitality
	luck = GlobalVariable.player_luck
	
	# Load fractional stats
	fractional_strength = GlobalVariable.player_fractional_strength
	fractional_speed = GlobalVariable.player_fractional_speed
	fractional_vitality = GlobalVariable.player_fractional_vitality
	fractional_luck = GlobalVariable.player_fractional_luck
	
	# Load persistent energy or initialize to max if first time
	if GlobalVariable.player_energy <= 0:
		energy = max_energy  # First time initialization
		GlobalVariable.player_energy = energy
	else:
		energy = GlobalVariable.player_energy  # Load saved energy
	
	# Set global reference to this player
	GlobalVariable.player_ref = self

func set_energy(new_energy: int):
	energy = clamp(new_energy, 0, max_energy)
	GlobalVariable.player_energy = energy  # Save to global
	energy_changed.emit(energy)

func set_strength(new_strength: int):
	strength = max(1, new_strength)
	GlobalVariable.player_strength = strength

func set_speed_stat(new_speed_stat: int):
	speed_stat = max(1, new_speed_stat)
	GlobalVariable.player_speed_stat = speed_stat

func set_vitality(new_vitality: int):
	vitality = max(1, new_vitality)
	GlobalVariable.player_vitality = vitality
	# Update max energy and energy cost based on vitality
	max_energy = 100 + (vitality - 1) * 20  # +20 max energy per vitality point
	energy_cost_per_fish = max(1, 2 - (vitality - 1))  # Reduce energy cost with higher vitality
	# Emit energy changed to update UI
	energy_changed.emit(energy)

func set_luck(new_luck: int):
	luck = max(1, new_luck)
	GlobalVariable.player_luck = luck

func add_fractional_strength(amount: float):
	"""Add fractional strength and convert to full points when >= 1.0"""
	fractional_strength += amount
	GlobalVariable.player_fractional_strength = fractional_strength
	while fractional_strength >= 1.0:
		strength += 1
		fractional_strength -= 1.0
		GlobalVariable.player_fractional_strength = fractional_strength
		print("Strength increased to %d! (%.1f%% progress toward next level)" % [strength, fractional_strength * 100])

func add_fractional_speed(amount: float):
	"""Add fractional speed and convert to full points when >= 1.0"""
	fractional_speed += amount
	GlobalVariable.player_fractional_speed = fractional_speed
	while fractional_speed >= 1.0:
		speed_stat += 1
		fractional_speed -= 1.0
		GlobalVariable.player_fractional_speed = fractional_speed
		print("Speed increased to %d! (%.1f%% progress toward next level)" % [speed_stat, fractional_speed * 100])

func add_fractional_vitality(amount: float):
	"""Add fractional vitality and convert to full points when >= 1.0"""
	fractional_vitality += amount
	GlobalVariable.player_fractional_vitality = fractional_vitality
	while fractional_vitality >= 1.0:
		vitality += 1
		fractional_vitality -= 1.0
		GlobalVariable.player_fractional_vitality = fractional_vitality
		print("Vitality increased to %d! (%.1f%% progress toward next level)" % [vitality, fractional_vitality * 100])

func add_fractional_luck(amount: float):
	"""Add fractional luck and convert to full points when >= 1.0"""
	fractional_luck += amount
	GlobalVariable.player_fractional_luck = fractional_luck
	while fractional_luck >= 1.0:
		luck += 1
		fractional_luck -= 1.0
		GlobalVariable.player_fractional_luck = fractional_luck
		print("Luck increased to %d! (%.1f%% progress toward next level)" % [luck, fractional_luck * 100])

func get_fractional_strength_progress() -> float:
	"""Return progress toward next strength point (0.0 to 1.0)"""
	return fractional_strength

func get_fractional_speed_progress() -> float:
	"""Return progress toward next speed point (0.0 to 1.0)"""
	return fractional_speed

func get_fractional_vitality_progress() -> float:
	"""Return progress toward next vitality point (0.0 to 1.0)"""
	return fractional_vitality

func get_fractional_luck_progress() -> float:
	"""Return progress toward next luck point (0.0 to 1.0)"""
	return fractional_luck

func reduce_energy_for_fish():
	energy -= get_energy_cost()
	if energy <= 0:
		print("Player is exhausted!")

func restore_energy(amount: int):
	energy += amount

# Stat effect getters
func get_pull_strength() -> float:
	"""Return pull strength multiplier based on strength stat"""
	return 1.0 + (strength - 1) * 0.25  # +25% pull strength per strength point

func get_rod_speed_multiplier() -> float:
	"""Return rod animation speed multiplier based on speed stat"""
	return 1.0 + (speed_stat - 1) * 0.15  # +15% rod speed per speed stat point

func get_energy_cost() -> int:
	"""Return actual energy cost based on vitality and energy food effects"""
	var base_cost = max(1, energy_cost_per_fish)
	var food_cost = GlobalVariable.get_energy_cost_modifier()
	return min(base_cost, food_cost)  # Use the lower cost

func get_luck_bonus() -> float:
	"""Return luck bonus for rare fish spawning and special ability resistance"""
	return (luck - 1) * 0.1  # +10% bonus per luck point

# Fish interaction methods based on player stats
func get_fish_catch_difficulty_modifier() -> float:
	"""Return catch difficulty modifier based on strength (easier catch with higher strength)"""
	return 1.0 - (strength - 1) * 0.15  # -15% catch difficulty per strength point

func get_fish_escape_chance_modifier() -> float:
	"""Return fish escape chance modifier based on strength and luck"""
	var strength_modifier = (strength - 1) * 0.1  # -10% escape chance per strength
	var luck_modifier = (luck - 1) * 0.05  # -5% escape chance per luck
	return max(0.1, 1.0 - strength_modifier - luck_modifier)  # Minimum 10% escape chance

func get_fish_ability_resistance() -> float:
	"""Return resistance to fish special abilities based on luck"""
	return (luck - 1) * 0.08  # +8% resistance per luck point

func get_rare_fish_spawn_bonus() -> float:
	"""Return bonus chance for rare fish spawning based on luck"""
	return (luck - 1) * 0.12  # +12% rare fish spawn chance per luck point

func get_fish_slow_effect_on_catch() -> float:
	"""Return fish speed reduction when being caught based on strength"""
	return (strength - 1) * 0.1  # +10% fish slow down per strength when hooked

func _physics_process(_delta):
	var screen_size = get_viewport_rect().size
	
	# Calculate current speed with stat bonuses and potion effects
	var current_speed = speed
	
	# Apply speed stat bonus (affects movement speed slightly)
	current_speed = int(current_speed * (1.0 + (speed_stat - 1) * 0.1))  # +10% movement speed per speed stat
	
	# Apply speed potion effect (legacy and new system)
	var potion_speed_bonus = GlobalVariable.get_player_speed_effect()
	if potion_speed_bonus > 0:
		current_speed = int(current_speed * (1.0 + potion_speed_bonus))
	elif GlobalVariable.has_speed_potion:
		current_speed = int(current_speed * 1.2)  # 20% speed increase (legacy)
	
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
			
