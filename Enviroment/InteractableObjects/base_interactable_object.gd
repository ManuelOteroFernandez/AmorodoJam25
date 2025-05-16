class_name BaseInteractableObject extends Node2D

var player:Player

func do_action(sender:Player):
	player = sender


func end_action():
	player.end_interaction()
