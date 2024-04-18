extends RigidBody3D

var speed : float
var vel : Vector3
var state_machine
enum states {IDLE,WALKING,ATTACKING,MINING,BUILDING}
var current_state = states.IDLE
var team : int = 0
var team_colors : Dictionary = {
	0: preload("res://assets/Materials/TeamBlueMat.tres"),
	1: preload("res://assets/Materials/TeamRedMat.tres")
}
@onready var nav_a: NavigationAgent3D = $NavigationAgent3D

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var armature: Node3D = $Armature
@onready var animation_tree: AnimationTree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")
	speed = 0
	selection_ring.hide()
	if team in team_colors:
		selection_ring.material_override = team_colors[team]

func _process(delta: float) -> void:
	var target = nav_a.get_next_path_position()
	var pos = get_global_transform().origin
	
	var n = ray_cast_3d.get_collision_normal()
	if n.length_squared() < 0.001:
		n = Vector3(0,1,0)
	vel = (target - pos).slide(n).normalized() * speed
	armature.rotation.y = lerp_angle(armature.rotation.y, atan2(vel.x, vel.z), delta * 10)
	nav_a.set_velocity(vel)
	
func select()-> void:
	selection_ring.show()
	
func deselect()-> void:
	selection_ring.hide()
	
func change_state(state) -> void:
	match state:
		"idle":
			current_state = states.IDLE
			speed = 0.000001
			state_machine.travel("Idle")
		"walking":
			current_state = states.WALKING
			state_machine.travel("Walk")
			speed = 2
			
func move_to(target_pos) -> void:
	change_state("walking")
	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().get_navigation_map(),target_pos)
	nav_a.set_target_position(closest_pos)
	
func look_at_target(target_pos) -> void:

	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().get_navigation_map(), target_pos)
	nav_a.set_target_position(closest_pos)
	
func _on_navigation_agent_3d_target_reached() -> void:
	change_state("idle")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	set_linear_velocity(safe_velocity)
