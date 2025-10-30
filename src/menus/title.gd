extends Node2D

@export var start_button: BaseButton
@export var settings_button: BaseButton
@export var credits_button: BaseButton
@export var change_button: BaseButton

@export var score: Label

func _ready() -> void:
	_set_highscore()
	start_button.mouse_entered.connect(func(): $Menu/Build/startreg.visible = false)
	start_button.mouse_exited.connect(func(): $Menu/Build/startreg.visible = true)

	settings_button.mouse_entered.connect(func(): $Menu/Build/settingsreg.visible = false)
	settings_button.mouse_exited.connect(func(): $Menu/Build/settingsreg.visible = true)

	credits_button.mouse_entered.connect(func(): $Menu/Build/credreg.visible = false)
	credits_button.mouse_exited.connect(func(): $Menu/Build/credreg.visible = true)

	change_button.mouse_entered.connect(func(): $Menu/Build/coffhov.visible = true ; $Menu/Build/coffreg.visible = false)
	change_button.mouse_exited.connect(func(): $Menu/Build/coffhov.visible = false ; $Menu/Build/coffreg.visible = true)

const CREDITS = preload("res://menus/credits.tscn")

func _set_highscore() -> void:
	await get_tree().process_frame
	score.text = str(Global.highscore)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_settings_pressed() -> void:
	SettingsManager.toggle_settings_panel()


func _on_credits_pressed() -> void:
	var cred = CREDITS.instantiate()
	get_tree().root.add_child(cred)

func _on_change_pressed() -> void:
	pass # Replace with function body.
