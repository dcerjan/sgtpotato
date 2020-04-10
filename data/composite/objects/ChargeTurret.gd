extends Node2D

onready var turret = $Turret
onready var particles = $Turret/Particles2D
onready var bar = $Control/Bg/Fg
onready var beam = $Turret/Beam

export (float) var charge_trheshold = 1.0
export (int) var particle_rate = 30

var charge: float = 0.0
var discharge: float = 1.0
var prev_particle_emission: int = -1

func _process(delta):
  var mouse_pos = get_global_mouse_position()
  var to_mouse = mouse_pos - turret.global_position
  turret.global_rotation = to_mouse.angle()

  if (Input.is_mouse_button_pressed(BUTTON_LEFT) and discharge >= 1.0):
    charge = min(charge + delta, charge_trheshold)
  else:
    if charge >= 1.0 and discharge > 0.0:
      beam.self_modulate = Color(1.0, 1.0, 1.0, 1.0 - discharge)
      if charge >= 1.0 and discharge >= 1.0:
        beam.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
        for i in range(20):
          beam.add_point(Vector2(i * 6.0, (randf() - 0.5) * 4.0))
      else:
        for i in range(20):
          var t = 1.0 if discharge > 0.2 else pow(discharge / 0.2, 0.7)
          beam.set_point_position(i, Vector2(i * 6.0 * t, (randf() - 0.5) * 4.0 * t))
      discharge = max(discharge - delta * 0.75, 0.0)
    else:
      beam.clear_points()
      charge = max(charge - delta * 4, 0.0)
      if charge <= 0.0:
        discharge = 1.0
    

  particles.self_modulate = Color(1.0, 1.0, 1.0, clamp(discharge * charge / charge_trheshold, 0.0, 1.0))
  
  bar.rect_scale = Vector2(clamp(charge / charge_trheshold, 0.0, 1.0), 1.0)
