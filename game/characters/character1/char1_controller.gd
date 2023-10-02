extends KinematicBody

onready var character = $char1
onready var anim_tree = $char1/AnimationTree
onready var state_machine = anim_tree['parameters/playback']

var velocity = Vector3.ZERO
var direction = Vector3.ZERO
var timer = 0
var minTimeBetweenTick = 1/60.0
var currentTick = 0

func state():
	return state_machine.get_current_node()
	
func travel(state):
	state_machine.travel(state)

func _on_Controls_direction_vector(dir):
	direction = dir

func _process(delta):
	timer += delta
	
	while timer >= minTimeBetweenTick:
		timer -= minTimeBetweenTick
		HandleTick()
		currentTick += 1
		
func HandleTick():
	var clientInput = {}
	clientInput['D'] = direction
	clientInput['R'] = character.rotation.y
	clientInput['S'] = state()
	ProcessInput(clientInput)
	
func ProcessInput(input):
	velocity = Vector3.ZERO
	if input['S'] == 'idle':
		if input['D'] == Vector3.ZERO:
			pass
		else:
			travel('run')
	elif input['S'] == 'run':
		if input['D'] == Vector3.ZERO:
			travel('idle')
		else:
			character.rotation.y = lerp_angle(input["R"], 
			atan2(input["D"].x, input["D"].z), minTimeBetweenTick*10)
			velocity = 50.0 * input['D']
	move_and_collide(velocity * minTimeBetweenTick);
