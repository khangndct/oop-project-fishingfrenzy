extends Node

const SAVE_FILE_PATH = "res://save_game.save"

func save_game():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error: Could not open save file for writing")
		return
	
	var save_data = {
		"money": GlobalVariable.money,
		"player_strength": GlobalVariable.player_strength,
		"player_speed_stat": GlobalVariable.player_speed_stat,
		"player_vitality": GlobalVariable.player_vitality,
		"player_luck": GlobalVariable.player_luck,
		"player_energy": GlobalVariable.player_energy,
		"player_fractional_strength": GlobalVariable.player_fractional_strength,
		"player_fractional_speed": GlobalVariable.player_fractional_speed,
		"player_fractional_vitality": GlobalVariable.player_fractional_vitality,
		"player_fractional_luck": GlobalVariable.player_fractional_luck,
		"has_fish_slow_potion_30": GlobalVariable.has_fish_slow_potion_30,
		"has_fish_slow_potion_50": GlobalVariable.has_fish_slow_potion_50,
		"has_fish_slow_potion_70": GlobalVariable.has_fish_slow_potion_70,
		"has_player_speed_potion_20": GlobalVariable.has_player_speed_potion_20,
		"has_player_speed_potion_30": GlobalVariable.has_player_speed_potion_30,
		"has_player_speed_potion_40": GlobalVariable.has_player_speed_potion_40,
		"has_rod_buff_potion_30": GlobalVariable.has_rod_buff_potion_30,
		"has_rod_buff_potion_50": GlobalVariable.has_rod_buff_potion_50,
		"has_rod_buff_potion_70": GlobalVariable.has_rod_buff_potion_70,
		"has_great_fortune_food": GlobalVariable.has_great_fortune_food,
		"has_super_fortune_food": GlobalVariable.has_super_fortune_food,
		"has_ultra_fortune_food": GlobalVariable.has_ultra_fortune_food,
		"has_recovery_energy_food": GlobalVariable.has_recovery_energy_food,
		"has_mighty_energy_food": GlobalVariable.has_mighty_energy_food,
		"has_grand_energy_food": GlobalVariable.has_grand_energy_food,
		"mighty_energy_fish_count": GlobalVariable.mighty_energy_fish_count,
		"grand_energy_fish_count": GlobalVariable.grand_energy_fish_count,
		# Level and Quest System
		"current_level": GlobalVariable.current_level,
		"unlocked_levels": GlobalVariable.unlocked_levels,
		"level_completed": GlobalVariable.level_completed,
		# Legacy support
		"has_slow_potion": GlobalVariable.has_slow_potion,
		"has_speed_potion": GlobalVariable.has_speed_potion
	}
	
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()
	print("Game saved successfully - Money: ", GlobalVariable.money)

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found, using default values")
		return
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		print("Error: Could not open save file for reading")
		return
	
	var save_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(save_string)
	
	if parse_result != OK:
		print("Error: Could not parse save file")
		return
	
	var save_data = json.data
	
	if save_data.has("money"):
		GlobalVariable.money = save_data.money
		print("Money loaded: ", GlobalVariable.money)
	
	# Load player stats
	if save_data.has("player_strength"):
		GlobalVariable.player_strength = save_data.player_strength
	if save_data.has("player_speed_stat"):
		GlobalVariable.player_speed_stat = save_data.player_speed_stat
	if save_data.has("player_vitality"):
		GlobalVariable.player_vitality = save_data.player_vitality
	if save_data.has("player_luck"):
		GlobalVariable.player_luck = save_data.player_luck
	if save_data.has("player_energy"):
		GlobalVariable.player_energy = save_data.player_energy
	
	# Load fractional stats
	if save_data.has("player_fractional_strength"):
		GlobalVariable.player_fractional_strength = save_data.player_fractional_strength
	if save_data.has("player_fractional_speed"):
		GlobalVariable.player_fractional_speed = save_data.player_fractional_speed
	if save_data.has("player_fractional_vitality"):
		GlobalVariable.player_fractional_vitality = save_data.player_fractional_vitality
	if save_data.has("player_fractional_luck"):
		GlobalVariable.player_fractional_luck = save_data.player_fractional_luck
	
	# Load new potion system
	if save_data.has("has_fish_slow_potion_30"):
		GlobalVariable.has_fish_slow_potion_30 = save_data.has_fish_slow_potion_30
	if save_data.has("has_fish_slow_potion_50"):
		GlobalVariable.has_fish_slow_potion_50 = save_data.has_fish_slow_potion_50
	if save_data.has("has_fish_slow_potion_70"):
		GlobalVariable.has_fish_slow_potion_70 = save_data.has_fish_slow_potion_70
	if save_data.has("has_player_speed_potion_20"):
		GlobalVariable.has_player_speed_potion_20 = save_data.has_player_speed_potion_20
	if save_data.has("has_player_speed_potion_30"):
		GlobalVariable.has_player_speed_potion_30 = save_data.has_player_speed_potion_30
	if save_data.has("has_player_speed_potion_40"):
		GlobalVariable.has_player_speed_potion_40 = save_data.has_player_speed_potion_40
	if save_data.has("has_rod_buff_potion_30"):
		GlobalVariable.has_rod_buff_potion_30 = save_data.has_rod_buff_potion_30
	if save_data.has("has_rod_buff_potion_50"):
		GlobalVariable.has_rod_buff_potion_50 = save_data.has_rod_buff_potion_50
	if save_data.has("has_rod_buff_potion_70"):
		GlobalVariable.has_rod_buff_potion_70 = save_data.has_rod_buff_potion_70
	
	# Load food effects
	if save_data.has("has_great_fortune_food"):
		GlobalVariable.has_great_fortune_food = save_data.has_great_fortune_food
	if save_data.has("has_super_fortune_food"):
		GlobalVariable.has_super_fortune_food = save_data.has_super_fortune_food
	if save_data.has("has_ultra_fortune_food"):
		GlobalVariable.has_ultra_fortune_food = save_data.has_ultra_fortune_food
	if save_data.has("has_recovery_energy_food"):
		GlobalVariable.has_recovery_energy_food = save_data.has_recovery_energy_food
	if save_data.has("has_mighty_energy_food"):
		GlobalVariable.has_mighty_energy_food = save_data.has_mighty_energy_food
	if save_data.has("has_grand_energy_food"):
		GlobalVariable.has_grand_energy_food = save_data.has_grand_energy_food
	if save_data.has("mighty_energy_fish_count"):
		GlobalVariable.mighty_energy_fish_count = save_data.mighty_energy_fish_count
	if save_data.has("grand_energy_fish_count"):
		GlobalVariable.grand_energy_fish_count = save_data.grand_energy_fish_count
	
	# Load level and quest system
	if save_data.has("current_level"):
		GlobalVariable.current_level = save_data.current_level
	if save_data.has("unlocked_levels"):
		GlobalVariable.unlocked_levels = save_data.unlocked_levels
	if save_data.has("level_completed"):
		GlobalVariable.level_completed = save_data.level_completed
	else:
		# Initialize level_completed if not in save data
		GlobalVariable.level_completed = {
			GlobalVariable.GameLevel.EASY: false,
			GlobalVariable.GameLevel.NORMAL: false,
			GlobalVariable.GameLevel.HARD: false
		}
	
	# Legacy support
	if save_data.has("has_slow_potion"):
		GlobalVariable.has_slow_potion = save_data.has_slow_potion
	if save_data.has("has_speed_potion"):
		GlobalVariable.has_speed_potion = save_data.has_speed_potion
	
	print("Game loaded successfully - Total money: ", GlobalVariable.money)

