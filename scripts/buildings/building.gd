class_name Building
extends StaticBody3D

var team : int = 0
var team_colors : Dictionary = {
	0: preload("res://assets/Materials/TeamBlueMat.tres"),
	1: preload("res://assets/Materials/TeamRedMat.tres")
}
var unit_img = preload("res://assets/GUI/MainBuildingImg.jpg")

enum building_types {MAIN_BUILDING, UNIT_BUILDING}
var building_type 

var spawning_unit
var spawning_img

var units_to_spawn : Array =[]
var under_cons : bool = false

var cost : int = 200
var max_units : int = 4
var current_created_units : int = 0
var units_images: Array = []
var unit_building
var can_build = true

var health : int = 100
var progress_start : float = 10.0
var active : bool = false
var is_rotating : bool = false

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var unit_destination: MeshInstance3D = $UnitDestination
@onready var unit_spawn_point: Marker3D = $UnitSpawnPoint


func _ready() -> void:
	add_to_group("units")
	deselect()
	if team in team_colors:
		selection_ring.material_override = team_colors[team]
	unit_destination.position = unit_spawn_point.position + Vector3(0.1,0,0.1)

func select() -> void:
	selection_ring.visible = true
	unit_destination.visible = true

func deselect() -> void:
	selection_ring.visible = false
	unit_destination.visible = false
