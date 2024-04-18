extends Node3D

const MOVE_MARGIN : int = 20
const MOVE_SPEED : int = 15
@onready var camera_3d: Camera3D = $Camera3D
var m_pos : Vector2
var team : int = 0
const RAY_LENGTH : int = 1000
var selected_units : Array = []
var old_selected_units : Array = []
var start_sel_position : Vector2
@onready var fps: Label = $"../UI/FPS"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("command"):
		move_selected_units()
	m_pos = get_viewport().get_mouse_position()
	camera_movement(delta)
	if Input.is_action_just_pressed("select"):
		start_sel_position = m_pos
	if Input.is_action_just_released("select"):
		select_units()
		
	debug()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel_down"):
		camera_3d.fov = lerp(camera_3d.fov,75.0,0.25)
	if event.is_action_pressed("wheel_up"):
		camera_3d.fov = lerp(camera_3d.fov,45.0,0.25)

func camera_movement(delta) -> void:
	var viewport_size = get_viewport().size
	var origin : Vector3 = global_transform.origin
	var move_vec := Vector3()
	if origin.x > -62:
		if m_pos.x < MOVE_MARGIN:
			move_vec.x -= 1
	if origin.z > -65:
		if m_pos.y < MOVE_MARGIN:
			move_vec.z -= 1
	if origin.x < 62:
		if m_pos.x > viewport_size.x - MOVE_MARGIN:
			move_vec.x += 1
	if origin.z < 90:
		if m_pos.y > viewport_size.y - MOVE_MARGIN:
			move_vec.z += 1
			
	move_vec = move_vec.rotated(Vector3(0,1,0), rad_to_deg(rotation.y))
	global_translate(move_vec * delta * MOVE_SPEED)


func mouse_raycast(collision_mask):
	var ray_start : Vector3 = camera_3d.project_ray_origin(m_pos)
	var ray_end : Vector3 = ray_start + camera_3d.project_ray_normal(m_pos) * RAY_LENGTH
	var space_state =get_world_3d().direct_space_state
	var prqp := PhysicsRayQueryParameters3D.new()
	prqp.from = ray_start
	prqp.to = ray_end
	prqp.collision_mask = collision_mask
	prqp.exclude = []
	return space_state.intersect_ray(prqp)
	
func get_unit_from_mouse() :
	var result_unit = mouse_raycast(2)
	if result_unit and "team" in result_unit.collider and result_unit.collider.team == team:
		var selected_unit = result_unit.collider
		return selected_unit
		
func select_units() -> void:
	var main_unit = get_unit_from_mouse()
	if selected_units.size() !=0:
		old_selected_units =selected_units
	selected_units = []
	if m_pos.distance_squared_to(start_sel_position) < 16:
		if main_unit != null:
			selected_units.append(main_unit)
			
	if selected_units.size() != 0:
		clean_current_units_and_select_new(selected_units)
	elif selected_units.size() == 0:
		selected_units = old_selected_units 
			
func  clean_current_units_and_select_new(new_units) -> void:
	for unit in get_tree().get_nodes_in_group("units"):
		unit.deselect()
	for unit in new_units:
		unit.select()

func move_selected_units() -> void:
	var result = mouse_raycast(0b100111)
	if selected_units.size() != 0:
		var first_unit = selected_units[0]
		if result.collider.is_in_group("surface"):
			first_unit.move_to(result.position)
			
func debug() -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
