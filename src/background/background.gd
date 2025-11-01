extends CanvasLayer

@export var global_scroll_factor: float= 1.0

@onready var level: Level= get_parent()

var layers: Array[BackgroundLayer]
var prev_camera_y: float



func _ready() -> void:
	for child in get_children():
		if child is BackgroundLayer:
			layers.append(child)
	await level.ready
	prev_camera_y= level.camera.position.y
	

func _physics_process(delta: float) -> void:
	if level.freeze:
		return
	
	var delta_height: float= prev_camera_y - level.camera.position.y
	for layer in layers:
		layer.position.y+= delta_height * layer.scroll_speed * global_scroll_factor
	prev_camera_y= level.camera.position.y


func reset():
	for child in get_children():
		if child is BackgroundLayer:
			child.position.y= child.start_y
	prev_camera_y= level.camera.position.y
