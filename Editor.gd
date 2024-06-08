class_name _GDScriptLive extends Control

@export var code_edit: CodeEdit
@export var entrypoint_field: LineEdit
@export var output_label: RichTextLabel
@export var modals: Modals
@onready var bootstrap_header := r"""
var GDScriptLive = instance_from_id(%d)
""" % [get_instance_id()]
@export var settings: _Settings
var script_instance: Object

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

@onready var url_params := _get_url_params()
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
  var script_b64 = url_params.get("script")
  if script_b64:
    code_edit.text = Marshalls.base64_to_utf8(script_b64)

func _ready() -> void:
  if EngineDebugger.is_active():
    _build_code_highlighter_colors()
  code_edit.text = (preload("res://DefaultScript.gd") as Script).source_code
  settings._load_settings()
  if url_params.has("indent_type") or url_params.has("indent_size"):
    settings.indentation_option.selected = url_params.get("indent_type", 1 if code_edit.indent_use_spaces else 0)
    settings.indentation_size.value = url_params.get("indent_size", code_edit.indent_size)
    settings._reindent_code_edit()
  _load_script_from_url() # Assume the encoded script is already indented properly

func user_print(messages: Array):
  _print_raw("".join(messages.map(str)))

func user_print_rich(messages: Array):
  _print("".join(messages.map(str)))

func user_push_warning(messages: Array, line: int):
  _print_warning("".join(messages.map(str)) + "\n\t\tLine: " + str(line))

func user_push_error(messages: Array, line: int):
  _print_error("".join(messages.map(str)) + "\n\t\tLine: " + str(line))

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
  _print("⚠ " + warning, false)
  output_label.pop()
  output_label.append_text("\n")

func _print_error(error: String) -> void:
  output_label.push_color(Color.RED)
  _print("🅧 " + error, false)
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

enum IndentationType {
  UNKNOWN,
  TAB,
  SPACE
}

func _ensure_script_has_no_errors(source: String) -> bool:
  var indentation_type := IndentationType.UNKNOWN
  var indent_regex := RegEx.create_from_string("^[\t ]+")
  var last_line := ""
  var line_index := 0
  var expected_indentations: Array[String] = [""]
  for line in source.split("\n"):
    line_index += 1
    var regex_match := indent_regex.search(line)
    if regex_match == null:
      if not line.is_empty():
        last_line = line
        expected_indentations = [""]
      continue
    var current_line_indentation := regex_match.get_string()
    if current_line_indentation.count(current_line_indentation[0]) != current_line_indentation.length():
      user_push_error(["Indentation mismatch. Mixing tabs and spaces."], line_index)
      return false
    var found_indentation_type := IndentationType.SPACE if current_line_indentation[0] == " " else IndentationType.TAB
    if found_indentation_type != indentation_type:
      if indentation_type == IndentationType.UNKNOWN:
        indentation_type = found_indentation_type
        var expected_indentation_type := IndentationType.SPACE if code_edit.indent_use_spaces else IndentationType.TAB
        if found_indentation_type != expected_indentation_type:
          var expected_indentation := "spaces" if expected_indentation_type == IndentationType.SPACE else "tabs"
          var found_indentation := "spaces" if found_indentation_type == IndentationType.SPACE else "tabs"
          user_push_warning(["Indentation mismatch with settings. Expected ", expected_indentation, ", but found ", found_indentation], line_index)
      else:
        var original_indentation := "spaces" if indentation_type == IndentationType.SPACE else "tabs"
        var found_indentation := "spaces" if found_indentation_type == IndentationType.SPACE else "tabs"
        user_push_error(["Indentation mismatch. Switched from ", original_indentation, " to ", found_indentation], line_index)
        return false
    if current_line_indentation.length() > expected_indentations.back().length() and not last_line.ends_with(":") and not last_line.ends_with("\\"):
      user_push_error(["Indentation error. Indentation increased despite prior line not ending with `:` or `\\`"], line_index)
      return false
    elif last_line.ends_with(":"):
      if current_line_indentation.length() > expected_indentations.back().length():
        var expected_indentation_count := code_edit.indent_size if code_edit.indent_use_spaces else 1
        if current_line_indentation.length() != expected_indentations.back().length() + expected_indentation_count:
          user_push_warning(["Indentation mismatch with settings. Expected next level to be ", expected_indentation_count, ", but found ", current_line_indentation.length()], line_index)
        expected_indentations.push_back(current_line_indentation)
      else:
        user_push_error(["Indentation error. Indentation did not increase despite prior line ending with `:`"], line_index)
        return false
    else: # Indentation decrease testing
      while expected_indentations.size() > 0:
        if current_line_indentation.length() == expected_indentations.back().length():
          break # Found valid indentation level
        elif current_line_indentation.length() < expected_indentations.back().length():
          expected_indentations.pop_back() # Still decreasing
        else:
          # Decreased too far or between possible indentations
          user_push_error(["Indentation error. Indentation decreased to an invalid amount (either too much or too little)."], line_index)
          return false
    last_line = line
  return true

