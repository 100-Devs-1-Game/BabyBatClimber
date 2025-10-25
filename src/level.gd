class_name Level
extends Node2D

@export var width: float = 500.0
@export var level_side_shader: ShaderMaterial

@onready var player: CharacterBody2D = $Player
@onready var objects_node: Node2D = $Objects

var height: float= 0

var delta_height: float



func _ready() -> void:
	player.position= Vector2(1920 / 2 + width / 2 - player.width / 2, 1080 * 0.8)

	var mushroom= preload("res://objects/resources/mushroom_definition.tres")
	add_level_object(mushroom, 0, false)
	add_level_object(mushroom, -300, true)
	add_level_object(mushroom, -600, false)


func _physics_process(delta: float) -> void:
	delta_height= player.delta_height
	height+= delta_height
	
	for obj: LevelObject in objects_node.get_children():
		obj.position.y+= delta_height

	level_side_shader.set_shader_parameter("height", -height / 1468.0)


func add_level_object(definition: LevelObjectDefinition, y: float, right: bool= true):
	var obj: LevelObject= definition.scene.instantiate()
	obj.position.x= get_right_side() if right else get_left_side() 
	obj.position.y= y
	if not right and definition.flip:
		obj.scale.x= -1
	objects_node.add_child(obj)


func get_left_side()-> float:
	return 1920 / 2 - width / 2


func get_right_side()-> float:
	return 1920 / 2 + width / 2
