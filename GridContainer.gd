extends GridContainer

onready var gd_tlm = preload("res://tetris_logic_model.gd").new()
var color_white = Color(1, 1, 1, 1)
var color_blue = Color(0, 0, 1, 1)
var color_green = Color(0, 1, 0, 1)
var color_red = Color(1, 0, 0, 1)
var a_cells = []
var down_speed_reward = 1

export (int) var rows = 20
export (int) var cols = 10

signal start_button_enabled(state)
signal final_hud(text, color)
signal init_hud()
signal set_level(level)
signal set_level_percent(percent)
signal set_score(score)
signal set_preview(idxs)

func _ready():
	gd_tlm.init(cols, rows)
	columns = gd_tlm.col_count
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		var item = ColorRect.new()
		item.rect_min_size = Vector2(20, 20)
		add_child(item)
		a_cells.append(item)
		
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
	if eventTime > 0.15:
		eventTime = 0
		get_input()

func draw_cells(idxs):
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		a_cells[i].color =  color_white if idxs[i] == 0 else color_blue

func _on_Button_pressed():
	$Timer.stop()
	gd_tlm.start()	
		
	for i in range(gd_tlm.col_count * gd_tlm.row_count):
		# set white color to the cells
		a_cells[i].color =  color_white
	$Timer.start()
	emit_signal("start_button_enabled", true) #disabled!
	emit_signal("init_hud")
	emit_signal("set_preview", gd_tlm.get_next_shape_idxs())
	
func next_step(direct):
	gd_tlm.next_step(direct)
	draw_cells(gd_tlm.model_array)
	if gd_tlm.bMatched:
		emit_signal ("set_level", gd_tlm.level)
		emit_signal ("set_level_percent", gd_tlm.get_level_percent())
		gd_tlm.bMatched = false
	if gd_tlm.is_close_step():
		emit_signal("set_preview", gd_tlm.get_next_shape_idxs())
	emit_signal ("set_score", gd_tlm.score)

func _on_Timer_timeout():
	if !gd_tlm.is_stop():
		next_step("ui_down")
	else:
		$Timer.stop()
		emit_signal("final_hud", "Game over", color_red)
		emit_signal("start_button_enabled", false) # enabled!
