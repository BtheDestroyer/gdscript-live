extends SplitContainer

@onready var default_horizontal := get_node(".") is HSplitContainer
@export var aspect_ratio_thresholds := Vector2(1.5, 1.0)

func _process(delta: float) -> void:
  var rect := get_viewport_rect()
  var aspect_ratio := rect.size.x / rect.size.y
  if get_node(".") is VSplitContainer:
    var become_hsplit := false
    if default_horizontal:
      become_hsplit = aspect_ratio > aspect_ratio_thresholds.x
    else:
      become_hsplit = aspect_ratio < aspect_ratio_thresholds.y
    if become_hsplit:
      var replacement := HSplitContainer.new()
      replacement.name = name
      replacement.set_script(get_script())
      replace_by(replacement)
      for property in get_property_list():
        replacement.set(property["name"], get(property["name"]))
      replacement.split_offset *= -1
  else: #if get_node(".") is HSplitContainer:
    var become_vsplit := false
    if default_horizontal:
      become_vsplit = aspect_ratio < aspect_ratio_thresholds.y
    else:
      become_vsplit = aspect_ratio > aspect_ratio_thresholds.x
    if become_vsplit:
      var replacement := VSplitContainer.new()
      replacement.name = name
      replacement.set_script(get_script())
      replace_by(replacement)
      for property in get_property_list():
        replacement.set(property["name"], get(property["name"]))
      replacement.split_offset *= -1
