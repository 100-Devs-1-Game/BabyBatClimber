extends CanvasLayer

@export var global_scroll_factor: float= 1.0

@onready var level: Level= get_parent()

var layers: Array[BackgroundLayer]


func _ready() -> void:
	for child in get_children():
		layers.append(child)


func _physics_process(delta: float) -> void:
	for layer in layers:
		layer.position.y+= level.delta_height * layer.scroll_speed * global_scroll_factor