func clear_data():
	# Reset all global variables to default values
	GlobalVariable.money = 0
	GlobalVariable.player_strength = 1
	GlobalVariable.player_speed_stat = 1
	GlobalVariable.player_vitality = 1
	GlobalVariable.player_luck = 1
	GlobalVariable.player_energy = 100
	GlobalVariable.player_fractional_strength = 0.0
	GlobalVariable.player_fractional_speed = 0.0
	GlobalVariable.player_fractional_vitality = 0.0
	GlobalVariable.player_fractional_luck = 0.0
	GlobalVariable.has_fish_slow_potion_30 = false
	GlobalVariable.has_fish_slow_potion_50 = false
	GlobalVariable.has_fish_slow_potion_70 = false
	GlobalVariable.has_player_speed_potion_20 = false
	GlobalVariable.has_player_speed_potion_30 = false
	GlobalVariable.has_player_speed_potion_40 = false
	GlobalVariable.has_rod_buff_potion_30 = false
	GlobalVariable.has_rod_buff_potion_50 = false
	GlobalVariable.has_rod_buff_potion_70 = false
	
	# Reset level and quest system
	GlobalVariable.current_level = GlobalVariable.GameLevel.EASY
	GlobalVariable.unlocked_levels = [GlobalVariable.GameLevel.EASY]
	GlobalVariable.level_completed = {
		GlobalVariable.GameLevel.EASY: false,
		GlobalVariable.GameLevel.NORMAL: false,
		GlobalVariable.GameLevel.HARD: false
	}
	
	# Legacy support
	GlobalVariable.has_slow_potion = false
	GlobalVariable.has_speed_potion = false
	
	# Delete save file if it exists
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("Save file deleted successfully")
	
	print("All game data cleared!")
