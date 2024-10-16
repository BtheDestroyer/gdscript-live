# GDScript.Live

Tool for quick GDScript testing and creating proof-of-concept scripts.

Use online now: https://gdscript.live

## Profiling

Using `GDScriptLive.profile(callback: Callable, ierations: int = 10_000)`, you can test the performance of various `Callable`s. This includes lambdas and asynchronous coroutines.

By default, `GDScriptLive.profile(callable)` will execute `callable` 10,000 times. This is done in batches of 1024 iterations per process frame to prevent the application from hanging indefinitely while profiling slower functions.

