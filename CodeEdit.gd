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
