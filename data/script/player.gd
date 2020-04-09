extends RigidBody2D

export (float) var speed = 10
export (float) var turning_speed = 10
export (float) var deadzone = 0.2

var target_velocity = Vector2.ZERO

var fuel_aspect: FuelAspect = null
var health_aspect: HealthAspect = null

func _ready():
  self.fuel_aspect = self.get_node("FuelAspect")
  self.health_aspect = self.get_node("HealthAspect")

func get_input():
  if fuel_aspect.is_empty():
    target_velocity = Vector2.ZERO
    return

  var x = Input.get_joy_axis(0, JOY_ANALOG_LX)
  var y = Input.get_joy_axis(0, JOY_ANALOG_LY)

  var thumb = Vector2(x, y)
  
  if thumb.length() > deadzone:
    target_velocity = Vector2(x, y)
  else:
    target_velocity = Vector2.ZERO

func play_motor(velocity):
  var vol = velocity.length()
  if vol <= 0:
    $EngineSfx.stop()
    return
  if vol > 3.0:
    vol = 3.0
  vol = vol / 3
  if !$EngineSfx.is_playing():
    $EngineSfx.play()
  var pitch = 0.8 + target_velocity.length()*2
  var voldb = (1-vol)*-80
  $EngineSfx.pitch_scale = pitch
  $EngineSfx.volume_db = voldb

func _physics_process(delta):
  get_input()
  if target_velocity.length() > 0.01:
    var global_direction = Vector2(cos(global_rotation), sin(global_rotation))
    var torque_to_apply = global_direction.angle_to(target_velocity)
    set_applied_torque(torque_to_apply * 1000 * mass * turning_speed * delta)
    set_applied_force(global_direction * 1000 * mass * speed * delta)
    fuel_aspect.consume_fuel(delta)
  else:
    set_applied_torque(0)
    set_applied_force(Vector2.ZERO)
  play_motor(self.linear_velocity)

func _on_healing_pad_body_entered(node: Object):
  print (node)
