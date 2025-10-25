class_name Player
extends CharacterBody2D

enum PlayerSide { NONE, LEFT, RIGHT }

@export var width: float= 30
@export var climb_speed: float= 100
@export var horizontal_speed: float= 300
@export var jump_boost: float= 100.0

@onready var level: Level= get_parent()

var side: PlayerSide= PlayerSide.RIGHT
var current_climb_speed: float
var jump_dir: int
var y_boost: float
var delta_height: float



func _physics_process(delta: float) -> void:
	if side != PlayerSide.NONE:
		y_boost= 0
		if Input.is_action_just_pressed("ui_select"):
			jump()
	else:
		var jump_delta: float= jump_dir * horizontal_speed
		position.x+= jump_delta * delta
		
		if jump_dir > 0 and position.x > level.get_right_side():
			side= PlayerSide.RIGHT
		elif jump_dir < 0 and position.x < level.get_left_side():
			side= PlayerSide.LEFT
			
		y_boost= lerp(y_boost, 0.0, delta)

	update_climb_speed()
	
	delta_height= (current_climb_speed + y_boost) * delta


func update_climb_speed():
	current_climb_speed= 0
	if Input.is_action_pressed("ui_up"):
		current_climb_speed= climb_speed


func jump():
	if side == PlayerSide.NONE:
		jump_dir= jump_dir * -1
	else:
		jump_dir= 1 if side == PlayerSide.LEFT else -1
	
	side= PlayerSide.NONE
	y_boost= jump_boost


func kill():
	get_tree().quit()
