extends Label

func _ready() -> void:
  text = "GDScript.Live Project Version: " + ProjectSettings.get_setting("application/config/version")
