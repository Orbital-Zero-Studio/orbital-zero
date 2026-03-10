extends CharacterBody3D

# Movement speed
const SPEED = 50.0
const ASCEND_SPEED = 20.0
const GRAVITY = 9.8
@onready var enter_zone: Area3D = $EnterZone

# State
var pilot: CharacterBody3D = null          # player currently piloting
var player_nearby: CharacterBody3D = null  # player standing close enough to enter

# ─── Ready ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	enter_zone.body_entered.connect(_on_body_entered)
	enter_zone.body_exited.connect(_on_body_exited)

# ─── Proximity Detection ───────────────────────────────────────────────────────

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_nearby = body

func _on_body_exited(body: Node3D) -> void:
	if body == player_nearby:
		player_nearby = null

# ─── Input ─────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	# F key — enter or exit
	if event is InputEventKey and event.keycode == KEY_F and event.pressed and not event.echo:
		if pilot != null:
			_exit_spaceship()
		elif player_nearby != null:
			_enter_spaceship(player_nearby)
		return

	# Mouse look only active while piloting
	if pilot == null:
		return

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ─── Enter / Exit ──────────────────────────────────────────────────────────────

func _enter_spaceship(player: CharacterBody3D) -> void:
	pilot = player
	if pilot.has_method("on_enter_spaceship"):
		pilot.on_enter_spaceship()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_spaceship() -> void:
	# Place player to the right side of the ship at ground level
	var exit_pos = global_position + global_transform.basis.x * 2.5
	exit_pos.y = global_position.y
	if pilot.has_method("on_exit_spaceship"):
		pilot.on_exit_spaceship(exit_pos)
	pilot = null

# ─── Per-frame: movement + TPP camera ─────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if pilot == null:
		# Apply gravity even when empty so it doesn't float away
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		else:
			velocity.x = 0
			velocity.z = 0
		move_and_slide()
		return

	# Apply gravity by default
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var ship_basis := global_transform.basis
	var is_thrusting_up = Input.is_key_pressed(KEY_UP)
	
	# Vertical movement (override gravity if thrusting)
	if is_thrusting_up:
		velocity.y = ASCEND_SPEED
	elif Input.is_key_pressed(KEY_DOWN):
		velocity.y = -ASCEND_SPEED

	const TURN_SPEED = 2.0

	# Only allow horizontal movement if we are in the air or taking off
	if not is_on_floor() or is_thrusting_up:
		var turn_input = 0.0
		if Input.is_key_pressed(KEY_A):
			turn_input += 1.0  # Turn left
		if Input.is_key_pressed(KEY_D):
			turn_input -= 1.0  # Turn right

		if turn_input != 0.0:
			rotate_y(turn_input * TURN_SPEED * delta)
			# Refresh basis after rotating so forward/backward use the new direction
			ship_basis = global_transform.basis

		var move_dir := Vector3.ZERO
		
		if Input.is_key_pressed(KEY_W):
			move_dir += ship_basis.x          # forward
		if Input.is_key_pressed(KEY_S):
			move_dir -= ship_basis.x          # backward
		
		if move_dir.length_squared() > 0.0:
			move_dir = move_dir.normalized()
			
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		# Landed and not trying to take off — kill horizontal speed
		velocity.x = lerp(velocity.x, 0.0, 5.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 5.0 * delta)

	move_and_slide()
