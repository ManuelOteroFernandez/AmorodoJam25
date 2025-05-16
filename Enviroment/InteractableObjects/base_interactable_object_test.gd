extends BaseInteractableObject

func do_action(sender:Player):
	super.do_action(sender)
	print("asd")
	get_tree().create_timer(5).timeout.connect(end_action)
	
func end_action():
	super.end_action()
	
