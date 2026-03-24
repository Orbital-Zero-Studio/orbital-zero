extends StaticBody3D

const SPACESHIP_MODEL_PATH = "res://Player/spaceship part 1.blend"

func _ready() -> void:
	# Load and instance the spaceship mesh from the blend file
	var spaceship_scene = load(SPACESHIP_MODEL_PATH)
	if spaceship_scene:
		var spaceship_instance = spaceship_scene.instantiate()
		add_child(spaceship_instance)
		
		# Auto-generate a convex collision shape from the mesh
		_generate_collision(spaceship_instance)
	else:
		push_warning("Spaceship: Could not load model from " + SPACESHIP_MODEL_PATH)

func _generate_collision(model_node: Node) -> void:
	# Find all MeshInstance3D children and create collision shapes
	var mesh_instances = _find_mesh_instances(model_node)
	for mesh_inst in mesh_instances:
		if mesh_inst.mesh:
			var collision_shape = CollisionShape3D.new()
			var shape = mesh_inst.mesh.create_convex_shape(true, true)
			collision_shape.shape = shape
			collision_shape.global_transform = mesh_inst.global_transform
			add_child(collision_shape)
			break  # Use the first mesh for collision

func _find_mesh_instances(node: Node) -> Array:
	var result = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_mesh_instances(child))
	return result
