class_name Fish

extends Node2D

enum State { IDLE, MOVE, CATCHED }

@export var fish_data : FishData
var fish_state := State.MOVE
var velocity : Vector2

# Special ability system
var ability_timer: Timer
var ability_cooldown_timer: Timer
var is_ability_active: bool = false
var is_ability_on_cooldown: bool = false

# Movement pattern system
var movement_timer: float = 0.0
var base_velocity: Vector2

# UI notification system
var notification_label: Label
var notification_timer: Timer

signal fish_caught(fish: Fish)

func _ready():
	self.fish_caught.connect(GlobalVariable.rod_ref._on_fish_caught)
	if fish_data != null:
		# Use the new effective speed method that includes behavior strategy
		velocity *= fish_data.get_effective_speed()
		base_velocity = velocity  # Store original velocity for movement patterns
		if has_node("Sprite2D"):
			$Sprite2D.texture = fish_data.sprite_texture
			$Sprite2D.flip_h = velocity.x < 0
		
		# Setup special ability system
		_setup_special_abilities()
		
		# Setup UI notification system
		_setup_notification_ui()
		
		# Log fish information with new methods
		print("🐟 Fish ready: ", fish_data.fish_name)
		print("   Rarity: ", fish_data.rarity, " (", typeof(fish_data.rarity), ")")
		print("   Movement pattern: ", fish_data.get_movement_pattern())
		print("   Has special ability: ", fish_data.has_special_ability())
		if fish_data.has_special_ability():
			print("   Special ability: ", fish_data.get_special_ability())
			print("   Ability cooldown: ", fish_data.get_ability_cooldown(), "s")
			print("   Ability duration: ", fish_data.get_ability_duration(), "s")
		print("   Catch difficulty: ", fish_data.get_catch_difficulty())
		
		# Removed spawn notification - only show when caught

func _setup_special_abilities():
	if not fish_data.has_special_ability():
		print("❌ Fish ", fish_data.fish_name, " has no special ability")
		return
	
	print("⚙️ Setting up special abilities for ", fish_data.fish_name)
	
	# Create ability duration timer
	ability_timer = Timer.new()
	ability_timer.wait_time = fish_data.get_ability_duration()
	ability_timer.one_shot = true
	ability_timer.timeout.connect(_on_ability_ended)
	add_child(ability_timer)
	
	# Create ability cooldown timer
	ability_cooldown_timer = Timer.new()
	ability_cooldown_timer.wait_time = fish_data.get_ability_cooldown()
	ability_cooldown_timer.one_shot = true
	ability_cooldown_timer.timeout.connect(_on_ability_cooldown_ended)
	add_child(ability_cooldown_timer)
	
	# Start the initial cooldown period (fish spawns with ability ready after brief delay)
	ability_cooldown_timer.wait_time = 1.0  # 1 second initial delay
	ability_cooldown_timer.start()
	is_ability_on_cooldown = true
	print("⏳ Initial cooldown started for ", fish_data.fish_name, " (1 second)")

func _setup_notification_ui():
	# Create notification label for displaying fish actions
	notification_label = Label.new()
	notification_label.add_theme_font_size_override("font_size", 8)
	notification_label.add_theme_color_override("font_color", Color.WHITE)
	notification_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	notification_label.add_theme_constant_override("shadow_offset_x", 1)
	notification_label.add_theme_constant_override("shadow_offset_y", 1)
	
	# Create a background panel for better visibility
	var panel = Panel.new()
	panel.add_theme_color_override("bg_color", Color(0, 0, 0, 0.7))  # Semi-transparent black
	panel.size = Vector2(80, 20)  # Larger size for fish name + rarity
	panel.position = Vector2(-40, -30)  # Position above the fish
	panel.visible = false
	
	# Setup label properties
	notification_label.text = ""
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.size = Vector2(80, 20)  # Match panel size
	notification_label.position = Vector2(-40, -30)  # Match panel position
	notification_label.visible = false
	
	# Add panel first, then label on top
	add_child(panel)
	add_child(notification_label)
	
	# Store reference to panel for cleanup
	notification_label.set_meta("panel", panel)
	
	# Create timer for auto-hiding notifications
	notification_timer = Timer.new()
	notification_timer.wait_time = 2.0  # Show for 2 seconds
	notification_timer.one_shot = true
	notification_timer.timeout.connect(_on_notification_timeout)
	add_child(notification_timer)

