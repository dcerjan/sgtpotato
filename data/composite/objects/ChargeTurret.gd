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

export (float) var charge_trheshold = 1.0
export (int) var particle_rate = 30
export (Curve) var curve = Curve.new()
export (Curve) var after_curve = Curve.new()

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

func _ready() -> void:
  # TODO: extract 100 into a range variable
  ray.enabled = false
  ray.set_cast_to(Vector2(100.0, 0.0))
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
  var mouse_pos = get_global_mouse_position()
  var to_mouse = mouse_pos - turret.global_position
  turret.global_rotation = to_mouse.angle()
  
  match __turret_state:
    TurretState.Idle:
      if Input.is_mouse_button_pressed(BUTTON_LEFT):
        __turret_state = TurretState.SpoolingUp
        play_spool_particles()
        
    TurretState.SpoolingUp:
      if Input.is_mouse_button_pressed(BUTTON_LEFT):
        charge = min(charge + delta, 1.0)
        if charge >= 1.0:
          __turret_state = TurretState.Charged
      else:
        __turret_state = TurretState.SpoolingDown
        
    TurretState.SpoolingDown:
      if Input.is_mouse_button_pressed(BUTTON_LEFT):
        __turret_state = TurretState.SpoolingUp
      else:
        charge = max(charge - delta, 0.0)
        if charge <= 0.0:
          __turret_state = TurretState.Idle
          stop_spool_particles()
          
    TurretState.Charged:
      if not Input.is_mouse_button_pressed(BUTTON_LEFT):
        energy = 1.0
        __turret_state = TurretState.Firing
        ray.enabled = true
        beam.add_point(Vector2(2.0, 0.0))
        beam.add_point(Vector2(100.0, 0.0))
        var samples = 20.0
        var step = 1.0 / samples
        for i in range(int(samples)):
          crackle.add_point(Vector2(4.0 + i * step * 80.0, (0.5 - randf()) * 6.0))

    TurretState.Firing:
      energy = max(energy - delta, 0.0)
      beam.width = curve.interpolate(1.0 - energy)
      crackle.width = curve.interpolate(1.0 - energy) * 0.25
      if ray.is_colliding():
        print(ray.get_collision_point())
        if not impact.playing:
          impact.play()
        impact.global_position = ray.get_collision_point()
        impact.global_rotation = ray.get_collision_normal().angle()
      else:
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
      modulate_residue_particles(after_curve.interpolate(1.0 - residue))
      if residue <= 0.0:
        __residue_state = ResidueState.Stopped
        stop_residue_particles()
    
    ResidueState.Stopped:
      pass
  
  if __turret_state != TurretState.Idle:
    modulate_spool_particles(charge / charge_trheshold)
  
  bar.rect_scale = Vector2(clamp(charge / charge_trheshold, 0.0, 1.0), 1.0)
