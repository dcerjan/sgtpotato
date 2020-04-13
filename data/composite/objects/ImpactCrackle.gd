extends Node2D

onready var tentacles = [
  $Crackle1,
  $Crackle2,
  $Crackle3
]
onready var chunks = $Chunks

var tentacle_length = 6.0
var samples = 4
var step = tentacle_length / float(samples)
var updates = 15

var delay = 1.0 / float(updates)

var playing = false

func _ready() -> void:
  stop()
  for crackle in tentacles:
    crackle.clear_points()
    for i in samples:
      crackle.add_point(Vector2(i * step, 2.0 * (0.5 - randf())))

func _process(delta: float) -> void:
  delay = max(delay - delta, 0.0)
  if delay <= 0.0:
    delay = 1.0 / float(updates)
    for crackle in tentacles:
      for i in samples:
        crackle.set_point_position(i, Vector2(i * step, 2.0 * (0.5 - randf())))

func stop() -> void:
  playing = false
  for crackle in tentacles:
    crackle.visible = false
  chunks.emitting = false 

func play():
  playing = true
  for crackle in tentacles:
    crackle.visible = true
  chunks.emitting = true
