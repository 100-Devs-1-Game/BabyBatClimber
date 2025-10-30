class_name LevelGenerator
extends Node

@export var enabled: bool= true
@export var step_size: float= 50
@export var chance_per_step: float= 15.0
@export var objects: Array[LevelObjectDefinition]
@export var decorations: Array[PackedScene]

@onready var level: Level= get_parent()

var last_height: float
var left_blocked_for: float
var right_blocked_for: float



func _ready() -> void:
	assert(not objects.is_empty())
	reset()


func generate(until_height: float):
	if not enabled:
		return
	
	if abs(until_height - last_height) < 200:
		return

	var new_height: float= spawn_objects(until_height)
	spawn_decorations(until_height)
	last_height= new_height


func spawn_objects(until_height: float)-> float:
	var new_height: float= last_height
	
	var obj: LevelObjectDefinition
	for height in range(last_height, until_height, -50):
		left_blocked_for-= step_size
		right_blocked_for-= step_size
		if left_blocked_for <= 0:
			if chance100(chance_per_step):
				obj= get_random_obj(height)
				level.add_level_object(obj, height, false)
				left_blocked_for= obj.size
		if right_blocked_for <= 0:
			if chance100(chance_per_step):
				obj= get_random_obj(height)
				level.add_level_object(obj, height, true)
				right_blocked_for= obj.size
		
		new_height= height
	
	return new_height


func spawn_decorations(until_height: float):
	for height in range(last_height, until_height, -385):
		if chance100(25):
			level.add_decoration(decorations.pick_random(), height, chance100(50))


func get_random_obj(height: float)-> LevelObjectDefinition:
	while true:
		var obj: LevelObjectDefinition= objects.pick_random()
		if height > obj.min_height:
			continue
		if chance100(obj.spawn_chance):
			return obj
	return null


func reset():
	last_height= 0


func chance100(c: float)-> bool:
	return randf() * 100 < c
