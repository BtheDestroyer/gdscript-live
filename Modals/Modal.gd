class_name Modal extends Control

@export var close_button: Button
var active_tween: Tween
var tweening_in := false
var tweening_out := false

func _ready() -> void:
  close_button.pressed.connect(_on_close_pressed)
  close_button.grab_focus()

func _on_close_pressed() -> void:
  var modals := get_parent() as Modals
  modals.remove_modal(self)
