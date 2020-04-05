extends Node2D

export (float) var springiness = 0.8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node('/root/scene/player')
	var toPlayer = (player.position - position) * delta * springiness
	set_position(position + toPlayer)
	
