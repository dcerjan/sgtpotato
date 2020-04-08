extends Reference

class_name TankState

var fuel: float
var health: float
var fuel_tank_size: float
var fuel_consumption: float

func _init(
	health: float = 100.0,
	fuel_tank_size: float = 100.0,
	fuel_consumption: float = 1.0
):
	self.health = health
	self.fuel_tank_size = fuel_tank_size
	self.fuel_consumption = fuel_consumption
	self.fuel = fuel_tank_size

func get_fuel_percentage():
	return max(self.fuel / self.fuel_tank_size, 0.0)

func can_drive():
	return self.fuel > 0

func consume_fuel(delta: float):
	if (self.can_drive()):
		self.fuel -= delta * self.fuel_consumption
