class_name Player
extends CharacterBody2D

enum PlayerSide { NONE, LEFT, RIGHT }
enum State { GETTING_UP, PLAYING, DEAD }

@export var width: float= 30
@export var climb_speed: float= 100
@export var horizontal_speed: float= 300
@export var jump_boost: float= 100.0

@onready var level: Level= get_parent()
@onready var kill_area_detection: Area2D = $"Kill Area Detection"

@onready var model: Node2D = %Model
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animated_sprite_behind: AnimatedSprite2D = %"AnimatedSprite2D Behind"


var side: PlayerSide= PlayerSide.RIGHT:
	set(s):
		side= s
		if side == PlayerSide.NONE:
			return
		animated_sprite.play("climb")
		model.scale.x= 1 if side == PlayerSide.LEFT else -1
		
var state:= State.GETTING_UP
var current_climb_speed: float
var jump_dir: int
var y_boost: float
var delta_height: float
var dead_velocity: Vector2

var controlling_object: LevelObject

var score: int



func _physics_process(delta: float) -> void:
	delta_height= 0

	if handle_states(delta):
		return
	
	if controlling_object:
		controlling_object.tick(self, delta)
		return
	
	if side != PlayerSide.NONE:
		y_boost= 0
		if Input.is_action_just_pressed("jump"):
			jump()
		else:
			if current_climb_speed > 0 and not animated_sprite.is_playing():
				animated_sprite.play("climb")
			elif is_zero_approx(current_climb_speed) and animated_sprite.is_playing():
				animated_sprite.stop()
				
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


func handle_states(delta: float)-> bool:
	match state:
		State.GETTING_UP:
			if not animated_sprite.is_playing():
				var dir:= roundi(Input.get_axis("left", "right"))
				if dir != 0:
					side= PlayerSide.RIGHT if dir < 0 else PlayerSide.LEFT
					jump()
					state= State.PLAYING
			return true
		State.DEAD:
			dead_velocity.x*= 1 - delta
			dead_velocity.y+= 1000 * delta
			position+= dead_velocity * delta
			return true

	return false


func update_climb_speed():
	current_climb_speed= 0
	if Input.is_action_pressed("climb") and can_climb():
		current_climb_speed= climb_speed


func jump():
	if side == PlayerSide.NONE:
		jump_dir= jump_dir * -1
	else:
		jump_dir= 1 if side == PlayerSide.LEFT else -1
	
	model.scale.x*= -1
	animated_sprite.play("jump")
	animated_sprite_behind.hide()
	
	side= PlayerSide.NONE
	y_boost= jump_boost


func kill():
	state= State.DEAD
	collision_layer= 0
	animated_sprite.play("fall")
	var dir: float= -(position.x - 1920 / 2) / (level.width / 2)
	dead_velocity= Vector2(dir * 1000, -100)


func take_control(obj: LevelObject):
	controlling_object= obj


func relinquish_control(obj: LevelObject):
	assert(controlling_object == obj)
	controlling_object= null


func can_climb()-> bool:
	if side == PlayerSide.NONE:
		return false
	if kill_area_detection.has_overlapping_areas():
		return false
	return true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		animated_sprite.play("jump_continued")
