extends Node

@export var enabled:= true

@onready var level: Level= get_parent()


func _ready() -> void:
	if not enabled:
		return
	await get_parent().ready
	
	var mushroom: LevelObjectDefinition= preload("res://objects/resources/mushroom_definition.tres")
	var crosses: LevelObjectDefinition= preload("res://objects/resources/crosses_definition.tres")
	var branch: LevelObjectDefinition= preload("res://objects/resources/branch_definition.tres")
	var deco1: PackedScene= preload("res://decorations/decoration1.tscn")

	level.add_level_object(crosses, 0, false)
	level.add_level_object(branch, 400, true)
	level.add_level_object(mushroom, -300, true)
	level.add_level_object(mushroom, -600, false)
	
	level.add_decoration(deco1, 0, true)
