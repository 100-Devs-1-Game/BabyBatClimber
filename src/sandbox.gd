extends Node

@export var enabled:= true

@onready var level: Level= get_parent()


func _ready() -> void:
	if not enabled:
		return
	await get_parent().ready
	
	var mushroom= preload("res://objects/resources/mushroom_definition.tres")
	level.add_level_object(mushroom, 0, false)
	level.add_level_object(mushroom, -300, true)
	level.add_level_object(mushroom, -600, false)
