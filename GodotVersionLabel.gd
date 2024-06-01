extends Label

func _ready() -> void:
  text = "Active Godot Version: " + Engine.get_version_info()["string"]
