extends Node2D

onready var turret = $Turret
onready var particles = $Turret/Particles2D
onready var particles_beam_up = $Turret/BeamParticles/Up
onready var particles_beam_down = $Turret/BeamParticles/Down
onready var particles_beam = $Turret/BeamParticles/Middle

onready var bar = $Control/Bg/Fg
onready var beam = $Turret/Beam

export (float) var charge_trheshold = 1.0
export (int) var particle_rate = 30
export (Curve) var curve = Curve.new()
export (Curve) var after_curve = Curve.new()

# = States = #
class Idle extends State:
  func on_enter():
    pass

class Spooling extends State:
  func on_enter():
    pass

class Unspooling extends State:
  func on_enter():
    pass

class Charged extends State:
  func on_enter():
    pass

class Discharging extends State:
  func on_enter():
    pass



var charge: float = 0.0
var discharge: float = 1.0
var after: float = 0.0
var prev_particle_emission: int = -1
var render_particles = false

func _process(delta):
  var mouse_pos = get_global_mouse_position()
  var to_mouse = mouse_pos - turret.global_position
  turret.global_rotation = to_mouse.angle()
  
  if charge <= 0.0:
    if particles_beam_down.emitting:
      particles_beam_down.emitting = false
    if particles_beam_up.emitting:
      particles_beam_up.emitting = false
    if particles.emitting:
      particles.emitting = false


  else:
    if not particles_beam_down.emitting:
      particles_beam_down.emitting = true
      particles_beam_down.restart()
    if not particles_beam_up.emitting:
      particles_beam_up.emitting = true
      particles_beam_up.restart()
    if not particles.emitting:
      particles.emitting = true
      particles.restart()
    
  after = max(after - delta * 0.85, 0.0)
  if particles_beam.emitting and after <= 0.0:
    particles_beam.emitting = false
  elif not particles_beam.emitting:
    particles_beam.emitting = true
    particles_beam.restart()

  if (Input.is_mouse_button_pressed(BUTTON_LEFT) and discharge >= 1.0):
    charge = min(charge + delta, charge_trheshold)
  else:
    if charge >= 1.0 and discharge <= 0.7 and discharge >= 0.6:
      after = 1.0
    if charge >= 1.0 and discharge > 0.0:
      beam.self_modulate = Color(1.0, 1.0, 1.0, 1.0 - discharge)
      if charge >= 1.0 and discharge >= 1.0:
        beam.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
        for i in range(20):
          beam.add_point(Vector2(1 + i * 6.0, (randf() - 0.5) * 4.0 * 0.0))
      else:
        var t = 1.0 if discharge > 0.2 && false else pow(discharge / 0.2, 0.7)
        beam.width = t * 3
      discharge = max(discharge - delta * 0.75, 0.0)
    else:
      beam.clear_points()
      charge = max(charge - delta * 4, 0.0)
      if charge <= 0.0:
        discharge = 1.0
  
  particles.self_modulate = Color(1.0, 1.0, 1.0, clamp(discharge * charge / charge_trheshold, 0.0, 1.0))
  particles_beam_down.self_modulate = Color(1.0, 1.0, 1.0, clamp(discharge * charge / charge_trheshold, 0.0, 1.0))
  particles_beam_up.self_modulate = Color(1.0, 1.0, 1.0, clamp(discharge * charge / charge_trheshold, 0.0, 1.0))
  particles_beam.self_modulate = Color(1.0, 1.0, 1.0, after_curve.interpolate(1.0 - after))
  
  beam.width = curve.interpolate(1.0 - discharge)
  
  bar.rect_scale = Vector2(clamp(charge / charge_trheshold, 0.0, 1.0), 1.0)
