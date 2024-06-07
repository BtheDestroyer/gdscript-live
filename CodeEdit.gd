extends CodeEdit

@export var run_button: Button

func _input(event: InputEvent) -> void:
  if not has_focus():
    return
  if event is InputEventKey:
    if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
      if event.ctrl_pressed:
        run_button.pressed.emit()
        get_viewport().set_input_as_handled()

func reindent(use_spaces: bool, indentation_size: int):
  var old_indent := " ".repeat(indent_size) if indent_use_spaces else "\t"
  var new_indent := " ".repeat(indentation_size) if use_spaces else "\t"
  var new_text := ""
  var offset := 0
  var non_indent_regex := RegEx.create_from_string("^(%s)*(?!%s)(.*)$" % [old_indent, old_indent])
  while offset < text.length():
    var current_line := text.substr(offset, text.find("\n", offset))
    var non_indent_match := non_indent_regex.search(current_line)
    if non_indent_match:
      var old_indentation_count := current_line.count(old_indent, 0, non_indent_match.get_end(1))
      new_text += new_indent.repeat(old_indentation_count) + non_indent_match.get_string(2)
    new_text += "\n"
    offset += current_line.length() + 1
  indent_use_spaces = use_spaces
  indent_size = indentation_size
  text = new_text