func _show_fish_notification(message: String, color: Color = Color.WHITE):
	"""Display a notification message above the fish with custom styling"""
	if not notification_label:
		return
	
	# Set the message and color
	notification_label.text = message
	notification_label.add_theme_color_override("font_color", color)
	
	# Get the panel for background color
	var panel = notification_label.get_meta("panel", null)
	
	# Only show panel for ability-related notifications
	var show_panel = false
	if panel:
		# Change background color based on message type
		var bg_color = Color(0, 0, 0, 0.8)  # Default dark background
		
		if "DASH" in message or "⚡" in message:
			bg_color = Color(1, 1, 0, 0.6)  # Yellow for dash
			show_panel = true
		elif "INVISIBILITY" in message or "👻" in message:
			bg_color = Color(0.5, 0, 1, 0.6)  # Purple for invisibility
			show_panel = true
		elif "ESCAPED" in message or "💨" in message:
			bg_color = Color(1, 0.5, 0, 0.6)  # Orange for escape
			show_panel = true
		elif "ended" in message or "⏰" in message:
			bg_color = Color(0.5, 0.5, 0.5, 0.6)  # Gray for ability ended
			show_panel = true
		else:
			show_panel = false
		# No panel for any other notifications (caught, ready, etc.)
		
		panel.add_theme_color_override("bg_color", bg_color)
		panel.visible = show_panel
	
	# Always show the notification label
	notification_label.visible = true
	
	# Set timer duration based on message type
	var display_time = 2.0  # Default 2 seconds
	if "CAUGHT" in message:
		display_time = 3.0  # Show catch notifications longer (3 seconds)
	
	notification_timer.wait_time = display_time
	notification_timer.start()

func _on_notification_timeout():
	"""Hide the notification after timeout"""
	if notification_label and is_instance_valid(notification_label):
		notification_label.visible = false
		var panel = notification_label.get_meta("panel", null)
		if panel and is_instance_valid(panel):
			panel.visible = false

func _physics_process(delta):
	# Early exit if fish_data is invalid
	if not fish_data or not is_instance_valid(fish_data):
		return
		
	movement_timer += delta
	
	match fish_state:
		State.IDLE:
			pass
		State.MOVE:
			# Apply movement pattern
			_apply_movement_pattern(delta)
			
			# Apply slow potion effect
			var current_velocity = velocity
			if GlobalVariable.has_slow_potion:
				current_velocity = velocity * 0.1  # 90% speed reduction (10% of original speed)
			
			# Apply new potion system slow effects
			var fish_slow_effect = GlobalVariable.get_fish_slow_effect()
			if fish_slow_effect > 0:
				current_velocity = velocity * (1.0 - fish_slow_effect)
			
			position += current_velocity
			
			# Keep fish within screen boundaries
			_clamp_to_screen_bounds()
			
			# Check if fish should use special ability
			_check_special_ability_usage()
		State.CATCHED:
			# Apply player strength effect on caught fish movement
			# Fish struggles less when player has higher strength
			var struggle_reduction = 1.0
			if GlobalVariable.player_ref:
				struggle_reduction = 1.0 - GlobalVariable.player_ref.get_fish_slow_effect_on_catch()
				struggle_reduction = max(0.3, struggle_reduction)  # Fish still struggle at least 30% for visual effect
			
			# Fish struggles less when player has higher strength but still visible
			var struggle_offset = Vector2(
				randf_range(-3.0, 3.0) * struggle_reduction,
				randf_range(-3.0, 3.0) * struggle_reduction
			)
			position = GlobalVariable.hook_ref.global_position + struggle_offset

