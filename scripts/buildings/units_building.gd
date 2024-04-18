extends Building
class_name UnitBuilding

func _ready() -> void:
	super._ready()
	building_type = building_types.UNIT_BUILDING
	cost = 300
	unit_img = preload("res://assets/GUI/UnitBuildingImg.jpg")
