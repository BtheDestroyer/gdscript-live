extends SpinBox

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton and event.is_pressed() and event.ctrl_pressed:
    match event.button_index:
      MOUSE_BUTTON_WHEEL_UP:
        value = min(value + 10, max_value)
      MOUSE_BUTTON_WHEEL_DOWN:
        value = max(value - 10, min_value)
  elif event is InputEventKey and event.is_pressed() and event.ctrl_pressed:
    match event.keycode:
      KEY_PLUS, KEY_EQUAL:
        value = min(value + 10, max_value)
      KEY_MINUS, KEY_UNDERSCORE:
        value = max(value - 10, min_value)
      KEY_0:
        value = 100