func _apply_movement_pattern(_delta):
	if not fish_data or not is_instance_valid(fish_data):
		return
	
	var pattern = fish_data.get_movement_pattern()
	var speed = base_velocity.length()
	var direction = base_velocity.normalized()
	
	# Check if fish is near vertical boundaries only (allow horizontal exit)
	var screen_size = get_viewport_rect().size
	var margin = 80.0
	var near_vertical_boundary = (position.y < margin or position.y > screen_size.y - margin)
	
	if near_vertical_boundary:
		# Only steer away from top/bottom boundaries
		var center_y = screen_size.y * 0.5
		var to_center_y = (center_y - position.y) / abs(center_y - position.y) if center_y != position.y else 0
		
		# Adjust Y direction to avoid top/bottom boundaries
		if position.y < margin:
			direction.y = lerp(direction.y, abs(direction.y), 0.2)  # Steer downward
		elif position.y > screen_size.y - margin:
			direction.y = lerp(direction.y, -abs(direction.y), 0.2)  # Steer upward
	
	match pattern:
		"straight":
			# Keep original velocity with boundary awareness
			velocity = direction * speed
		
		"slight_wave":
			# Gentle sine wave movement
			var wave_offset = sin(movement_timer * 2.0) * 0.3
			velocity = Vector2(direction.x * speed, direction.y * speed + wave_offset * 20)
		
		"zigzag":
			# Sharp zigzag pattern
			var zigzag = sin(movement_timer * 4.0)
			if abs(zigzag) > 0.7:  # Create sharp turns
				velocity.y = direction.y * speed + sign(zigzag) * speed * 0.5
			else:
				velocity.y = direction.y * speed
			velocity.x = direction.x * speed
		
		"circular":
			# Circular/spiral movement
			var angle = movement_timer * 3.0
			var radius = 30.0
			velocity = Vector2(
				direction.x * speed + cos(angle) * radius * 0.1,
				direction.y * speed + sin(angle) * radius * 0.1
			)
		
		"teleport":
			# Occasional instant position change (handled in special ability)
			# Also handle random teleportation for legendary fish movement
			if randf() < 0.001:  # Very rare random teleport (0.1% chance per frame)
				_perform_safe_teleport()
			velocity = direction * speed  # Use boundary-aware direction

func _clamp_to_screen_bounds():
	"""Keep fish within screen boundaries and adjust velocity if hitting edges"""
	var screen_size = get_viewport_rect().size
	var margin = 50.0  # Keep fish at least 50 pixels from screen edge
	
	var sprite_size = Vector2(32, 32)  # Default fish size
	if has_node("Sprite2D") and $Sprite2D.texture:
		sprite_size = $Sprite2D.texture.get_size()
	
	var half_sprite = sprite_size * 0.5
	var min_bounds = Vector2(margin + half_sprite.x, margin + half_sprite.y)
	var max_bounds = Vector2(screen_size.x - margin - half_sprite.x, screen_size.y - margin - half_sprite.y)
	
	var was_clamped = false
	var new_position = position
	
	# Only clamp Y position (top and bottom) - allow fish to exit left and right
	# Fish should be able to go off-screen horizontally to be deleted naturally
	if position.y < min_bounds.y:
		new_position.y = min_bounds.y
		was_clamped = true
	elif position.y > max_bounds.y:
		new_position.y = max_bounds.y
		was_clamped = true
	
	position = new_position
	
	# Bounce or redirect velocity if fish hit boundaries
	if was_clamped:
		_handle_boundary_collision()

func _handle_boundary_collision():
	"""Handle fish behavior when hitting screen boundaries (only top/bottom)"""
	var screen_size = get_viewport_rect().size
	var margin = 50.0
	
	print("🔄 ", fish_data.fish_name, " hit vertical boundary at position: ", position)
	
	# Only handle vertical bouncing - fish can exit horizontally
	if position.y <= margin or position.y >= screen_size.y - margin:
		velocity.y = -velocity.y  # Bounce vertically
		print("   Bouncing vertically")
	
	# Add some randomness to prevent repetitive bouncing
	var random_factor = 0.8 + randf() * 0.4  # 0.8 to 1.2 multiplier
	velocity *= random_factor
	
	# Gentle steering away from top/bottom boundaries
	var center_y = screen_size.y * 0.5
	if position.y <= margin:
		# Near top, steer slightly downward
		velocity.y = abs(velocity.y)  # Ensure downward direction
	elif position.y >= screen_size.y - margin:
		# Near bottom, steer slightly upward
		velocity.y = -abs(velocity.y)  # Ensure upward direction

