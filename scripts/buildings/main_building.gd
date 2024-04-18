extends Building
class_name MainBuilding

func _ready() -> void:
	super._ready()
	building_type = building_types.MAIN_BUILDING
	cost = 500
	unit_img = preload("res://assets/GUI/MainBuildingImg.jpg")



