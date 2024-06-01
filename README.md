# GDScript.Live

Tool for quick GDScript testing and creating proof-of-concept scripts.

Use online now: https://gdscript.live

## Profiling

Using `GDScriptLive.profile(callback: Callable, state: Dictionary = {}, iterations: int = PROFILE_ITERATION_COUNT)`, you can test the performance of various `Callable`s. This includes lambdas and asynchronous coroutines.

By default, `GDScriptLive.profile(...)` will execute `callable` `PROFILE_ITERATION_COUNT` times, which is currently 10,000. This is done in batches of 1024 iterations per process frame to prevent the application from haulting while profiling slower functions.

The `state` parameter is forwarded to each call of `callable`, so you can test the same function with various inputs. For instance, a function could be given `Array`s of various sizes to empirically determine how its performance scales with the size of its input. One special case is that `state[&"index"]` is set to the iteration index of the current call. This can be used in your profiled function to print debug information, generate random numbers, or otherwise perform unique work per profiled call.
