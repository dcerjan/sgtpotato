extends ColorRect

export (NodePath) var target = null

var health_aspect: HealthAspect = null

func _ready():
  self.health_aspect = get_node(target).get_node('HealthAspect')
  assert(self.health_aspect != null)

func _process(_delta):
  self.rect_scale = Vector2(self.health_aspect.percentage(), 1)
