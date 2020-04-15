extends Spatial

onready var yaw_node = self
onready var pitch_node = $Pitch


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var yaw = 0.0
var pitch = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func _process(delta: float) -> void:
  var x = Input.get_joy_axis(0, JOY_ANALOG_RX)
  var y = Input.get_joy_axis(0, JOY_ANALOG_RY)

  yaw = x * delta if abs(x) > 0.3 else 0.0
  pitch = y * delta if abs(y) > 0.3 else 0.0

  yaw_node.rotate_y(-yaw)
  pitch_node.rotate_x(pitch)

