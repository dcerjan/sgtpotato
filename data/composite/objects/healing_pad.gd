extends Area2D

enum State {
	Active = 0,
	Recharging = 1,
}

export (float) var energy_max = 100.0
export (float) var initial_energy = 1.0
export (float) var energy_regen = 1.0
export (float) var healing_rate = 5.0
export (float) var reactivation_threshold = 0.5

onready var particles = $Particles2D
onready var sprite = $Sprite

var current_energy = initial_energy * energy_max
var state = State.Active

func _process(delta: float) -> void:
	match state:
		State.Active:
			var bodies = get_overlapping_bodies()
			for body in bodies:
				if body.has_node('HealthAspect'):
					var health_aspect: HealthAspect = body.get_node('HealthAspect')
					if not health_aspect.is_full():
						health_aspect.heal(delta * healing_rate)
						current_energy = max(current_energy - delta * healing_rate, 0.0)
						if (current_energy <= 0.0):
							particles.emitting = false
							state = State.Recharging
		
		State.Recharging:
			if current_energy >= reactivation_threshold * energy_max:
				particles.emitting = true
				state = State.Active
			
	current_energy = min(current_energy + delta * energy_regen, energy_max)
	sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0).darkened(0.5 * pow(1.0 - current_energy / energy_max, 2.0))
