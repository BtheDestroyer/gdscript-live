class_name Modal extends Control

@export var close_button: Button

func _ready() -> void:
  close_button.pressed.connect(_on_close_pressed)

func _on_close_pressed() -> void:
  var modals := get_parent() as Modals
  modals.remove_modal(self)
