extends GridContainer

onready var gd_tlm = preload("res://tetris_logic_model.gd").new()
const color_white = Color(1, 1, 1, 1)
const color_blue = Color(0, 0, 1, 1)
const color_green = Color(0, 1, 0, 1)
const color_red = Color(1, 0, 0, 1)
const down_speed_reward = 1
const time_sub = 0.01
const time_start = 0.5
const level_start = 1
const save_section = "main_scene"

var a_cells = []
var last_level = level_start
var state_run = true

export (int) var rows = 20
export (int) var cols = 10

signal start_button_init(run)
signal final_hud(text, color)
signal init_hud()
signal set_level(level)
signal set_level_percent(percent)
signal set_score(score)
signal set_preview(idxs)
signal set_time(time_ms)

func _ready():
	gd_tlm.init(cols, rows)
	columns = gd_tlm.col_count
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		var item = ColorRect.new()
		item.rect_min_size = Vector2(20, 20)
		add_child(item)
		a_cells.append(item)
	deserialize()
	if gd_tlm.GameState == gd_tlm.E_RUN:
		unpause()
		
func _input(event):
	eventTime = 0
	get_input()

func get_input():
	if Input.is_action_pressed("ui_down"):
		next_step("ui_down")
		gd_tlm.set_outer_reward(down_speed_reward)
		
	if Input.is_action_pressed("ui_up"):
		next_step("ui_up")
		
	if Input.is_action_pressed("ui_left"):
		next_step("ui_left")
		
	if Input.is_action_pressed("ui_right"):
		next_step("ui_right")
		
var eventTime = 0
func _process(delta):
	eventTime += delta
	# Move discret time
	if eventTime > 0.15:
		eventTime = 0
		get_input()

func unpause():
	$Timer.stop()
	#gd_tlm.start()	
	emit_signal("set_time", $Timer.wait_time * 1000)
	
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		# set white color to the cells
		a_cells[i].color =  color_white		
	
	emit_signal("init_hud")
	emit_signal("set_preview", gd_tlm.get_next_shape_idxs())
	emit_signal ("set_level", gd_tlm.level)
	emit_signal("set_time", int($Timer.wait_time * 1000))
	emit_signal("start_button_init", state_run)
	draw_cells(gd_tlm.model_array)

func _on_Button_pressed():
	$Timer.stop()
	last_level = level_start
	gd_tlm.start()
	$Timer.wait_time = time_start
	emit_signal("set_time", $Timer.wait_time * 1000)
	
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		# set white color to the cells
		a_cells[i].color =  color_white
		
	$Timer.start()	
	emit_signal("init_hud")
	emit_signal("set_preview", gd_tlm.get_next_shape_idxs())
	draw_cells(gd_tlm.model_array)
	
func serialize():	
	var main_scene = {
	"last_level": last_level,
	"state_run": state_run,
	"Timer_wait_time": $Timer.wait_time}
	State_mgr.set_dict(save_section, main_scene)
	
func deserialize():
	var main_scene = State_mgr.get_dict(save_section)
	last_level = State_mgr.get_value(main_scene, "last_level", last_level)
	$Timer.wait_time = State_mgr.get_value(main_scene, "Timer_wait_time", time_start)
	state_run = State_mgr.get_value(main_scene, "state_run", state_run)
	
func draw_cells(idxs):
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		a_cells[i].color =  color_white if idxs[i] == 0 else color_blue
	
func next_step(direct):
	gd_tlm.next_step(direct)
	draw_cells(gd_tlm.model_array)
		
	if gd_tlm.bMatched:
		emit_signal ("set_level", gd_tlm.level)
		emit_signal ("set_level_percent", gd_tlm.get_level_percent())
		gd_tlm.bMatched = false
		# Increment the level time
		if last_level < gd_tlm.level:
			$Timer.wait_time -= time_sub
			last_level = gd_tlm.level
			emit_signal("set_time", int($Timer.wait_time * 1000))
			
	if gd_tlm.is_close_step():
		emit_signal("set_preview", gd_tlm.get_next_shape_idxs())
		
	emit_signal ("set_score", gd_tlm.score)

func _on_Timer_timeout():
	if !gd_tlm.is_stop():
		next_step("ui_down")
	else:
		$Timer.stop()
		emit_signal("final_hud", "Game over", color_red)
		emit_signal("start_button_init", state_run)
		
		serialize()

func _on_ButtonStart_toggled(button_pressed):
	if button_pressed:
		_on_Button_pressed()
	else:
		$Timer.stop()
		emit_signal("final_hud", "Game stopped", color_red)
	serialize()

func _on_ButtonPause_toggled(button_pressed):
	if button_pressed:
		$Timer.stop()
		emit_signal("final_hud", "Game paused", color_green)
	else:
		$Timer.start()
		emit_signal("final_hud", "", color_green)
	serialize()
	state_run = !button_pressed
