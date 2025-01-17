extends CharacterBody3D

#Player stats
var SPEED = 4

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#Player camera References
var look_dir: Vector2
@onready var camera = $Camera3D
var camera_sens = 23
@onready var aim = $Camera3D/lookDetect
var lookedObject
@onready var footSounds = $footSounds

#Main scene references + signals
@onready var scene = $".."
signal passInput(objectID, inputString)
signal itemCheck(objectID)

#Player UI References
@onready var descUI = $UIControl/InfoText
@onready var inputUI = $UIControl/LineEdit
var capMouse = true
var inputting = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#descUI.visible = false
	inputUI.visible = false
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 1, input_dir.y)).normalized()
	var is_moving = input_dir.length() > 0

	if is_moving && !inputting:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if !footSounds.is_playing() && is_on_floor():
			footSounds.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		footSounds.stop()
		
	#Interact function: runs when the raycast is colliding with a properly layered object and "enter" is pressed
	if  aim.is_colliding() && Input.is_action_just_pressed("interact") && !inputting:
		lookedObject = aim.get_collider()
		descUI.text = "" + lookedObject.get_meta("interactText")
		lookingAt()
	
	if Input.is_action_just_pressed("pause"):
		if descUI.visible == true:
			descUI.visible = false
		else:
			capMouse = !capMouse
		if capMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("input") && inputting: 
		passInput.emit(lookedObject.get_meta("objectID"), inputUI.text) 
		inputUI.visible = false
		inputting = false
	
	_rotate_camera(delta)
	move_and_slide()

	# Head bob - now tied to input rather than velocity
	if is_moving && is_on_floor():
		t_bob += delta * BOB_FREQ
	camera.transform.origin = _headbob(t_bob)
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP + 0.6
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01

func _rotate_camera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	look_dir += input
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func lookingAt():
	descUI.visible = true
	if lookedObject.get_collision_mask_value(3) == true:
		inputUI.clear()
		inputUI.visible = true
		inputUI.grab_focus()
		inputting = true
	if lookedObject.get_collision_mask_value(4) == true:
		itemCheck.emit(lookedObject.get_meta("objectID"))

func _on_main_solved_puzzle():
	inputUI.clear()
	inputUI.visible = false
	inputting = false

func _on_area_3d_body_entered(body):
	descUI.text = "Press E to go to up the stairs."
	descUI.visible = true

func _on_main_not_blind():
	$UIControl/Blind.visible = false

func _on_main_button_select():
	$"UIControl/Stay Button".visible = true
	$"UIControl/Stay Button".disabled = false
	$UIControl/LeaveButton.visible = true
	$UIControl/LeaveButton.disabled = false

func _on_leave_button_pressed():
	$"../AudioFiles/Endings/leaveEnding".play()
	$"UIControl/Stay Button".visible = false
	$"UIControl/Stay Button".disabled = true
	$UIControl/LeaveButton.visible = false
	$UIControl/LeaveButton.disabled = true
	await get_tree().create_timer(44).timeout
	get_tree().change_scene_to_file("res://title.tscn")

func _on_stay_button_pressed():
	$"../AudioFiles/Endings/stayEnding".play()
	$"UIControl/Stay Button".visible = false
	$"UIControl/Stay Button".disabled = true
	$UIControl/LeaveButton.visible = false
	$UIControl/LeaveButton.disabled = true
	await get_tree().create_timer(30).timeout
	get_tree().change_scene_to_file("res://title.tscn")
