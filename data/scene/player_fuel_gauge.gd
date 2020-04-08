extends ColorRect

export (NodePath) var target = null

var fuel_aspect: FuelAspect = null

func _ready():
	self.fuel_aspect = get_node(target).get_node('FuelAspect')
	assert(self.fuel_aspect != null)

func _process(_delta):
	self.rect_scale = Vector2(fuel_aspect.fuel_percentage(), 1)
