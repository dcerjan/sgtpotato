extends Control

onready var healing_pad: HealingPad = get_node('../')
onready var energy = $DebugEnergyBar/DebugAmount
onready var delay = $DebugDelayBar/DebugAmount

func _process(delta: float):
  if healing_pad != null:
    energy.rect_scale = Vector2(clamp(healing_pad.current_energy / healing_pad.energy_max, 0.0, 1.0), 1.0)
    delay.rect_scale = Vector2(clamp(healing_pad.regen_delay / healing_pad.delay_before_energy_regen, 0.0, 1.0), 1.0)
