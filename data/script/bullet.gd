extends RigidBody2D

export (float) var initial_alpha = 0.2
export (Vector2) var initial_scale = Vector2(0.4, 0.4)

var age

func init(position, velocity, age = 1.0):
	self.position = position + Vector2(randf() - 0.5, randf() - 0.5) * 1.5
	self.age = age
	global_rotation = velocity.angle() + (randf() - 0.5) * 36
	set_linear_velocity(velocity)
	
func _ready():
	var sprite = get_node('Sprite')
	sprite.scale = initial_scale
	var initial_color = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, initial_alpha)
	var end_color = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.0)

	var tweenAlpha = Tween.new()
	sprite.add_child(tweenAlpha)
	tweenAlpha.interpolate_property(
		sprite,
		'modulate',
		initial_color,
		end_color,
		age,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN
	)

	var tweenScale = Tween.new()
	sprite.add_child(tweenScale)
	tweenScale.interpolate_property(
		sprite,
		'scale',
		initial_scale,
		Vector2(1.0, 1.0),
		age,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)

	tweenAlpha.start()
	tweenScale.start()
	
	# var timer = get_tree().create_timer(2.0)
	yield(tweenAlpha, "tween_completed")
	get_parent().remove_child(self)
