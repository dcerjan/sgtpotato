extends ValueAspect

class_name FuelAspect

export (float) var fuel_consumption = 1.0

func consume_fuel(delta: float):
  subtract(fuel_consumption * delta) 

func is_empty():
  return current_value <= 0.0