func _get_safe_teleport_position() -> Vector2:
	"""Get a safe position for teleportation that's within screen bounds"""
	var screen_size = get_viewport_rect().size
	var margin = 100.0  # Larger margin for teleportation
	
	var safe_x = randf_range(margin, screen_size.x - margin)
	var safe_y = randf_range(margin, screen_size.y - margin)
	
	return Vector2(safe_x, safe_y)

func _perform_safe_teleport():
	"""Teleport fish to a safe position within screen bounds"""
	var old_pos = position
	var new_pos = _get_safe_teleport_position()
	position = new_pos
	
	print("✨ ", fish_data.fish_name, " teleported from ", old_pos, " to ", new_pos)
	
	# Show a brief teleport effect
	_show_fish_notification("✨ TELEPORT!", Color.CYAN)

func _check_special_ability_usage():
	# Early null check to prevent errors
	if not fish_data or not is_instance_valid(fish_data):
		return
		
	if not fish_data.has_special_ability():
		# Only print this occasionally to avoid spam
		if randf() < 0.001:  # Very rare debug message
			print("🚫 ", fish_data.fish_name, " (rarity: ", fish_data.rarity, ") has no special ability")
		return
		
	if is_ability_active or is_ability_on_cooldown:
		if randf() < 0.01:  # Occasional debug message
			print("⏳ ", fish_data.fish_name, " ability blocked - Active: ", is_ability_active, " Cooldown: ", is_ability_on_cooldown)
		return
	
	print("🎯 ", fish_data.fish_name, " ready to use ability: ", fish_data.get_special_ability())
	
	# Calculate ability activation chance based on player stats
	var base_chance = 0.05  # 5% base chance per frame
	var player_resistance = 0.0
	
	# Apply player's luck-based resistance to fish abilities
	if GlobalVariable.player_ref:
		player_resistance = GlobalVariable.player_ref.get_fish_ability_resistance()
		print("🛡️ Player resistance to fish abilities: ", player_resistance * 100, "%")
	
	var final_chance = base_chance * (1.0 - player_resistance)
	final_chance = max(0.01, final_chance)  # Minimum 1% chance
	
	# Reasonable chance to activate ability with player resistance factor
	if randf() < final_chance:
		_activate_special_ability()

func _activate_special_ability():
	# Enhanced null checking
	if not fish_data or not is_instance_valid(fish_data):
		print("⚠️ Cannot activate ability: fish_data is null or invalid")
		return
		
	if is_ability_active or is_ability_on_cooldown:
		return
	
	var ability_name = fish_data.get_special_ability()
	print("🔥 ", fish_data.fish_name, " activating special ability: ", ability_name)
	
	# Show notification based on ability type
	match ability_name:
		"dash":
			_show_fish_notification("⚡ DASH!", Color.YELLOW)
		"invisibility":
			_show_fish_notification("👻 INVISIBLE!", Color.MAGENTA)
		_:
			_show_fish_notification("🔮 " + ability_name.to_upper() + "!", Color.CYAN)
	
	# Apply the ability effect
	fish_data.apply_special_ability(self)
	
	# Set ability state
	is_ability_active = true
	
	# Start ability duration timer
	if ability_timer:
		ability_timer.start()

func _on_ability_ended():
	if not fish_data:
		return
	
	var ability_name = fish_data.get_special_ability()
	print("⏰ ", fish_data.fish_name, " special ability ended")
	
	# Show ability ended notification
	_show_fish_notification("⏰ " + ability_name + " ended", Color.GRAY)
	
	# Remove ability effects
	fish_data.remove_special_ability(self)
	
	# Set cooldown
	is_ability_active = false
	is_ability_on_cooldown = true
	
	# Start cooldown timer
	if ability_cooldown_timer:
		ability_cooldown_timer.wait_time = fish_data.get_ability_cooldown()
		ability_cooldown_timer.start()

func _on_ability_cooldown_ended():
	is_ability_on_cooldown = false
	if fish_data:
		print("✅ ", fish_data.fish_name, " special ability ready!")
		_show_fish_notification("✅ Ready!", Color.GREEN)
	else:
		print("⚠️ Cooldown ended but fish_data is null")

