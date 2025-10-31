extends LevelObject

enum PlayerState { MOVING, IDLE, AIMING, JUMPING, LAUNCHING }

@export var player_move_speed: float= 200.0
@export var player_offsets: Array[int]
@export var aim_height_steps: Array[int]
@export var aim_time_steps: float= 0.25
@export var player_lean_angle: float= 20.0

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var move_target: Marker2D = $"Move Target"
@onready var area: Area2D = $Area2D

#@onready var aim: Polygon2D = $Aim


var state: PlayerState= PlayerState.MOVING
var aim_time: float
var aim_height: float
var current_aim_step: int



func _on_area_2d_body_entered(body: Node2D) -> void:
	assert(body is Player)
	var player: Player= body
	if player.controlling_object != null:
		return
	
	player.take_control(self)
	player.position.y= position.y + player_offsets[0]
	if move_target.global_position.x > player.position.x:
		player.model.scale.x= 1
	else:
		player.model.scale.x= -1
	$"AudioStreamPlayer Leaves".play()


func tick(player: Player, delta: float):
	match state:
		PlayerState.MOVING:
			if not player.animated_sprite.animation == "branch_climb":
				player.animated_sprite.play("branch_climb")

			var dir: int= sign(move_target.global_position.x - player.position.x)
			var prev_pos_x: float= player.position.x
			player.position.x+= dir * player_move_speed * delta
			
			if sign(player.position.x - move_target.global_position.x) != sign(prev_pos_x - move_target.global_position.x):
				player.position.x= move_target.global_position.x
				player.animated_sprite.play("branch_rest")
				state= PlayerState.IDLE

		PlayerState.IDLE:
			player.position.y= position.y + player_offsets[0]
			if Input.is_action_just_pressed("jump"):
				aim_time= 0
				$"AudioStreamPlayer Bend".play()
				state= PlayerState.AIMING
		
		PlayerState.AIMING:
			current_aim_step= clampi(aim_time / aim_time_steps, 0, aim_height_steps.size() - 1)
			sprite.frame= current_aim_step + 1

			if Input.is_action_just_released("jump"):
				var dir:= roundi(Input.get_axis("left", "right"))
				sprite.frame= 0
				if dir != 0:
					area.monitoring= false
					player.side= Player.PlayerSide.RIGHT if dir < 0 else Player.PlayerSide.LEFT
					
					var tween:= get_tree().create_tween()
					tween.tween_property(player, "position:y", position.y + player_offsets[0], 0.1)
					tween.tween_callback(func(): state= PlayerState.JUMPING)
					$"AudioStreamPlayer Boing".play()
					state= PlayerState.LAUNCHING
				else:
					state= PlayerState.IDLE
				return
			
			aim_time+= delta
			aim_height= aim_height_steps[current_aim_step]
			
			player.position.y= position.y + player_offsets[current_aim_step + 1]
			
			var dir:= 0
			
			if Input.is_action_pressed("left"):
				dir= -1
				player.model.scale.x= -1
			elif Input.is_action_pressed("right"):
				dir= 1
				player.model.scale.x= 1
			else:
				player.rotation= 0
				
			#aim.visible= dir != 0
			#if aim.visible:
				#var x: float= get_level().get_right_side() if dir > 0 else get_level().get_left_side()
				#aim.global_position= Vector2(x, global_position.y - aim_height)

		PlayerState.LAUNCHING:
			pass
			
		PlayerState.JUMPING:
			player.rotation= 0
			player.jump()
			player.y_boost*= current_aim_step + 1
			player.relinquish_control(self)

			
