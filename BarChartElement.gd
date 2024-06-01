class_name BarChartElement extends Control

var bar_chart: BarChart:
  get:
    if not bar_chart:
      bar_chart = get_parent()
    return bar_chart
var item_name: String
var value: float
var _color_rect: ColorRect:
  get:
    if not _color_rect:
      _color_rect =  get_node_or_null(^"ColorRect")
    return _color_rect
var color: Color:
  get:
    return _color_rect.color
  set(value):
    _color_rect.color = value

func get_value_ratio() -> float:
  return value / bar_chart.get_child(0).value

func _get_tooltip(_at_position: Vector2) -> String:
  var decimal_count := 1
  var decimal_determiner := value
  while decimal_determiner < 1.0 and decimal_determiner != 0.0:
    decimal_determiner *= 10.0
    decimal_count += 1
  var format_string := "%%s: %%.%df%%s (%%.2fx)" % [decimal_count]
  var tooltip := format_string % [item_name, value, bar_chart.unit, get_value_ratio()]
  return tooltip

var tween: Tween = null

func _ready() -> void:
  _color_rect.anchor_top = 1.0
  run_tween()
  
func run_tween() -> void:
  if tween != null:
    tween.kill()
  tween = create_tween()
  tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
  var min_value := bar_chart.get_min_value()
  var max_value := bar_chart.get_max_value()
  var final_top := 0.5 if is_equal_approx(min_value, max_value) else remap(value, min_value, max_value, 0.99, 0.01)
  tween.tween_property(_color_rect, ^"anchor_top", final_top, 0.25)
