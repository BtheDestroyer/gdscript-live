extends Control

@export var code_edit: CodeEdit
@export var entrypoint_field: LineEdit
@export var output_label: RichTextLabel
@export var modals: Modals
@onready var bootstrap_header := r"""
var GDScriptLive = instance_from_id(%d)
""" % [get_instance_id()]

func _build_code_highlighter_colors() -> void:
  var highlighter: CodeHighlighter = load("res://CodeHighlighter.tres")
  highlighter.clear_keyword_colors()
  highlighter.clear_color_regions()
  const CONTROL_FLOW_KEYWORD := Color("ff8ccc")
  for k in ["if", "else", "elif", "for", "while", "match", "break", "continue", "pass", "return"]:
    highlighter.add_keyword_color(k, CONTROL_FLOW_KEYWORD)
  const KEYWORD := Color("ff7085")
  for k in ["and", "or", "not", "null", "super", "class", "class_name", "extends", "is", "in", "as", "self", "signal", "func", "static", "const", "var", "breakpoint", "preload", "await", "yield", "assert", "PI", "TAU", "INF", "NAN"]:
    highlighter.add_keyword_color(k, KEYWORD)
  const TYPE := Color("8fffdb")
  for k in ["void", "bool", "int", "float", "String", "StringName", "NodePath", "Vector2", "Vector2i", "Rect2", "Vector3", "Vector3i", "Transform2D", "Plane", "Quaternion", "Basis", "Transform3D", "Color", "RID", "Object", "Array", "Dictionary", "Signal", "Callable"]:
    highlighter.add_keyword_color(k, TYPE)
  const GLOBAL_FUNCTION := Color("a3a3f5")
  for k in ["angle_difference", "atan2", "bezier_derivative", "bezier_interpolate", "bytes_to_var", "bytes_to_var_with_objects", "cubic_interpolate", "cubic_interpolate_angle", "cubic_interpolate_angle_in_time", "cubic_interpolate_in_time", "db_to_linear", "deg_to_rad", "ease", "error_string", "exp", "fmod", "fposmod", "hash", "instance_from_id", "inverse_lerp", "is_equal_approx", "is_finite", "is_inf", "is_instance_id_valid", "is_instance_valid", "is_nan", "is_same", "is_zero_approx", "lerp", "lerp_angle", "lerpf", "linear_to_db", "log", "move_toward", "nearest_po2", "pingpong", "posmod", "pow", "print", "print_rich", "print_verbose", "printerr", "printraw", "prints", "printt", "push_error",  "push_warning", "rad_to_deg", "rand_from_seed", "randomize", "remap", "rid_allocate_id", "rid_from_int64", "rotate_toward", "seed", "smoothstep", "sqrt", "step_decimals", "str", "str_to_var", "type_convert", "type_string", "typeof", "var_to_bytes", "var_to_bytes_with_objects", "var_to_str", "weakref"]:
    highlighter.add_keyword_color(k, GLOBAL_FUNCTION)
  for k in ["acos", "asin", "atan", "cos", "sin", "tan"]:
    for suffix in ["", "h"]:
      highlighter.add_keyword_color(k + suffix, GLOBAL_FUNCTION)
  for k in ["abs", "ceil", "clamp", "floor", "max", "min", "round", "sign", "snapped", "wrap"]:
    for suffix in ["", "f", "i"]:
      highlighter.add_keyword_color(k + suffix, GLOBAL_FUNCTION)
  for suffix in ["f", "f_range", "fn", "i", "irange"]:
    highlighter.add_keyword_color("rand" + suffix, GLOBAL_FUNCTION)
  const STRING := Color("ffeda1")
  for k in ["'", "\"", "'''", "\"\"\""]:
    highlighter.add_color_region(k, k, STRING)
  const STRING_NAME := Color("ffc2a6")
  highlighter.add_color_region("&\"", "\"", STRING_NAME, true)
  highlighter.add_color_region("&'", "'", STRING_NAME, true)
  const NODE_PATH := Color("b8c47d")
  highlighter.add_color_region("^\"", "\"", NODE_PATH, true)
  highlighter.add_color_region("^'", "'", NODE_PATH, true)
  const NODE_REFERENCE := Color("63c259")
  for s in ["$", "%"]:
    for q in ["\"", "'"]:
      highlighter.add_color_region(s + q, q, NODE_REFERENCE, true)
  const COMMENT := Color("cdcfd280")
  highlighter.add_color_region("#", "", COMMENT, true)
  const DOC_COMMENT := Color("cdcfd280")
  highlighter.add_color_region("##", "", DOC_COMMENT, true)
  ResourceSaver.save(highlighter)

func _get_url_params() -> Dictionary:
  var search := str(JavaScriptBridge.eval("window.location.search"))
  if search.is_empty():
    return {}
  search = search.substr(1)
  if search.is_empty():
    return {}
  var params := {}
  for param in search.split("&"):
    var key_value_pair := param.split("=")
    match key_value_pair.size():
      1:
        params[key_value_pair[0]] = null
      2:
        params[key_value_pair[0]] = key_value_pair[1]
  return params