func _postprocess_script(source: String) -> String:
  source = _re_replace(source, RegEx.create_from_string(r"(\s+)print\((.+)\)(\s*)"), func(re_match: RegExMatch):
    return re_match.get_string(1) + "GDScriptLive.user_print([" + re_match.get_string(2) + "])" + re_match.get_string(3)
  )
  source = _re_replace(source, RegEx.create_from_string(r"(\s+)print_rich\((.+)\)(\s*)"), func(re_match: RegExMatch):
    return re_match.get_string(1) + "GDScriptLive.user_print_rich([" + re_match.get_string(2) + "])" + re_match.get_string(3)
  )
  source = _re_replace(source, RegEx.create_from_string(r"(\s+)push_warning\((.+)\)(\s*)"), func(re_match: RegExMatch):
    var line := source.count("\n", 0, re_match.get_end(1))
    return re_match.get_string(1) + "GDScriptLive.user_push_warning([" + re_match.get_string(2) + "], " + str(line) + ")" + re_match.get_string(3)
  )
  source = _re_replace(source, RegEx.create_from_string(r"(\s+)push_error\((.+)\)(\s*)"), func(re_match: RegExMatch):
    var line := source.count("\n", 0, re_match.get_end(1))
    return re_match.get_string(1) + "GDScriptLive.user_push_error([" + re_match.get_string(2) + "], " + str(line) + ")" + re_match.get_string(3)
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
  if not _ensure_script_has_no_errors(code_edit.text):
    _print_error("Script has errors")
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
  var has_custom_init := false
  for method_info in script.get_script_method_list():
    if method_info["name"] == "_init":
      has_custom_init = true
    elif method_info["name"] == entrypoint:
      has_entrypoint = true
    else:
      continue
    if method_info["args"].size() > method_info["default_args"].size():
      _print_error(method_info["name"] + " must take 0 non-default parameters")
      return
    if has_custom_init && has_entrypoint:
      break
  if not has_entrypoint:
    _print_error("Script has no function with the entrypoint name: " + entrypoint)
    return
  script_instance = script.new()
  if not is_instance_valid(script_instance):
    _print_error("Failed to make an instance of the script. It's possible _init() produced an error.")
    return
  profiles_active.clear()
  var return_value = script_instance.call(entrypoint)
  _print("Return: " + str(return_value))

func _on_godot_icon_pressed() -> void:
  OS.shell_open("https://godotengine.org/")

func _on_output_meta_clicked(meta: Variant) -> void:
  OS.shell_open(str(meta))

func _on_share_pressed() -> void:
  var url_root := str(JavaScriptBridge.eval("""window.location.protocol + "//" + window.location.host + window.location.pathname"""))
  var script_b64 := Marshalls.utf8_to_base64(code_edit.text)
  var full_url := url_root + "?script=" + script_b64 + "&indent_type=" + str(1 if code_edit.indent_use_spaces else 0) + "&indent_size=" + str(code_edit.indent_size)
  DisplayServer.clipboard_set(full_url)
  JavaScriptBridge.eval("history.pushState(null, null, \"" + full_url + "\")")
  _print("Copied script URL to clipboard")

var about_modal: Modal
func _on_about_pressed() -> void:
  if is_instance_valid(about_modal):
    return
  about_modal = preload("res://Modals/About.tscn").instantiate()
  modals.add_modal(about_modal)

const PROFILE_ITERATION_COUNT = 10_000
const PROFILE_ITERATION_BATCH_COUNT = 1_024
var profiles_active := []
func profile(callable: Callable, state := {}, iterations := PROFILE_ITERATION_COUNT) -> void:
  var min_usec := INF
  var max_usec := 0.0
  var total_msec := 0.0
  var original_state := state.duplicate(true)
  var hash := callable.hash() ^ state.hash()
  profiles_active.push_back(hash)
  profile_start.emit(callable, original_state)
  var index := 0
  while index < iterations:
    var local_state := original_state.duplicate(true).merged({&"index": -1}, true)
    var batch_count := mini(PROFILE_ITERATION_BATCH_COUNT, iterations - index)
    var batch_duration_usec := 0
    var start_usec := 0
    var end_usec := 0
    for batch_index in range(batch_count):
      local_state[&"index"] = index + batch_index
      start_usec = Time.get_ticks_usec()
      await callable.call(local_state)
      end_usec = Time.get_ticks_usec()
      batch_duration_usec += end_usec - start_usec
    var average_iteration_usec := float(batch_duration_usec) / float(PROFILE_ITERATION_BATCH_COUNT)
    min_usec = min(min_usec, average_iteration_usec)
    max_usec = max(max_usec, average_iteration_usec)
    total_msec += batch_duration_usec * 0.001
    if index != 0:
      await get_tree().process_frame
      if not profiles_active.has(hash):
        profile_cancelled.emit(callable, state)
        return
    index += PROFILE_ITERATION_BATCH_COUNT
    var completion := float(index) / float(iterations)
    profile_progress.emit(callable, original_state, completion)
  if profiles_active.has(hash):
    profiles_active.erase(hash)
  var average_msec := total_msec / iterations
  var min_msec := min_usec * 0.001
  var max_msec := max_usec * 0.001
  _print("Profile result for `%s(%s)`:\n\taverage=%fms\n\tmin=%fms\n\tmax=%fms" % [callable.get_method(), str(original_state), average_msec, min_msec, max_msec])
  profile_complete.emit(callable, original_state, average_msec, min_msec, max_msec)

signal profile_start(callable: Callable, state: Dictionary)
signal profile_progress(callable: Callable, state: Dictionary, completion: float)
signal profile_complete(callable: Callable, state: Dictionary, average_time: float, min_time: float, max_time: float)
signal profile_cancelled(callable: Callable, state: Dictionary)
