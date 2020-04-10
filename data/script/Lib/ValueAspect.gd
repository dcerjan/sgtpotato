extends Node2D

class_name ValueAspect

export (float) var max_value = 100.0  
export (float) var current_value = 100.0 

func percentage():
  return clamp(current_value / max_value, 0.0, 1.0)

func is_max():
  return current_value >= max_value

func subtract(amount: float):
  current_value = max(current_value - amount, 0.0)

func add(amount: float):
  current_value = min(current_value + amount, max_value)
