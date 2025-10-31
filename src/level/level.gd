class_name Level
extends Node2D

@export var width: float = 500.0
@export var level_side_shader: ShaderMaterial
@export var title_scene: PackedScene

@onready var player: Player = $Player
@onready var objects_node: Node2D = $Objects
@onready var decorations_node: Node2D = $Decorations
@onready var level_generator: LevelGenerator = $LevelGenerator

var height: float= 0
var delta_height: float
var freeze:= false



func _ready() -> void:
	level_generator.generate(-2000)


func _physics_process(delta: float) -> void:
	if freeze:
		return
		
	delta_height= player.delta_height
	height+= delta_height
	
	var score: int= max(0, height / 100)
	if score > Global.highscore:
		Global.highscore= score
	%Score.text= str(score)
	
	for obj: Node2D in objects_node.get_children() + decorations_node.get_children():
		obj.position.y+= delta_height

	level_side_shader.set_shader_parameter("height", -height / 1468.0)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_packed(title_scene)


func add_level_object(definition: LevelObjectDefinition, y: float, right: bool= true):
	var obj: LevelObject= definition.scene.instantiate()
	if definition.has_custom_spawner:
		obj.spawn(y)
	else:
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


func reset():
	for child in objects_node.get_children() + decorations_node.get_children():
		child.queue_free()

	level_generator.reset()
	level_side_shader.set_shader_parameter("height", 0)

	$Background.reset()


func fade(out: bool):
	var tween:= get_tree().create_tween()
	tween.tween_property(%FadeBox, "color:a", 1.0 if out else 0.0, 0.7)


func get_left_side()-> float:
	return 1920 / 2 - width / 2


func get_right_side()-> float:
	return 1920 / 2 + width / 2


func _on_update_level_timeout() -> void:
	level_generator.generate(-height - 2000)


func _on_player_died() -> void:
	freeze= true
	fade(true)
	await get_tree().create_timer(1).timeout
	
	reset()
	height= 0
	_on_update_level_timeout()
	
	player.position.y= 0
	player.state= Player.State.FALLING

	fade(false)
	await player.respawned
	freeze= false
