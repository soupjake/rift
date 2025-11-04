extends CharacterBody2D

@onready var animations := $AnimatedSprite2D
@onready var jump_buffer_timer := $JumpBufferTimer
@onready var coyote_timer := $CoyoteTimer

const SPEED := 160.0
const ACCELERATION := 10.0
const JUMP_VELOCITY := -SPEED * 2
const GRAVITY := SPEED * 5
const DOWN_GRAVITY_FACTOR := 1.5

enum State{IDLE, WALK, JUMP, DOWN}
var current_state := State.IDLE

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
		
	update_movement(delta)
	handle_input(direction)
	update_state(direction)
	update_animation(direction)
	move_and_slide()
	

func handle_input(direction: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
	
	if direction:
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ACCELERATION)

func update_movement(delta: float) -> void:
	if (is_on_floor() || coyote_timer.time_left > 0) && jump_buffer_timer.time_left > 0:
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP
		jump_buffer_timer.stop()
		coyote_timer.stop()
		
	if current_state == State.JUMP:
		velocity.y += GRAVITY * delta
	else:
		velocity.y += GRAVITY * DOWN_GRAVITY_FACTOR * delta
		
func update_state(direction: float) -> void:
	match current_state:
		State.IDLE when direction != 0:
			current_state = State.WALK

		State.WALK:
			if direction == 0:
				current_state = State.IDLE
			if not is_on_floor() and velocity.y > 0:
				current_state = State.DOWN
				coyote_timer.start()

		State.JUMP when velocity.y > 0:
			current_state = State.DOWN

		State.DOWN when is_on_floor():
			if direction == 0:
				current_state = State.IDLE
			else:
				current_state = State.WALK

func update_animation(direction: float) -> void:
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
		
	match current_state:
		State.IDLE: animations.play("idle")
		State.WALK: animations.play("walk")
		State.JUMP: animations.play("jump")
		State.DOWN: animations.play("down")
