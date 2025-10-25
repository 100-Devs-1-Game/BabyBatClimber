extends Area2D



func _on_body_entered(body: Node2D) -> void:
	assert(body is Player)
	var player: Player= body
	player.kill()