# Public method to force ability activation (for testing or special events)
func force_activate_ability():
	if fish_data and fish_data.has_special_ability() and not is_ability_active:
		is_ability_on_cooldown = false  # Override cooldown
		_activate_special_ability()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("fish deleted: ", fish_data.fish_name if fish_data else "unknown fish")
	_cleanup_special_abilities()
	queue_free()

func _exit_tree():
	# Additional cleanup when fish is removed from scene tree
	_cleanup_special_abilities()

func _cleanup_special_abilities():
	# Prevent double cleanup
	if not notification_label:
		return
	
	# Clean up ability effects if fish is removed while ability is active
	if is_ability_active and fish_data:
		fish_data.remove_special_ability(self)
	
	# Clean up timers
	if ability_timer and is_instance_valid(ability_timer):
		ability_timer.queue_free()
		ability_timer = null
	if ability_cooldown_timer and is_instance_valid(ability_cooldown_timer):
		ability_cooldown_timer.queue_free()
		ability_cooldown_timer = null
	if notification_timer and is_instance_valid(notification_timer):
		notification_timer.queue_free()
		notification_timer = null
	
	# Clean up UI elements
	if notification_label and is_instance_valid(notification_label):
		var panel = notification_label.get_meta("panel", null)
		if panel and is_instance_valid(panel):
			panel.queue_free()
		notification_label.queue_free()
		notification_label = null

func _on_fish_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("hook") and not GlobalVariable.is_fish_being_caught:
		# Check if fish can escape due to special ability
		if _can_escape_due_to_ability():
			print("💨 ", fish_data.fish_name, " escapes using special ability!")
			_show_fish_notification("💨 ESCAPED!", Color.ORANGE)
			_escape_with_ability()
			return
		
		GlobalVariable.is_fish_being_caught = true
		fish_state = State.CATCHED
		
		# Show caught notification in the UI on the right side of screen
		GlobalVariable.show_caught_fish(fish_data.fish_name, fish_data.rarity)
	
		fish_caught.emit(self)

func _can_escape_due_to_ability() -> bool:
	if not fish_data or not is_instance_valid(fish_data) or not fish_data.has_special_ability():
		return false
	
	# Base escape chances
	var base_escape_chance = 0.0
	if fish_data.get_special_ability() == "invisibility" and is_ability_active:
		base_escape_chance = 0.3  # 30% base chance for legendary fish
	elif fish_data.get_special_ability() == "dash" and is_ability_active:
		base_escape_chance = 0.15  # 15% base chance for epic fish
	
	if base_escape_chance == 0.0:
		return false
	
	# Apply player's stat-based resistance
	var player_escape_modifier = 1.0
	if GlobalVariable.player_ref:
		player_escape_modifier = GlobalVariable.player_ref.get_fish_escape_chance_modifier()
		print("🎣 Player escape modifier: ", player_escape_modifier, " (lower is better)")
	
	var final_escape_chance = base_escape_chance * player_escape_modifier
	final_escape_chance = max(0.05, final_escape_chance)  # Minimum 5% escape chance
	
	print("🏃 ", fish_data.fish_name, " escape chance: ", final_escape_chance * 100, "%")
	return randf() < final_escape_chance

func _escape_with_ability():
	# Trigger special ability as escape mechanism
	if not is_ability_active and not is_ability_on_cooldown:
		_activate_special_ability()
	
	# Move fish away from hook quickly - allow horizontal escape
	var escape_direction = (position - GlobalVariable.hook_ref.global_position).normalized()
	var escape_speed = fish_data.get_effective_speed() * 2.0
	
	# Only check if escape would go out of vertical bounds (allow horizontal exit)
	var screen_size = get_viewport_rect().size
	var margin = 100.0
	var projected_position = position + escape_direction * 100  # Project 100 pixels ahead
	
	# Only redirect if escape would go out of vertical bounds (top/bottom)
	if (projected_position.y < margin or projected_position.y > screen_size.y - margin):
		# Keep horizontal escape but adjust vertical direction
		var center_y = screen_size.y * 0.5
		var safe_y_direction = (center_y - position.y) / abs(center_y - position.y) if center_y != position.y else 0
		escape_direction.y = safe_y_direction * 0.5  # Moderate vertical adjustment
		escape_direction = escape_direction.normalized()
	
	velocity = escape_direction * escape_speed
