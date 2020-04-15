extends Node2D

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event: InputEvent) -> void:
  if Input.is_action_just_released("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
