extends Node2D

@onready var save_manager = preload("res://Common/Utils/SaveManager.gd").new()
@onready var clear_confirm_dialog = $ClearDataConfirmDialog
@onready var success_dialog = $SuccessDialog

func _ready():
	# Load game data when starting
	save_manager.load_game()
	
	# Hide dialogs initially
	if clear_confirm_dialog:
		clear_confirm_dialog.hide()
	if success_dialog:
		success_dialog.hide()


func _on_play_button_pressed() -> void:
	print("Play button pressed, saving game...")
	# Save before switching scenes
	save_manager.save_game()
	print("Navigating to LevelSelect scene...")
	get_tree().change_scene_to_file("res://Scenes/LevelSelect/LevelSelect.tscn")


func _on_shop_button_pressed() -> void:
	# Save before switching scenes
	save_manager.save_game()
	get_tree().change_scene_to_file("res://Scenes/Shop/Shop.tscn")


func _on_clear_data_button_pressed() -> void:
	# Show confirmation dialog instead of clearing immediately
	if clear_confirm_dialog:
		clear_confirm_dialog.popup_centered(Vector2i(550, 350))


func _on_confirm_clear_data() -> void:
	# User confirmed - clear all data
	save_manager.clear_data()
	clear_confirm_dialog.hide()
	
	# Show success message
	if success_dialog:
		success_dialog.popup_centered(Vector2i(450, 220))


func _on_cancel_clear_data() -> void:
	# User cancelled - just hide dialog
	clear_confirm_dialog.hide()


func _on_success_ok() -> void:
	# User acknowledged success - hide dialog and reload scene to refresh UI
	success_dialog.hide()
	# Reload the main scene to ensure all UI elements are properly refreshed
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	# Save before quitting
	save_manager.save_game()
	get_tree().quit()
