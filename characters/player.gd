extends CharacterBody3D

#Player constants
const SPEED = 4

#Player camera References
var look_dir: Vector2
@onready var camera = $Camera3D
var camera_sens = 35
@onready var aim = $Camera3D/lookDetect
var lookedObject

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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && !inputting:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	#Interact function: runs when the raycast is colliding with a properly layered object and "enter" is pressed
	#not runnable when player is inputting something to avoid clearing text
	if  aim.is_colliding() && Input.is_action_just_pressed("interact") && !inputting:
		lookedObject = aim.get_collider()
		#This line here draws the text to be displayed from a metadata variable added in the static body of the looked at object
		#This must be a string named interactText and the static body must be on collision layer 2 to avoid null values
		descUI.text = "" + lookedObject.get_meta("interactText")
		lookingAt()
	
	#"Pause" function, pressing "escape" will make mouse unhidden and unlocked, also checks first to see if text UI
	#Is up and removes it first if it is.
	if Input.is_action_just_pressed("pause"):
		if descUI.visible == true:
			descUI.visible = false
		else:
			capMouse = !capMouse
		if capMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	#This submits the text field with checks to make sure it happens only when meant too.
	if Input.is_action_just_pressed("input") && inputting: 
		#This signal gets the object ID from metadata and then the inputted text and sends it to the main scene code
		passInput.emit(lookedObject.get_meta("objectID"), inputUI.text) 
		inputUI.visible = false
		inputting = false
		#descUI.visible = false
	
	_rotate_camera(delta)
	move_and_slide()

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01

func _rotate_camera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	look_dir += input
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

#This function manages code for various effects when interacting with certain objects.
func lookingAt():
	descUI.visible = true
	#Layer three input controls for text input puzzles
	if lookedObject.get_collision_mask_value(3) == true:
		inputUI.clear() #This clears all previous text stored in the Line Edit node
		inputUI.visible = true #This makes the input field visible
		inputUI.grab_focus() #This grabs focus for the input field
		inputting = true #This sets a flag to disable traditional movement
	#
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
