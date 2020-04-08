extends Node2D

export (int) var rate_of_fire = 3
export (float) var deadzone = 0.2
export (float) var align_speed = 0.9

var bullets = []
var charged = 0.0
var direction = Vector2(1, 0)
var thumb_moved = false
var last_global_rotation = 0

func process_input(delta):
	var x = Input.get_joy_axis(0, JOY_ANALOG_RX)
	var y = Input.get_joy_axis(0, JOY_ANALOG_RY)
	
	var thumb = Vector2(x, y)
	
	if thumb.length() > deadzone:
		direction = Vector2(x, y).normalized()
		thumb_moved = true
	else:
		thumb_moved = false

	if Input.get_joy_axis(0, JOY_ANALOG_R2) > 0.1:
		charged += Input.get_joy_axis(0, JOY_ANALOG_R2) * delta

	while (charged > 1.0 / rate_of_fire):
		if !$CannonSfx.playing:
			$CannonSfx.play()
		charged -= (1.0 / rate_of_fire)
		var root = get_node('/root/')
		var bullet = load('res://data/composite/projectiles/bullet.tscn').instance()
		bullet.init(
			get_node('action_point').global_position,
			get_parent().linear_velocity + Vector2(cos(global_rotation), sin(global_rotation)) * 150,
			1.5
		)
		root.add_child(bullet)

func _process(delta):
	process_input(delta)
	if (thumb_moved):
		global_rotation = lerp_angle(global_rotation, direction.angle(), align_speed * delta)
		last_global_rotation = global_rotation
	else:
		global_rotation = last_global_rotation



