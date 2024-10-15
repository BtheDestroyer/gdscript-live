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

const PROFILE_ITERATION_BATCH_COUNT := 1_024
class Profiler:
  static var all_profilers := []
  static var bootstrap: SceneTree
  var callable: Callable
  var running := false
  var finished := false
  var min_usec: float
  var max_usec: float
  var total_msec: float
  var average_msec: float
  var min_msec: float
  var max_msec: float
  
  func _init(callable: Callable):
    self.callable = callable
    profile_complete.connect(_on_complete.unbind(3))
    profile_cancelled.connect(_on_cancel)

  func _on_complete() -> void:
    running = false
    finished = true
    profile_done.emit()
  
  func _on_cancel() -> void:
    running = false
    profile_done.emit()

  func start(iterations: int) -> void:
    if running:
        push_warning("Cannot start profile when already running; `if (running): await profile_done` first")
        return

    profile_start.emit()
    running = true
    finished = false
    min_usec = INF
    max_usec = 0.0
    total_msec = 0.0

    for index in range(0, iterations, PROFILE_ITERATION_BATCH_COUNT):
      var batch_count := mini(PROFILE_ITERATION_BATCH_COUNT, iterations - index)
      var batch_duration_usec := 0
      var start_usec := 0
      var end_usec := 0
      for batch_index in range(batch_count):
        start_usec = Time.get_ticks_usec()
        await callable.call()
        end_usec = Time.get_ticks_usec()
        batch_duration_usec += end_usec - start_usec
      var average_iteration_usec := float(batch_duration_usec) / float(batch_count)
      min_usec = min(min_usec, average_iteration_usec)
      max_usec = max(max_usec, average_iteration_usec)
      total_msec += batch_duration_usec * 0.001
      if index != 0:
        await Profiler.bootstrap.process_frame
        if not Profiler.all_profilers.has(self):
          profile_cancelled.emit()
          return
      index += PROFILE_ITERATION_BATCH_COUNT
      var completion := float(index) / float(iterations)
      profile_progress.emit(completion)

    average_msec = total_msec / iterations
    min_msec = min_usec * 0.001
    max_msec = max_usec * 0.001
    profile_complete.emit(average_msec, min_msec, max_msec)
  
  signal profile_start()
  signal profile_progress(completion: float)
  signal profile_done()
  signal profile_complete(average_time: float, min_time: float, max_time: float)
  signal profile_cancelled()

static func profile(callable: Callable, iterations:= 10_000):
  var profiler := Profiler.new(callable)
  profiler.start(iterations)
  Profiler.all_profilers.push_back(profiler)

var initialized := false
func _initialize():
  Profiler.bootstrap = self
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
  initialized = true
  var user_return = await script_instance.call(entrypoint)
  if user_return != null:
    print("Returned: ", user_return)
  var profile_results := []
  if !Profiler.all_profilers.is_empty():
    for profiler: Profiler in Profiler.all_profilers:
      if profiler.running:
        await profiler.profile_done
      if profiler.finished:
        profile_results.push_back({
          "callable": profiler.callable.get_method(),
          "failed": false,
          "min_msec": profiler.min_msec,
          "max_msec": profiler.max_msec,
          "average_msec": profiler.average_msec,
        })
      else:
        profile_results.push_back({
          "callable": profiler.callable.get_method(),
          "failed": true
        })
  var profile_results_file := FileAccess.open("/mnt/user/profiler", FileAccess.WRITE)
  if not profile_results_file:
    push_error("Failed to open profile results file for write")
  else:
    profile_results_file.store_string(JSON.stringify(profile_results))
  
  quit(0)

func _process(_delta):
  if not initialized:
    quit(4)

