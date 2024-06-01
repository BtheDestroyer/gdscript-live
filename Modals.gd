class_name Modals extends Control

@export var backdrop: ColorRect
var tween: Tween = null
var modal_count := 0

func add_modal_prefab(modal: PackedScene):
  add_modal(modal.instantiate())
  
func add_modal(modal: Modal):
  if modal_count == 0:
    if tween:
      tween.kill()
    show()
    tween = create_tween()
    tween.tween_property(backdrop, ^"color:a", 0.5, 0.25)
    mouse_filter = MOUSE_FILTER_STOP
  add_child(modal)
  var modal_tween_in := modal.create_tween()
  modal.position.y = size.y + modal.size.y
  modal_tween_in.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
  modal_tween_in.tween_property(modal, ^"position:y", (size.y - modal.size.y) * 0.5, 0.25)
  modal_count += 1

func remove_modal(modal: Modal):
  if modal.get_parent() != self:
    push_error("Tried to remove_modal non-modal")
    return
  var modal_tween_out := modal.create_tween()
  modal_tween_out.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
  modal_tween_out.tween_property(modal, ^"position:y", size.y + modal.size.y, 0.25)
  modal_tween_out.tween_callback(func(): modal.queue_free())
  modal_count -= 1
  if modal_count == 0:
    if tween:
      tween.kill()
    tween = create_tween()
    tween.tween_property(backdrop, ^"color:a", 0.0, 0.25)
    tween.tween_callback(hide)
    mouse_filter = MOUSE_FILTER_IGNORE
