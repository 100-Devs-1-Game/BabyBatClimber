extends LevelObject

@onready var area: Area2D = $Area2D


func _physics_process(delta: float) -> void:
	if area.has_overlapping_bodies():
		var player: Player= area.get_overlapping_bodies()[0]
		assert(player)
		
		#player.slip= true
