extends HFlowContainer

@export var primary_container: Control
@export var settings_button: Button
@export var indentation_option: OptionButton
@export var indentation_size: Range
@export var code_edit: CodeEdit
@export var page_scale: Range
var _dirty := false

const SETTINGS_PATH := "user://settings.json"
func _load_settings() -> void:
  print("Loading settings...")
  var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
  if file == null:
    push_warning("Couldn't load settings; maybe there are none saved, maybe cookies are disabled")
    return
  var contents := file.get_as_text()
  var data = JSON.parse_string(contents)
  if data == null:
    push_error("Failed to read settings JSON")
    return
  if not data is Dictionary:
    push_error("Read settings JSON was not a dictionary")
    return
  settings_button.button_pressed = data.get("settings_open", settings_button.button_pressed)
  indentation_option.selected = data.get("indentation_type", indentation_option.selected)
  indentation_size.value = data.get("indentation_size", indentation_size.value)
  page_scale.value = data.get("page_scale", page_scale.value)
  _dirty = false

func _save_settings() -> void:
  print("Saving settings...")
  var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
  if file == null:
    push_warning("Couldn't load settings; maybe there are none saved, maybe cookies are disabled")
    return
  file.store_string(JSON.stringify({
    "settings_open": settings_button.button_pressed,
    "indentation_type": indentation_option.selected,
    "indentation_size": indentation_size.value,
    "page_scale": page_scale.value
  }))
  _dirty = false

func _ready() -> void:
  _load_settings()
  _on_settings_pressed()
  _on_page_scale_value_changed(false)
  _dirty = false

func _on_settings_pressed() -> void:
  primary_container.visible = settings_button.button_pressed
  _dirty = true

func _reindent_code_edit() -> void:
  var use_spaces := indentation_option.selected == 1
  var indent_size := indentation_size.value
  code_edit.reindent(use_spaces, indent_size)

func _on_indentation_item_selected(_index: int) -> void:
  _reindent_code_edit()
  _dirty = true

func _on_indentation_size_value_changed(_value: float) -> void:
  _reindent_code_edit()
  _dirty = true

func _on_page_scale_value_changed(_value: float) -> void:
  set_page_scale(page_scale.value * 0.01)
  _dirty = true

func set_page_scale(scale: float) -> void:
  get_tree().get_root().content_scale_factor = scale
  page_scale.tooltip_text = "Page Scale: %.0f%%" % [scale * 100]

func _on_save_timer_timeout() -> void:
  if _dirty:
    _save_settings()
