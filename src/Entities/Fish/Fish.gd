class_name Fish

extends Node2D

enum State { IDLE, MOVE, CATCHED }

@export var fish_data : FishData
var fish_state := State.MOVE
var velocity : Vector2

signal fish_caught(fish: Fish)

func _ready():
	self.fish_caught.connect(GlobalVariable.rod_ref._on_fish_caught)
	if fish_data != null:
		velocity *= fish_data.get_stat("speed")
		if has_node("Sprite2D"):
			$Sprite2D.texture = fish_data.sprite_texture
			$Sprite2D.flip_h = velocity.x < 0

func _physics_process(delta):
	match fish_state:
		State.IDLE:
			pass
		State.MOVE:
			position += velocity
		State.CATCHED:
			position = GlobalVariable.hook_ref.global_position

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("fish deleted")
	queue_free()

func _on_fish_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("hook") and not GlobalVariable.is_fish_being_caught:
		GlobalVariable.is_fish_being_caught = true
		fish_state = State.CATCHED
		fish_caught.emit(self)
