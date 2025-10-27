extends LevelObject

enum PlayerState { MOVING, IDLE, AIMING }

@export var player_move_speed: float= 200.0
@export var player_offset: float= 50

@onready var move_target: Marker2D = $"Move Target"


var state: PlayerState= PlayerState.MOVING


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
