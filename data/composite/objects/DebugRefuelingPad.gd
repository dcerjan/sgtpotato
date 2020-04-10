extends Control

onready var refueling_pad: RefuelingPad = get_node('../')
onready var energy = $DebugEnergyBar/DebugAmount
onready var delay = $DebugDelayBar/DebugAmount

func _process(delta: float):
  if refueling_pad != null:
    energy.rect_scale = Vector2(clamp(refueling_pad.current_energy / refueling_pad.energy_max, 0.0, 1.0), 1.0)
    delay.rect_scale = Vector2(clamp(refueling_pad.regen_delay / refueling_pad.delay_before_energy_regen, 0.0, 1.0), 1.0)
