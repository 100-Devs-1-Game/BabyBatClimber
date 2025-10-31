extends LevelObject


func spawn(height: float):
	position.x= 1920 / 2


func _on_kill_area_body_entered(body: Node2D) -> void:
	$"AudioStreamPlayer Hoot".play()
