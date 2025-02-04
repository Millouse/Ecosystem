extends Node3D

var genes = {
	"color" = Color(randf(), randf(), randf()),
	"attention_span" = randf(),
	"speed" = randf(),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
