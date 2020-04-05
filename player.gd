extends RigidBody2D

export (float) var speed = 10
export (float) var turning_speed = 10
export (float) var deadzone = 0.2

var target_velocity = Vector2.ZERO

func get_input():
	var x = Input.get_joy_axis(0, JOY_ANALOG_LX)
	var y = Input.get_joy_axis(0, JOY_ANALOG_LY)
	
	var thumb = Vector2(x, y)
	
	if thumb.length() > deadzone:
		target_velocity = Vector2(x, y)
	else:
		target_velocity = Vector2.ZERO

func _physics_process(delta):
	get_input()
	if target_velocity.length() > 0.01:
		var global_direction = Vector2(cos(global_rotation), sin(global_rotation))
		var torque_to_apply = global_direction.angle_to(target_velocity)
		set_applied_torque(torque_to_apply * 1000 * mass * turning_speed * delta)
		set_applied_force(global_direction * 1000 * mass * speed * delta)
	else:
		set_applied_torque(0)
		set_applied_force(Vector2.ZERO)

