extends Node

@export var generator_enabled:= false
@export var skip_getting_up: bool= true

@onready var level: Level= get_parent()


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	await get_parent().ready

	if skip_getting_up:
		level.player.side= Player.PlayerSide.RIGHT
		level.player.jump()
		level.player.state= Player.State.PLAYING

	if not generator_enabled:
		return

	
	var mushroom: LevelObjectDefinition= preload("res://objects/resources/mushroom_definition.tres")
	var crosses: LevelObjectDefinition= preload("res://objects/resources/crosses_definition.tres")
	var branch: LevelObjectDefinition= preload("res://objects/resources/branch_definition.tres")
	var deco1: PackedScene= preload("res://decorations/decoration1.tscn")

	#level.add_level_object(crosses, 0, false)
	level.add_level_object(branch, 0, false)
	level.add_level_object(branch, 400, true)
	level.add_level_object(mushroom, -300, true)
	level.add_level_object(mushroom, -600, false)
	
	level.add_decoration(deco1, 0, true)
