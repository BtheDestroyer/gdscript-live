extends PanelContainer

var label: Label:
  get:
    if not label:
      label = get_node_or_null(^"MarginContainer/ProgressText")
    return label
var text: String:
  get:
    return label.text
  set(value):
    label.text = value
