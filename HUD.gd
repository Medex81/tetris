extends MarginContainer

var color_blue = Color(0, 0, 1, 1)
var color_invisible = Color(0, 0, 1, 0)
var color_white = Color(1, 1, 1, 1)

func _ready():
	# Очистка области превью
	init()
	
func init():
	# Очистка области превью
	set_preview([])
	set_final("", color_white)
	set_level(1)
	set_level_percent(0)
	set_score(0)

func set_preview(a_shape):
	#Очистить область
	for i in range($VBoxContainer/VBoxPreview/ShapePreview.get_child_count()):
		$VBoxContainer/VBoxPreview/ShapePreview.get_child(i).color = color_blue if i in a_shape else color_invisible
		
func set_final(final_str, txt_color = color_white):
	$VBoxContainer/Final.text = final_str
	$VBoxContainer/Final.set("custom_colors/font_color", txt_color)
	
func set_level(new_level):
	$VBoxContainer/VBoxStatistic/LevelContainer/Level_current.text = str(new_level)
	$VBoxContainer/VBoxStatistic/LevelContainer/Level_next.text = str(new_level + 1)
	
func set_score(score):
	$VBoxContainer/VBoxStatistic/ScoreContainer/Score.text = str(score)
	
func set_level_percent(percent):
	$VBoxContainer/VBoxStatistic/LevelContainer/TextureProgress.value = clamp(percent, 0, 100)	

func _on_GridContainer_final_hud(text, color):
	set_final(text, color)

func _on_GridContainer_init_hud():
	init()

func _on_GridContainer_set_level(level):
	set_level(level)

func _on_GridContainer_set_level_percent(percent):
	set_level_percent(percent)


func _on_GridContainer_set_score(score):
	set_score(score)


func _on_GridContainer_set_preview(idxs):
	set_preview(idxs)
