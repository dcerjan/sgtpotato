extends Node2D

class_name FuelAspect

export (float) var max_fuel = 100.0  
export (float) var current_fuel = 100.0
export (float) var fuel_consumption = 1.0 

func fuel_percentage():
	return max(self.current_fuel / self.max_fuel, 0.0)

func is_empty():
	return self.current_fuel <= 0

func consume_fuel(delta: float):
	self.current_fuel = max(self.current_fuel - delta * self.fuel_consumption, 0.0)

func refil_fuel(amount: float):
	self.current_fuel = min(self.current_fuel + amount, self.max_fuel)
