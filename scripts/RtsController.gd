extends Node3D

const MOVE_MARGIN : int = 20
const MOVE_SPEED : int = 15
@onready var camera_3d: Camera3D = $Camera3D
@onready var unit_selector: Control = $UnitSelector
@export var units_in_circle : int = 6
@export var units_in_line : int = 4

var m_pos : Vector2
var team : int = 0
const RAY_LENGTH : int = 1000
var selected_units : Array = []
var old_selected_units : Array = []
var start_sel_position : Vector2
var target_positions_list : Array[Vector3] = []
var unit_pos_index : int = 0


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
		unit_selector.start_pos = m_pos
		start_sel_position = m_pos
	if Input.is_action_just_released("select"):
		select_units()
	if Input.is_action_pressed("select"):
		unit_selector.m_pos = m_pos
		unit_selector.is_rect_visible = true
	else:
		unit_selector.is_rect_visible = false

		
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
	var result_unit = mouse_raycast(0b110)
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
			
	else:
		selected_units = get_units_in_box(start_sel_position, m_pos)
			
	if selected_units.size() != 0:
		clean_current_units_and_select_new(selected_units)
		SignalManager.units_selected.emit(selected_units)
	elif selected_units.size() == 0:
		selected_units = old_selected_units 
			
func  clean_current_units_and_select_new(new_units) -> void:
	for unit in get_tree().get_nodes_in_group("units"):
		unit.deselect()
	for unit in new_units:
		unit.select()

func move_selected_units() -> void:
	var result = mouse_raycast(0b100111)
	unit_pos_index = 0
	if selected_units.size() != 0:
		#var first_unit = selected_units[0]
		if result.collider.is_in_group("surface"):
			for unit in selected_units:
				position_units(unit, result)
			#first_unit.move_to(result.position)
			
func get_units_in_box(top_left, bot_right) -> Array:
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
		
	var box = Rect2(top_left,bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(camera_3d.unproject_position(unit.global_transform.origin)):
			if box_selected_units.size() <= 24:
				box_selected_units.append(unit)
	return box_selected_units
	
func create_unit_position_in_rect(target_pos: Vector3, units_num : int) -> Array:
	var line_positions_list : Array[Vector3] = []
	var positions_list : Array[Vector3] = []
	var new_target_pos = target_pos
	var x_pos = 1
	var z_pos = 1
	var num_of_lines = ceil(units_num/units_in_line)
	for unit in units_in_line:
		line_positions_list.append(new_target_pos)
		positions_list.append(new_target_pos)
		new_target_pos = Vector3(target_pos.x + x_pos,target_pos.y, target_pos.z)
		if unit%2 == 1:
			x_pos -= 1
		x_pos = -x_pos
		
	for i in num_of_lines:
		for k in units_in_line:
			var new_pos = Vector3(line_positions_list[k].x,line_positions_list[k].y,line_positions_list[k].z + z_pos)
			positions_list.append(new_pos)
		if 1%2 == 1:
			z_pos -= 1
		z_pos = -z_pos
		
	return positions_list
	
func create_unit_position_in_circle(target_pos: Vector3, units_num : int) -> Array:
	var positions_list : Array[Vector3] = []
	var radius : float = 1.0
	var center = Vector2(target_pos.x, target_pos.z)
	var max_units_in_circle = units_in_circle
	var angle_step = PI * 2/ max_units_in_circle
	var angle = 0
	var unit_count = 0 
	for i in range(0, units_num):
		if unit_count == max_units_in_circle:
			radius += 1.0
			unit_count = 0
			angle = 0
			max_units_in_circle += 2
			angle_step = 2 *PI/ max_units_in_circle
		var direction = Vector2(cos(angle), sin(angle))
		var pos = center + direction * radius
		var pos_3d = Vector3(pos.x,0,pos.y)
		positions_list.append(pos_3d)
		unit_count += 1
		angle += angle_step
	return positions_list
	
func position_units(unit, result):
	#target_positions_list = create_unit_position_in_circle(result.position,len(selected_units))
	target_positions_list = create_unit_position_in_circle(result.position,len(selected_units))
	unit.move_to(target_positions_list[unit_pos_index])
	unit_pos_index += 1
func debug() -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	

