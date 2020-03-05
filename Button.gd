extends Button

const save_section = "btn_start"

func _on_ButtonStart_toggled(button_pressed):
	text = "STOP" if button_pressed else "START"
	
func _on_GridContainer_start_button_init(state_run):
	text = "STOP"
	pressed = false
	
func _ready():
	deserialize()

func _exit_tree():
	serialize()
	
func serialize():
	var btn_start = {"pressed": pressed}
	State_mgr.set_dict(save_section, btn_start)
	
func deserialize():
	var btn_start = State_mgr.get_dict(save_section)
	pressed = State_mgr.get_value(btn_start, "pressed", pressed)
	#toggled(pressed)
