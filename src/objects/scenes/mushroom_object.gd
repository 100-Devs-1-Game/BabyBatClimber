extends LevelObject


func _on_area_2d_body_entered(body: Node2D) -> void:
	assert(body is Player)
	var player: Player= body
	
	if player.side == Player.PlayerSide.NONE:
		if player.jump_dir == sign(1920 / 2 - position.x):
			return
	
	$"AudioStreamPlayer Boing".play()
	player.jump()
