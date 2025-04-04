class_name NodeStateMachine
extends Node

@export var initial_node_state : NodeState

var node_states : Dictionary = {}
var current_node_state : NodeState
var current_node_state_name : String
var parent_node_name: String


func _ready() -> void:
    # Set the parent node name
    parent_node_name = get_parent().name
    
    # Populate the node_states dictionary with child nodes that are NodeState
    for child in get_children():
        if child is NodeState:
            node_states[child.name.to_lower()] = child
            child.transition.connect(transition_to)
    
    # Set the initial state if it exists
    if initial_node_state:
        initial_node_state._on_enter()
        current_node_state = initial_node_state
        current_node_state_name = current_node_state.name.to_lower()


func _process(delta : float) -> void:
    # Call the _on_process function of the current state
    if current_node_state:
        current_node_state._on_process(delta)


func _physics_process(delta: float) -> void:
    # Call the _on_physics_process and _on_next_transitions functions of the current state
    if current_node_state:
        current_node_state._on_physics_process(delta)
        current_node_state._on_next_transitions()
        print(parent_node_name, " Current State: ", current_node_state_name)


func transition_to(node_state_name : String) -> void:
    # Check if the new state is different from the current state
    if node_state_name == current_node_state.name.to_lower():
        return
    
    # Get the new state node
    var new_node_state = node_states.get(node_state_name.to_lower())
    
    # If the new state node does not exist, return
    if !new_node_state:
        return
    
    # Call the _on_exit function of the current state
    if current_node_state:
        current_node_state._on_exit()
    
    # Call the _on_enter function of the new state
    new_node_state._on_enter()
    
    # Update the current state and state name
    current_node_state = new_node_state
    current_node_state_name = current_node_state.name.to_lower()
    print("Current State: ", current_node_state_name)
