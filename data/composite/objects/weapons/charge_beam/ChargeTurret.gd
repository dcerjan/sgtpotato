extends Node2D

onready var turret = $Turret
onready var particles_charge = $Turret/BeamParticles/Charge
onready var particles_beam_up = $Turret/BeamParticles/Up
onready var particles_beam_down = $Turret/BeamParticles/Down
onready var particles_residue = $Turret/BeamParticles/Residue
onready var beam = $Turret/Beams/Beam
onready var crackle = $Turret/Beams/Crackle
onready var ray = $Turret/RayCast2D
onready var impact = $Impact

onready var bar = $Control/Bg/Fg

export (Curve) var beam_width_curve = Curve.new()
export (Curve) var residue_curve = Curve.new()


enum TurretState {
  Idle          = 0,
  SpoolingUp    = 1,
  SpoolingDown  = 2,
  Charged       = 3,
  Firing        = 4,
  Discharging   = 5
}

enum ResidueState {
  Stopped = 0,
  Playing = 1
}

var __turret_state = TurretState.Idle
var __residue_state = ResidueState.Stopped

var charge: float = 0.0
var energy: float = 0.0
var residue: float = 0.0

var beam_length = 200.0
var samples = 40.0
var step = 1.0 / samples

var trigger_held = false
var damage_per_secod = 1.0

func _ready() -> void:
  ray.enabled = false
  ray.set_cast_to(Vector2(beam_length, 0.0))
  beam.clear_points()
  crackle.clear_points()
  impact.stop()
  stop_spool_particles()
  stop_residue_particles()

func stop_spool_particles() -> void:
  if particles_beam_down.emitting:
    particles_beam_down.emitting = false
  if particles_beam_up.emitting:
    particles_beam_up.emitting = false
  if particles_charge.emitting:
    particles_charge.emitting = false

func play_spool_particles() -> void:
  if not particles_beam_down.emitting:
    particles_beam_down.emitting = true
    particles_beam_down.restart()
  if not particles_beam_up.emitting:
    particles_beam_up.emitting = true
    particles_beam_up.restart()
  if not particles_charge.emitting:
    particles_charge.emitting = true
    particles_charge.restart()

func modulate_spool_particles(alpha: float) -> void:
  var color = Color(1.0, 1.0, 1.0, clamp(alpha, 0.0, 1.0))
  particles_charge.self_modulate = color
  particles_beam_down.self_modulate = color
  particles_beam_up.self_modulate = color

func stop_residue_particles() -> void:
  if particles_residue.emitting:
    particles_residue.emitting = false

func play_residue_particles() -> void:
  if not particles_residue.emitting:
    particles_residue.emitting = true
    particles_residue.restart()

func modulate_residue_particles(alpha: float) -> void:
  particles_residue.self_modulate = Color(1.0, 1.0, 1.0, clamp(alpha, 0.0, 1.0))

func _process(delta):
  match __turret_state:
    TurretState.Idle:
      if trigger_held:
        __turret_state = TurretState.SpoolingUp
        play_spool_particles()

    TurretState.SpoolingUp:
      if trigger_held:
        charge = min(charge + delta, 1.0)
        if charge >= 1.0:
          __turret_state = TurretState.Charged
      else:
        __turret_state = TurretState.SpoolingDown

    TurretState.SpoolingDown:
      if trigger_held:
        __turret_state = TurretState.SpoolingUp
      else:
        charge = max(charge - delta, 0.0)
        if charge <= 0.0:
          __turret_state = TurretState.Idle
          stop_spool_particles()

    TurretState.Charged:
      if not trigger_held:
        energy = 1.0
        __turret_state = TurretState.Firing
        ray.enabled = true
        beam.add_point(Vector2(2.0, 0.0))
        beam.add_point(Vector2(beam_length, 0.0))
        for i in range(int(samples)):
          crackle.add_point(Vector2(4.0 + i * step * beam_length * 0.8, (0.5 - randf()) * 6.0))

    TurretState.Firing:
      energy = max(energy - delta * 0.75, 0.0)
      beam.width = beam_width_curve.interpolate(1.0 - energy)
      crackle.width = beam_width_curve.interpolate(1.0 - energy) * 0.25
      if ray.is_colliding():
        if not impact.playing:
          impact.play()
        impact.global_position = ray.get_collision_point()
        impact.global_rotation = ray.get_collision_normal().angle()
        var end = beam.get_global_transform().xform_inv(ray.get_collision_point())
        beam.set_point_position(1, end * 0.93)
        var end_len = end.length()
        for i in range(int(samples)):
          var y = crackle.get_point_position(i).y
          crackle.set_point_position(i, Vector2(min(4.0 + i * step * beam_length * 0.8, end_len), y))
        var body = ray.get_collider() as Node2D
        if body.has_node('HealthAspect'):
          var health_aspect: HealthAspect = body.get_node('HealthAspect')
          health_aspect.subtract(damage_per_secod * delta)
      else:
        beam.set_point_position(1, Vector2(beam_length, 0.0))
        for i in range(int(samples)):
          var y = crackle.get_point_position(i).y
          crackle.set_point_position(i, Vector2(4.0 + i * step * beam_length * 0.8, y))
        impact.stop()

      if energy <= 0.0:
        __turret_state = TurretState.Discharging
        impact.stop()
        ray.enabled = false
        beam.clear_points()
        crackle.clear_points()
      if __residue_state == ResidueState.Stopped and energy <= 0.75:
        residue = 1.0
        __residue_state = ResidueState.Playing
        play_residue_particles()

    TurretState.Discharging:
      charge = max(charge - delta * 4.0, 0.0)
      if charge <= 0.0:
        __turret_state = TurretState.Idle
        stop_spool_particles()

  match __residue_state:
    ResidueState.Playing:
      residue = max(residue - delta * 0.85, 0.0)
      modulate_residue_particles(residue_curve.interpolate(1.0 - residue))
      if residue <= 0.0:
        __residue_state = ResidueState.Stopped
        stop_residue_particles()

    ResidueState.Stopped:
      pass

  if __turret_state != TurretState.Idle:
    modulate_spool_particles(charge)

  # bar.rect_scale = Vector2(clamp(charge, 0.0, 1.0), 1.0)

func hold_trigger() -> void:
  trigger_held = true

func release_trigger() -> void:
  trigger_held = false
