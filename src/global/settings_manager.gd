extends Node

var fullscreen: bool = false
var settings_opened: bool = false

var settings_panel

var volumes: Dictionary = {
	"Master": 0.5,
	"SFX": 0.5,
	"Music": 0.5,
}

const CFG: String = "user://settings.cfg"
const SEC_VIDEO: String = "Video"
const SEC_AUDIO: String = "Audio"
const SEC_GAME: String = "Game"
const SETTINGS = preload("res://menus/settings.tscn")

func _ready() -> void:
	# TODO re-enable when fixed
	return
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("SHandler")

	_load_settings()

	for bus_name in volumes.keys():
		_apply_bus_volume(bus_name, volumes[bus_name])


func set_window_mode(state: bool) -> void:
	fullscreen = state
	if fullscreen:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	_save_settings()


func set_bus_volume(bus: String, linear_value: float) -> void:
	var new_value = clamp(linear_value, 0.0, 1.0)
	if volumes[bus] != new_value:
		volumes[bus] = new_value
		_apply_bus_volume(bus, new_value)
		_save_settings()


func _apply_bus_volume(bus: String, linear: float) -> void:
	var index = AudioServer.get_bus_index(bus)
	if index == -1:
		push_error("Audio bus '%s' not found." % bus)
		return

	if linear <= 0.0001:
		AudioServer.set_bus_volume_db(index, -80.0)
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_volume_db(index, linear_to_db(linear))
		AudioServer.set_bus_mute(index, false)


func get_bus_volume(bus: String) -> float:
	return volumes.get(bus, 1.0)


func get_all_volumes() -> Dictionary:
	return volumes.duplicate()


func _save_settings() -> void:
	var c = ConfigFile.new()
	c.set_value(SEC_VIDEO, "fullscreen", fullscreen)
	c.set_value(SEC_GAME, "score", Global.highscore)
	for bus in volumes.keys():
		c.set_value(SEC_AUDIO, bus, volumes[bus])

	if not FileAccess.file_exists(CFG):
		var f = FileAccess.open(CFG, FileAccess.WRITE)
		if f:
			f.close()

	var err = c.save(CFG)
	if err != OK:
		push_error("Failed to save settings: %d" % err)


func _load_settings() -> void:
	var c = ConfigFile.new()
	if c.load(CFG) != OK:
		return

	fullscreen = bool(c.get_value(SEC_VIDEO, "fullscreen", fullscreen))
	Global.highscore = int(c.get_value(SEC_GAME, "score", Global.highscore))

	for bus in ["Master", "SFX", "Music"]:
		if c.has_section_key(SEC_AUDIO, bus):
			volumes[bus] = clamp(float(c.get_value(SEC_AUDIO, bus, 1.0)), 0.0, 1.0)


func toggle_settings_panel() -> void:
	if not settings_opened:
		if settings_panel == null:
			settings_panel = SETTINGS.instantiate()
			get_tree().root.add_child(settings_panel)
			settings_opened = true
	else:
		if settings_panel != null:
			settings_panel.queue_free()
			settings_opened = false


func get_settings() -> Dictionary:
	return {
		"fullscreen": fullscreen,
		"volumes": get_all_volumes(),
	}


func close_game() -> void:
	_save_settings()
	get_tree().quit()
