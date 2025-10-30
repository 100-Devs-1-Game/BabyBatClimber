class_name LevelObject
extends Node2D



func spawn(height: float):
	pass


func tick(player: Player, delta: float):
	pass


func get_level()-> Level:
	return get_parent().get_parent()
