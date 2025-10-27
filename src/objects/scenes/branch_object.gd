extends LevelObject

enum PlayerState { MOVING, IDLE, AIMING }

@export var player_move_speed: float= 200.0
@export var player_offset: float= 50
@export var aim_height_steps: Array[int]
@export var aim_time_steps: float= 0.25

@onready var move_target: Marker2D = $"Move Target"
@onready var aim: Polygon2D = $Aim


var state: PlayerState= PlayerState.MOVING
var aim_time: float
var aim_height: float


func _on_area_2d_body_entered(body: Node2D) -> void:
	assert(body is Player)
	var player: Player= body
	
	player.take_control(self)
	player.position.y= position.y + player_offset


func tick(player: Player, delta: float):
	match state:
		PlayerState.MOVING:
			var dir: int= sign(move_target.position.x - player.position.x)
			var prev_pos_x: float= player.position.x
			player.position.x+= dir * player_move_speed * delta
			
			if sign(player.position.x - move_target.global_position.x) != sign(prev_pos_x - move_target.global_position.x):
				player.position.x= move_target.global_position.x
				state= PlayerState.IDLE
		PlayerState.IDLE:
			if Input.is_action_just_pressed("pull"):
				state= PlayerState.AIMING
				aim_time= 0
		PlayerState.AIMING:
			if Input.is_action_just_released("pull"):
				state= PlayerState.IDLE
				return
			aim_time+= delta
			var step: int= clampi(aim_time / aim_time_steps, 0, aim_height_steps.size() - 1)
			aim_height= aim_height_steps[step]

			var dir:= 0
			
			if Input.is_action_pressed("left"):
				dir= -1
			elif Input.is_action_pressed("right"):
				dir= 1
			
			aim.visible= dir != 0
			if aim.visible:
				var x: float= get_level().get_right_side() if dir > 0 else get_level().get_left_side()
				aim.global_position= Vector2(x, global_position.y - aim_height)
			
