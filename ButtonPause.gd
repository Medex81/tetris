extends Button

const save_section = "btn_pause"

func _on_ButtonPause_toggled(button_pressed):
	text = "PAUSE" if !button_pressed else "CONTINUE"

func _on_GridContainer_start_button_init(state_run):
	if state_run:
		text = "PAUSE"
		pressed = false
	else:
		text = "CONTINUE"
		pressed = true
		disabled = false

func _on_ButtonStart_toggled(button_pressed):
	disabled = !button_pressed
	text = "PAUSE"
	
func _ready():
	deserialize()

func _exit_tree():
	serialize()
	
func serialize():
	var btn_pause = {
		"pressed": pressed,
		"disabled": disabled
		}
	State_mgr.set_dict(save_section, btn_pause)
	
func deserialize():
	var btn_pause = State_mgr.get_dict(save_section)
	pressed = State_mgr.get_value(btn_pause, "pressed", pressed)
	disabled = State_mgr.get_value(btn_pause, "disabled", disabled)
	#_toggled(pressed)
