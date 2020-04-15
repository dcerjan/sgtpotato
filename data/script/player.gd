extends RigidBody2D

export (float) var speed = 10
export (float) var turning_speed = 10
export (float) var deadzone = 0.2

var target_velocity = Vector2.ZERO

var fuel_aspect: FuelAspect = null
var health_aspect: HealthAspect = null

func _ready():
  fuel_aspect = get_node("FuelAspect")
  health_aspect = get_node("HealthAspect")

func get_input():
  if fuel_aspect.is_empty():
    target_velocity = Vector2.ZERO
    return

#  var x = Input.get_joy_axis(0, JOY_ANALOG_LX)
#  var y = Input.get_joy_axis(0, JOY_ANALOG_LY)
#  var thumb = Vector2(x, y)

  var x = 0.0
  var y = 0.0
  x += -1.0 if Input.is_key_pressed(KEY_A) else 0.0
  x +=  1.0 if Input.is_key_pressed(KEY_D) else 0.0
  y += -1.0 if Input.is_key_pressed(KEY_W) else 0.0
  y +=  1.0 if Input.is_key_pressed(KEY_S) else 0.0

  target_velocity = Vector2(x, y)
#  if thumb.length() > deadzone:
#    target_velocity = Vector2(x, y)
#  else:
#    target_velocity = Vector2.ZERO

func play_motor(velocity):
  var vol = clamp(velocity.length(), 1.0, 3.0) / 3.0
  if not $EngineSfx.is_playing():
    $EngineSfx.play()
  var pitch = 0.7 + target_velocity.length() * 0.2
  var voldb = vol * 0.5
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
