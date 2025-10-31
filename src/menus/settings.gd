extends CanvasLayer

@export var window_mode: CheckBox

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider

@export var exit_button: BaseButton

var settings_handler

func _ready() -> void:
	exit_button.pressed.connect(func(): SettingsManager.toggle_settings_panel())

	# TODO re-enable when fixed
	return

	settings_handler = get_tree().get_first_node_in_group("SHandler")
	if settings_handler == null:
		push_error("No settings handler found.")
	else:
		_load_toggle(window_mode, "fullscreen")
		_load_audio_sliders()
		_connect_signals()

	if OS.has_feature("web"):
		$Panel/VBoxContainer/Fullscreen.visible = false


func _connect_signals() -> void:
	window_mode.toggled.connect(_on_fullscreen_selected)

	master_slider.value_changed.connect(_on_master_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)


func _on_fullscreen_selected(fullscreen: bool) -> void:
	if settings_handler.has_method("set_window_mode"):
		settings_handler.set_window_mode(fullscreen)


func _load_toggle(toggle: CheckBox, key: String) -> void:
	toggle.button_pressed = settings_handler.get_settings().get(key, false)


func _load_audio_sliders() -> void:
	var audio_sliders = settings_handler.get_all_volumes()
	master_slider.value = audio_sliders["Master"] * 100.0
	sfx_slider.value = audio_sliders["SFX"] * 100.0
	music_slider.value = audio_sliders["Music"] * 100.0


func _on_master_slider_changed(value: float) -> void:
	var new_value = value / 100
	if settings_handler.has_method("set_bus_volume"):
		settings_handler.set_bus_volume("Master", new_value)


func _on_sfx_slider_changed(value: float) -> void:
	var new_value = value / 100
	if settings_handler.has_method("set_bus_volume"):
		settings_handler.set_bus_volume("SFX", new_value)


func _on_music_slider_changed(value: float) -> void:
	var new_value = value / 100
	if settings_handler.has_method("set_bus_volume"):
		settings_handler.set_bus_volume("Music", new_value)
