class_name Rod

extends Node2D

enum State { IDLE, THROW, PULL, CATCH, COOLDOWN }

@export var rarity : String
@export var speed : int
@export var power : int
@export var min_length : int
@export var max_length : int
@export var cooldown_time : float = 0.5  # Wait time in seconds after catching a fish
var rod_state := State.IDLE
var fish_ref : Fish = null
var cooldown_timer : float = 0.0

func _ready():
	GlobalVariable.rod_ref = self
	GlobalVariable.hook_ref = self.get_node("Hook")

func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	$Hook.position = $Line.points[0]
	
	# Calculate current rod speed with player stats and potion effects
	var current_speed = speed
	if GlobalVariable.player_ref:
		var speed_multiplier = GlobalVariable.player_ref.get_rod_speed_multiplier()
		current_speed = int(speed * speed_multiplier)
		# Apply rod buff potion effects
		var rod_buff_effect = GlobalVariable.get_rod_buff_effect()
		if rod_buff_effect > 0:
			current_speed = int(current_speed * (1.0 + rod_buff_effect))
	
	# Calculate current rod power with player strength and rod buff potion
	var current_power = power
	if GlobalVariable.player_ref:
		var strength_multiplier = GlobalVariable.player_ref.get_pull_strength()
		current_power = int(power * strength_multiplier)
		
		# Apply rod buff potion effects to pull power
		var rod_buff_effect = GlobalVariable.get_rod_buff_effect()
		if rod_buff_effect > 0:
			current_power = int(current_power * (1.0 + rod_buff_effect))
	
	# Handle cooldown timer
	if rod_state == State.COOLDOWN:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			rod_state = State.IDLE
		return
	
	match rod_state:
		State.IDLE:
			$Line.points[0].y = $Line.points[1].y + 30
			if Input.is_action_just_pressed("spaceBar"):
				# Check if player has enough energy to cast
				if GlobalVariable.player_ref and GlobalVariable.player_ref.energy <= 0:
					print("Not enough energy to cast!")
					return
				rod_state = State.THROW
		State.THROW:
			$Line.points[0].y += current_speed
			if to_global($Line.points[0]).y >= screen_size.y:
				rod_state = State.PULL
		State.PULL:
			$Line.points[0].y -= current_speed
			# Prevent hook from going too far above the rod
			var min_y = $Line.points[1].y - 50  # Allow 50 pixels above rod for normal operation
			
			# Check if hook reached the limit
			if $Line.points[0].y <= min_y:
				# Force hook back to normal position and go to idle state
				$Line.points[0].y = $Line.points[1].y + 30
				rod_state = State.IDLE
			elif abs($Line.points[1].y - $Line.points[0].y) <= 30:
				rod_state = State.IDLE
		State.CATCH:
			# Fish struggles less against stronger players but still visible
			var struggle_strength = 1.0
			if fish_ref and fish_ref.fish_data:
				struggle_strength = fish_ref.fish_data.get_catch_difficulty()
				# Apply player strength reduction but keep minimum struggle for visual effect
				if GlobalVariable.player_ref:
					var strength_modifier = GlobalVariable.player_ref.get_fish_catch_difficulty_modifier()
					struggle_strength = struggle_strength * strength_modifier
					struggle_strength = max(0.3, struggle_strength)  # Minimum 30% struggle for visual effect
			
			$Line.points[0].y += int(2 * struggle_strength)  # Increased base struggle for better visual effect
			if Input.is_action_just_pressed("spaceBar"):
				# Check if player has enough energy to pull
				if GlobalVariable.player_ref and GlobalVariable.player_ref.energy <= 0:
					print("Not enough energy to pull!")
					return
				
				var new_y = $Line.points[0].y - current_power
				# Prevent hook from flying too high when pulling during catch
				var min_y = $Line.points[1].y - 200  # Allow 200 pixels above rod during catch
				
				# If the pull would exceed the limit, consider fish caught automatically
				if new_y <= min_y:
					# Very strong pull - fish is caught instantly
					$Line.points[0].y = $Line.points[1].y + 30  # Reset to normal position
					var money_earned = fish_ref.fish_data.get_stat("value")
					GlobalVariable.money += money_earned
					GlobalVariable.current_session_money_earned += money_earned
					# Update energy food counters
					GlobalVariable.on_fish_caught()
					# Track fish for quest system
					GlobalVariable.track_fish_caught(fish_ref.fish_data.rarity)
					# Reduce player energy when fish is caught
					var player = get_parent()  # Rod is child of Player
					if player and player is Player:
						player.reduce_energy_for_fish()
						# Gain strength from caught fish
						_gain_strength_from_fish(player, fish_ref)
					if is_instance_valid(fish_ref):
						fish_ref.queue_free()
					fish_ref = null
					GlobalVariable.is_fish_being_caught = false
					# Start cooldown period after successful catch
					cooldown_timer = cooldown_time
					rod_state = State.COOLDOWN
					return
				else:
					$Line.points[0].y = new_y
			if abs($Line.points[1].y - $Line.points[0].y) <= 90:
				var money_earned = fish_ref.fish_data.get_stat("value")
				GlobalVariable.money += money_earned
				GlobalVariable.current_session_money_earned += money_earned
				# Update energy food counters
				GlobalVariable.on_fish_caught()
				# Track fish for quest system
				GlobalVariable.track_fish_caught(fish_ref.fish_data.rarity)
				# Reduce player energy when fish is caught
				var player = get_parent()  # Rod is child of Player
				if player and player is Player:
					player.reduce_energy_for_fish()
					# Gain strength from caught fish
					_gain_strength_from_fish(player, fish_ref)
				if is_instance_valid(fish_ref):
					fish_ref.queue_free()
				fish_ref = null
				GlobalVariable.is_fish_being_caught = false
				# Start cooldown period after successful catch
				cooldown_timer = cooldown_time
				rod_state = State.COOLDOWN
			if to_global($Line.points[0]).y >= screen_size.y:
				if is_instance_valid(fish_ref):
					fish_ref.queue_free()
				fish_ref = null
				GlobalVariable.is_fish_being_caught = false
				rod_state = State.PULL
				

func _on_fish_caught(fish: Fish):
	fish_ref = fish
	rod_state = State.CATCH

func _gain_strength_from_fish(player: Player, fish: Fish):
	"""Increase player strength based on caught fish strength"""
	if not fish or not fish.fish_data:
		return
	
	var fish_strength = fish.fish_data.get_stat("strength")
	if fish_strength == null:
		return
	
	# Calculate strength gain based on fish rarity:
	# Common (5): 0.5% = 0.005, Uncommon (10): 1.0% = 0.01
	# Rare (15): 1.5% = 0.015, Epic (20): 2.0% = 0.02, Legendary (25): 2.5% = 0.025
	var strength_gain = fish_strength * 0.001  # 0.1% of fish strength
	
	# Add the strength gain as a fractional value
	player.add_fractional_strength(strength_gain)
	
	# Show notification based on fish rarity
	var rarity_name = FishData.Rarity.keys()[fish.fish_data.rarity]
	print("Gained %.3f strength from catching %s %s! (%.1f%% progress)" % [
		strength_gain, 
		rarity_name.to_lower(), 
		fish.fish_data.fish_name,
		player.get_fractional_strength_progress() * 100
	])
