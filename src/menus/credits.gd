extends CanvasLayer

func _ready() -> void:
	$Panel/Exit.pressed.connect(func(): queue_free())
