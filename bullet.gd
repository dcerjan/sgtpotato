extends RigidBody2D

func init(position, velocity):
	self.position = position
	global_rotation = velocity.angle()
	set_linear_velocity(velocity)

func _ready():
	var timer = get_tree().create_timer(1.0)
	yield(timer, "timeout")
	get_parent().remove_child(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
