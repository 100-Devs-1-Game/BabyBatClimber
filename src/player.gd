class_name Player
extends CharacterBody2D

signal died
signal respawned

enum PlayerSide { NONE, LEFT, RIGHT }
enum State { GETTING_UP, PLAYING, DEAD, FALLING }

@export var width: float= 30
@export var climb_speed: float= 100
@export var horizontal_speed: float= 300
@export var jump_boost: float= 100.0

@onready var level: Level= get_parent()
@onready var kill_area_detection: Area2D = $"Kill Area Detection"

@onready var model: Node2D = %Model
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var area_slip: Area2D = $"Area2D Slip"

@onready var start_y: float= position.y

@onready var audio_climbing: AudioStreamPlayer = $"AudioStreamPlayer Climbing"
@onready var audio_flying: AudioStreamPlayer = $"AudioStreamPlayer Flying"


var side: PlayerSide= PlayerSide.NONE:
	set(s):
		side= s
		if side == PlayerSide.NONE:
			return
		animated_sprite.play("climb")
		model.scale.x= 1 if side == PlayerSide.LEFT else -1
		audio_flying.stop()
		
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
			jump(not Input.is_action_pressed("climb"))
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


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F1:
			kill()


func handle_states(delta: float)-> bool:
	match state:
		State.GETTING_UP:
			if animated_sprite.animation == "stand":
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

		State.FALLING:
			if position.y > start_y:
				position.y= start_y
				animated_sprite.play("get_up")
				collision_layer= 1
				state= State.GETTING_UP
				$"AudioStreamPlayer Landing".play()
				respawned.emit()
				return true
			
			position= Vector2(1920 / 2, position.y + 1000 * delta)
			
	return false


func update_climb_speed():
	current_climb_speed= 0
	audio_climbing.pitch_scale= 1.0

	if Input.is_action_pressed("climb") and can_climb():
		current_climb_speed= climb_speed
		if not audio_climbing.playing:
			audio_climbing.play()
	else:
		audio_climbing.stop()

	if area_slip.has_overlapping_areas():
		current_climb_speed-= 100
		audio_climbing.pitch_scale= 2.0


func jump(straight: bool= false):
	if side == PlayerSide.NONE:
		jump_dir= jump_dir * -1
	else:
		jump_dir= 1 if side == PlayerSide.LEFT else -1
	
	model.scale.x*= -1
	animated_sprite.play("jump")
	
	side= PlayerSide.NONE
	if not straight:
		y_boost= jump_boost

	audio_flying.play()


func kill():
	state= State.DEAD
	collision_layer= 0
	animated_sprite.play("fall")
	var dir: float= -(position.x - 1920 / 2) / (level.width / 2)
	dead_velocity= Vector2(dir * 1000, -100)

	audio_climbing.stop()
	audio_flying.stop()
	$"AudioStreamPlayer Falling".start()
	died.emit()


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
	if animated_sprite.animation == "get_up":
		animated_sprite.play("stand")
	elif animated_sprite.animation == "jump":
		animated_sprite.play("jump_continued")
