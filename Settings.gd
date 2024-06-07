extends HFlowContainer

@export var settings_button: Button
@export var indentation_option: OptionButton
@export var indentation_size: SpinBox
@export var code_edit: CodeEdit

func _ready() -> void:
  pass

func _on_settings_pressed() -> void:
  visible = settings_button.button_pressed

func _reindent_code_edit() -> void:
  var use_spaces := indentation_option.selected == 1
  var indent_size := indentation_size
  code_edit.reindent(use_spaces, indentation_size)

func _on_indentation_item_selected(_index: int) -> void:
  _reindent_code_edit()

func _on_indentation_size_value_changed(_value: float) -> void:
  _reindent_code_edit()
