class_name  Worker
extends Unit


func _ready() -> void:
	super._ready()
	unit_type = unit_types.WORKER
	cost = 35
	damage = 5
	unit_img = preload("res://assets/GUI/WorkerImg.jpg")
