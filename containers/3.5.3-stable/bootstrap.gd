extends SceneTree

func get_options() -> Dictionary:
  var options := {}
  var args := OS.get_cmdline_user_args()
  for i in range(args.size()):
    options[args[i].get_slice("=", 0)] = (
      args[i].substr(args[i].find("=") + 1)
        if args[i].contains("=") else
      null
    )
  return options

func _initialize():
  var user_script := load("/mnt/user/script.gd") as GDScript
  if not user_script:
    push_error("Missing user script file!")
    quit(1)
    return
  var script_instance = user_script.new()
  if not script_instance:
    push_error("Failed to make instance of user script")
    quit(2)
    return
  var options := get_options()
  var entrypoint: String = options.get("entrypoint", "main")
  if not script_instance.has_method(entrypoint):
    push_error("User script has no entrypoint: ", entrypoint)
    quit(3)
    return
  var user_return = await script_instance.call(entrypoint)
  if user_return != null:
    print("Returned: ", user_return)
  quit(0)
