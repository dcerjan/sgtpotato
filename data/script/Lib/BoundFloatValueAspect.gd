extends Node2D

class_name BoundFloatValueAspect

export (float) var max_value = 100.0
export (float) var min_value = 0.0
export (float) var initial_value = 100.0

onready var current_value = clamp(initial_value, min_value, max_value)

func _ready():
  print(current_value)

func percentage():
  return clamp(current_value / (max_value - min_value), 0.0, 1.0)

func is_max():
  return current_value >= max_value

func is_min():
  return current_value <= min_value

func subtract(amount: float):
  current_value = max(current_value - amount, min_value)

func add(amount: float):
  current_value = min(current_value + amount, max_value)
