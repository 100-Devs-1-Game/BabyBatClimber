class_name Level
extends Node2D

@export var width: float = 500.0

@onready var player: CharacterBody2D = $Player

@onready var left_polygon: Polygon2D = %"Left Polygon"
@onready var right_polygon: Polygon2D = %"Right Polygon"

var height: float= 0
var level_objects: Array[LevelObject]
var delta_height: float



func _ready() -> void:
	_init_polygons()
	player.position= Vector2(1920 / 2 + width / 2 - player.width / 2, 1080 / 2)

	var KILL_OBJECT = preload("res://kill_object.tscn")
	var obj: LevelObject= KILL_OBJECT.instantiate()
	obj.position= Vector2(1920 / 2 - width / 2 - 5, 0)
	add_child(obj)
	level_objects.append(obj)

	obj= KILL_OBJECT.instantiate()
	obj.position= Vector2(1920 / 2 + width / 2 + 5, -300)
	add_child(obj)
	level_objects.append(obj)


func _physics_process(delta: float) -> void:
	delta_height= (player.climb_speed + player.y_boost) * delta
	height+= delta_height
	
	for obj in level_objects:
		obj.position.y+= delta_height
	

func _init_polygons():
	left_polygon.polygon=[
		Vector2(0, 0),
		Vector2(1920 / 2 - width / 2, 0),
		Vector2(1920 / 2 - width / 2, 1080),
		Vector2(0, 1080)]
	
	right_polygon.polygon=[
		Vector2(1920 / 2 + width / 2, 0),
		Vector2(1920, 0),
		Vector2(1920, 1080),
		Vector2(1920 / 2 + width / 2,1080)]


func get_left_side()-> float:
	return 1920 / 2 - width / 2


func get_right_side()-> float:
	return 1920 / 2 + width / 2
