extends Node2D

class_name HealthAspect

export (float) var max_health = 100.0  
export (float) var current_health = 100.0 

func health_percentage():
	return max(self.current_health / self.max_health, 0.0)

func is_full():
	return self.current_health >= self.max_health

func is_alive():
	return self.current_health > 0

func is_death():
	return self.current_health <= 0

func damage(amount: float):
	self.current_health = max(self.current_health - amount, 0.0)

func heal(amount: float):
	self.current_health = min(self.current_health + amount, self.max_health)
