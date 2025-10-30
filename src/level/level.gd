class_name Level
extends Node2D

@export var width: float = 500.0
@export var level_side_shader: ShaderMaterial

@onready var player: CharacterBody2D = $Player
@onready var objects_node: Node2D = $Objects
@onready var decorations_node: Node2D = $Decorations
@onready var level_generator: LevelGenerator = $LevelGenerator

var height: float= 0

var delta_height: float


func _ready() -> void:
	level_generator.generate(-2000)


func _physics_process(delta: float) -> void:
	delta_height= player.delta_height
	height+= delta_height
	
	for obj: Node2D in objects_node.get_children() + decorations_node.get_children():
		obj.position.y+= delta_height

	level_side_shader.set_shader_parameter("height", -height / 1468.0)


func add_level_object(definition: LevelObjectDefinition, y: float, right: bool= true):
	var obj: LevelObject= definition.scene.instantiate()
	obj.position.x= get_right_side() if right else get_left_side() 
	obj.position.y= y
	if not right and definition.flip:
		obj.scale.x= -1
	objects_node.add_child(obj)


func add_decoration(scene: PackedScene, y: float, right: bool= true):
	var offset: float= 125
	var obj: Node2D= scene.instantiate()
	obj.position.x= get_right_side() + offset if right else get_left_side() - offset 
	obj.position.y= y
	decorations_node.add_child(obj)


func get_left_side()-> float:
	return 1920 / 2 - width / 2


func get_right_side()-> float:
	return 1920 / 2 + width / 2
