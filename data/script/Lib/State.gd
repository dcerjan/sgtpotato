extends Reference

class_name State

func on_enter():
  pass

func on_leave():
  pass

func on_update(delta: float, state):
  pass
  
func transition_to(state: State):
  self.on_leave()
  state.on_enter()
  return state
