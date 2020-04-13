extends Node2D

export (float) var damage_per_second = 10.0

onready var turret = $ChargeTurret

func _ready() -> void:
  turret.damage_per_secod = damage_per_second

func hold_trigger() -> void:
  turret.hold_trigger()

func release_trigger() -> void:
  turret.release_trigger()
