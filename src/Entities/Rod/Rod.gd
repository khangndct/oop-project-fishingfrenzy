class_name Rod

extends Node2D

enum State { IDLE, THROW, PULL, CATCH }

@export var rarity : String
@export var speed : int
@export var power : int
@export var min_length : int
@export var max_length : int
var rod_state := State.IDLE
var fish_ref : Fish = null

func _ready():
	GlobalVariable.rod_ref = self
	GlobalVariable.hook_ref = self.get_node("Hook")

func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	$Hook.position = $Line.points[0]
	match rod_state:
		State.IDLE:
			$Line.points[0].y = $Line.points[1].y + 30
			if Input.is_action_just_pressed("spaceBar"):
				rod_state = State.THROW
		State.THROW:
			$Line.points[0].y += speed
			if to_global($Line.points[0]).y >= screen_size.y:
				rod_state = State.PULL
		State.PULL:
			$Line.points[0].y -= speed
			if abs($Line.points[1].y - $Line.points[0].y) <= 30:
				rod_state = State.IDLE
		State.CATCH:
			$Line.points[0].y += 1
			if Input.is_action_just_pressed("spaceBar"):
				$Line.points[0].y -= power
			if abs($Line.points[1].y - $Line.points[0].y) <= 90:
				GlobalVariable.money += fish_ref.fish_data.get_stat("value")
				if is_instance_valid(fish_ref):
					fish_ref.queue_free()
				fish_ref = null
				GlobalVariable.is_fish_being_caught = false
				rod_state = State.IDLE
			if to_global($Line.points[0]).y >= screen_size.y:
				if is_instance_valid(fish_ref):
					fish_ref.queue_free()
				fish_ref = null
				GlobalVariable.is_fish_being_caught = false
				rod_state = State.PULL
				

func _on_fish_caught(fish: Fish):
	fish_ref = fish
	rod_state = State.CATCH
