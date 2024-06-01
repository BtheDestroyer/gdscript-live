class_name BarChart extends Control

@export var max_label: Label
@export var min_label: Label
@export var placeholder_text: Control
@export var progress_text: Control
@export var minimum_bar_width := 32.0
@export var bar_separation := 32.0
@export var unit := ""

func get_max_value() -> float:
  if get_child_count() == 0:
    return 0.0
  return get_children().map(func(bar): return bar.value).max()

func get_min_value() -> float:
  if get_child_count() == 0:
    return 0.0
  return get_children().map(func(bar): return bar.value).min()

func get_max_value_ratio() -> float:
  if get_child_count() == 0:
    return 0.0
  return get_max_value() / get_child(0).value

func get_min_value_ratio() -> float:
  if get_child_count() == 0:
    return 0.0
  return get_min_value() / get_child(0).value

func _on_child_entered_tree(_node: Node) -> void:
  placeholder_text.hide()
  _update_size()
  _position_children()
  _update_legend()

func _on_child_exiting_tree(_node: Node) -> void:
  if get_child_count() == 1 and not progress_text.visible: # Last child being removed
    placeholder_text.show()
  _update_size()
  _position_children()
  _update_legend()

func _on_child_order_changed() -> void:
  _position_children()

func _update_size() -> void:
  custom_minimum_size.x = get_child_count() * (minimum_bar_width + bar_separation)

func _update_legend() -> void:
  var max_value := get_max_value()
  var min_value := get_min_value()
  var decimal_count := 1
  var decimal_determiner := minf(max_value, min_value)
  while decimal_determiner < 1.0 and decimal_determiner != 0.0:
    decimal_determiner *= 10.0
    decimal_count += 1
  var format_string := "%%.%df%%s" % [decimal_count]
  max_label.text = format_string % [get_max_value(), unit]
  min_label.text = format_string % [get_min_value(), unit]

func _position_children() -> void:
  var start := bar_separation * 0.5
  for child in get_children():
    child.anchor_left = start / custom_minimum_size.x
    child.anchor_right = (start + minimum_bar_width) / custom_minimum_size.x
    start += minimum_bar_width + bar_separation
    child.run_tween()

func add_item(item_name: String, value: float) -> void:
  var element: BarChartElement = preload("res://BarChartElement.tscn").instantiate()
  element.item_name = item_name
  element.value = value
  element.color = Color.from_hsv(randf(), 0.6, 1.0)
  add_child(element)

func _on_run_pressed() -> void:
  for child in get_children():
    child.queue_free()

var profiles_in_progress := {}
func _on_editor_profile_start(callable: Callable, state: Dictionary) -> void:
  placeholder_text.hide()
  _on_editor_profile_progress(callable, state, 0.0)

func _on_editor_profile_progress(callable: Callable, state: Dictionary, completion: float) -> void:
  profiles_in_progress[callable.hash() ^ state.hash()] = completion
  progress_text.show()
  var total_profiles := get_child_count() + profiles_in_progress.size()
  var finished_progress := float(get_child_count()) / float(total_profiles)
  var active_progress: float = profiles_in_progress.values().reduce(func(acc, next): return acc + next / total_profiles, finished_progress)
  progress_text.text = "Progress: %.2f%%" % [active_progress * 100.0]

func _on_editor_profile_complete(callable: Callable, state: Dictionary, average_time: float, _min_time: float, _max_time: float) -> void:
  add_item(callable.get_method(), average_time)
  _on_editor_profile_cancelled(callable, state)

func _on_editor_profile_cancelled(callable: Callable, state: Dictionary) -> void:
  profiles_in_progress.erase(callable.hash() ^ state.hash())
  if profiles_in_progress.size() == 0:
    progress_text.hide()
