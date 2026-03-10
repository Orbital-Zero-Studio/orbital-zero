extends Node3D

const SPACESHIP_SCENE_PATH = "res://Spaceship/Spaceship.tscn"

func _ready() -> void:
	_spawn_spaceship()

func _spawn_spaceship() -> void:
	var spaceship_scene = load(SPACESHIP_SCENE_PATH)
	if spaceship_scene:
		var spaceship = spaceship_scene.instantiate()
		# Position the spaceship in the world - slightly elevated and offset from origin
		spaceship.position = Vector3(10, 0.5, -5)
		# Rotate it so it faces a nice direction
		spaceship.rotation_degrees = Vector3(0, 45, 0)
		spaceship.name = "Spaceship"
		add_child(spaceship)
		print("Spaceship added to world at position: ", spaceship.position)
	else:
		push_warning("World: Could not load spaceship scene from " + SPACESHIP_SCENE_PATH)
