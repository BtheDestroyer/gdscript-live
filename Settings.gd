extends HFlowContainer

@export var primary_container: Control
@export var settings_button: Button
@export var indentation_option: OptionButton
@export var indentation_size: SpinBox
@export var code_edit: CodeEdit
@export var page_scale: Slider

func _load_settings() -> void:
  pass # TODO

func _save_settings() -> void:
  pass # TODO

func _ready() -> void:
  _load_settings()
  primary_container.visible = settings_button.button_pressed

func _notification(what: int) -> void:
  match what:
    NOTIFICATION_EXIT_TREE, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_CRASH:
      _save_settings()

func _on_settings_pressed() -> void:
  primary_container.visible = settings_button.button_pressed

func _reindent_code_edit() -> void:
  var use_spaces := indentation_option.selected == 1
  var indent_size := indentation_size.value
  code_edit.reindent(use_spaces, indent_size)

func _on_indentation_item_selected(_index: int) -> void:
  _reindent_code_edit()

func _on_indentation_size_value_changed(_value: float) -> void:
  _reindent_code_edit()

func _on_page_scale_drag_ended(_value_changed: bool) -> void:
  set_page_scale(page_scale.value * 0.01)

func set_page_scale(scale: float) -> void:
  ThemeDB.get_project_theme().default_base_scale = scale