func _load_script_from_url() -> void:
  var url_params := _get_url_params()
  var script_b64 = url_params.get("script")
  if script_b64:
    code_edit.text = Marshalls.base64_to_utf8(script_b64)

func _ready() -> void:
  if EngineDebugger.is_active():
    _build_code_highlighter_colors()
  _load_script_from_url()
  modals.add_modal(preload("res://Modals/TestModal.tscn").instantiate())

func user_print(messages: Array):
  _print_raw("".join(messages.map(str)))

func user_print_rich(messages: Array):
  _print("".join(messages.map(str)))

func user_push_warning(messages: Array):
  _print_warning("".join(messages.map(str)))

func user_push_error(messages: Array):
  _print_error("".join(messages.map(str)))

func _print(message: String, newline := true) -> void:
  output_label.append_text(message)
  if newline:
    output_label.append_text("\n")
    
func _print_raw(message: String, newline := true) -> void:
  output_label.add_text(message)
  if newline:
    output_label.append_text("\n")
  
func _print_warning(warning: String) -> void:
  output_label.push_color(Color.YELLOW)
  _print(warning, false)
  output_label.pop()
  output_label.append_text("\n")
  
func _print_error(error: String) -> void:
  output_label.push_color(Color.RED)
  _print(error, false)
  output_label.pop()
  output_label.append_text("\n")

func _re_replace(source: String, re: RegEx, replace_callback: Callable):
  var start := 0
  while true:
    var re_match := re.search(source, start)
    if re_match == null:
      break
    var replacement: String = replace_callback.call(re_match)
    source = source.substr(0, re_match.get_start()) + replacement + source.substr(re_match.get_end())
    start = re_match.get_start() + replacement.length()
  return source

func _postprocess_script(source: String):
  source = _re_replace(source, RegEx.create_from_string(r"([$\s])print\(([^\)]+)\)"), func(re_match):
    return re_match.get_string(1) + "GDScriptLive.user_print([" + re_match.get_string(2) + "])"
  )
  source = _re_replace(source, RegEx.create_from_string(r"([$\s])print_rich\(([^\)]+)\)"), func(re_match):
    return re_match.get_string(1) + "GDScriptLive.user_print_rich([" + re_match.get_string(2) + "])"
  )
  source = _re_replace(source, RegEx.create_from_string(r"([$\s])push_warning\(([^\)]+)\)"), func(re_match):
    return re_match.get_string(1) + "GDScriptLive.user_push_warning([" + re_match.get_string(2) + "])"
  )
  source = _re_replace(source, RegEx.create_from_string(r"([$\s])push_error\(([^\)]+)\)"), func(re_match):
    return re_match.get_string(1) + "GDScriptLive.user_push_error([" + re_match.get_string(2) + "])"
  )
  source = bootstrap_header + source
  return source

func _on_run_pressed() -> void:
  var entrypoint := entrypoint_field.text.strip_edges()
  output_label.text = ""
  if entrypoint.is_empty():
    entrypoint_field.text = ""
    _print_error("Entrypoint is empty")
    return
  var script := GDScript.new()
  script.source_code = _postprocess_script(code_edit.text)
  match script.reload():
    OK:
      pass
    var error:
      _print_error("Error in script compilation: " + error_string(error))
      return
  var has_entrypoint := false
  var custom_init_valid := false
  for method_info in script.get_script_method_list():
    if method_info["args"].size() > method_info["default_args"].size():
      _print_error(method_info["name"] + " must take 0 non-default parameters")
      return
    if method_info["name"] == "_init":
      custom_init_valid = true
    elif method_info["name"] == entrypoint:
      has_entrypoint = true
    if custom_init_valid && has_entrypoint:
      break
  if not has_entrypoint:
    _print_error("Script has no function with the entrypoint name: " + entrypoint)
    return
  var instance: Object = script.new()
  if not is_instance_valid(instance):
    _print_error("Failed to make an instance of the script. It's possible _init() produced an error.")
    return
  var return_value = instance.call(entrypoint)
  _print("Return: " + str(return_value))

func _on_godot_icon_pressed() -> void:
  OS.shell_open("https://godotengine.org/")

func _on_output_meta_clicked(meta: Variant) -> void:
  OS.shell_open(str(meta))

func _on_share_pressed() -> void:
  var url_root := str(JavaScriptBridge.eval("""window.location.protocol + "//" + window.location.host + window.location.pathname"""))
  var script_b64 := Marshalls.utf8_to_base64(code_edit.text)
  var full_url := url_root + "?script=" + script_b64
  DisplayServer.clipboard_set(full_url)
  JavaScriptBridge.eval("history.pushState(null, null, \"" + full_url + "\")")
  _print("Copied script URL to clipboard")
