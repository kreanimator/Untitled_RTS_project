extends Control

var unit_img_button = preload("res://scenes/units/unit_img_button.tscn")
var current_units : Array = []
@onready var units_grid: GridContainer = $GuiHbox/InfoBar/UnitHbox/UnitsGrid

#Units and buildings scenes
const MAIN_BUILDING : PackedScene = preload("res://scenes/buildings/main_building.tscn")
const UNITS_BUILDING : PackedScene = preload("res://scenes/buildings/units_building.tscn")
const WORKER_UNIT : PackedScene = preload("res://scenes/units/worker.tscn")
const WARRIOR_UNIT : PackedScene = preload("res://scenes/units/warrior.tscn")

#Units and buildings images
const MAIN_BUILDING_IMG : CompressedTexture2D = preload("res://assets/GUI/MainBuildingImg.jpg")
const UNITS_BUILDING_IMG : CompressedTexture2D = preload("res://assets/GUI/UnitBuildingImg.jpg")
const WORKER_UNIT_IMG : CompressedTexture2D = preload("res://assets/GUI/WorkerImg.jpg")
const WARRIOR_UNIT_IMG : CompressedTexture2D = preload("res://assets/GUI/WarriorImg.jpg")

@onready var main_unit_img: TextureRect = $GuiHbox/InfoBar/UnitHbox/MainUnitImgContainer/MainUnitImg
@onready var sel_bar_grid_container: GridContainer = $GuiHbox/SelectionBar/SelBarGridContainer
@onready var option_button_1_img: TextureButton = $GuiHbox/SelectionBar/SelBarGridContainer/OptionButton1
@onready var option_button_2_img: TextureButton = $GuiHbox/SelectionBar/SelBarGridContainer/OptionButton2
var button_one_unit
var button_two_unit

func _ready() -> void:
	SignalManager.units_selected.connect(_on_rts_controller_units_selected)


	
func _on_rts_controller_units_selected(units) -> void:
	current_units = units
	for n in units_grid.get_children():
		units_grid.remove_child(n)
		n.queue_free()
	for i in range(1, len(units)):
		var img_button = unit_img_button.instantiate()
		units_grid.add_child(img_button)
		img_button.texture_normal = units[i].unit_img
		
	main_unit_img.texture = current_units[0].unit_img
	set_button_images()
	
func hide_buttons() -> void:
	for button in sel_bar_grid_container.get_children():
		button.visible = false
	
func show_buttons(active_buttons_num) -> void:
	hide_buttons()
	for button in range(active_buttons_num):
		sel_bar_grid_container.get_child(button).visible = true



func _on_option_button_1_pressed() -> void:
	pass # Replace with function body.


func _on_option_button_2_pressed() -> void:
	pass # Replace with function body.
	
func set_button_images() -> void:
	if current_units[0] is MainBuilding:
		show_buttons(1)
		button_one_unit = WORKER_UNIT
		option_button_1_img.texture_normal = WORKER_UNIT_IMG
	if current_units[0] is UnitBuilding:
		show_buttons(1)
		button_one_unit = WARRIOR_UNIT
		option_button_1_img.texture_normal = WARRIOR_UNIT_IMG
	elif current_units[0] is Worker:
		show_buttons(2)
		button_one_unit = MAIN_BUILDING
		option_button_1_img.texture_normal = MAIN_BUILDING_IMG
		button_two_unit = MAIN_BUILDING
		option_button_2_img.texture_normal = UNITS_BUILDING_IMG
	elif current_units[0] is Warrior:
		show_buttons(0)
