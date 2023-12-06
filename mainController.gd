extends Node

#References
@onready var player = $player
#ALSO NOTE: In comments I have included an index at the bottom of this code for easier management of what is linked to what

#Inventory Items
var officeKey = false
#bookKey 1 is from file cabinet, 2 is actual key for it
var bookKey = false
var bookKey2 = false
var fingerKey = false

#Passwords
@export var portrait1Pass = "Darwin"
@export var fileCabinetPass = "B_G_R_Y"
@export var fileCabinetPass2 = "b_g_r_y"
#@export var fileCabinetPass3 = "BLUE_GREEN_RED_YELLOW"

signal solvedPuzzle

#Flags
var fileFlag = false


#This code gets called whenever a layer3 object is detected by the player raycast. It has two inputs, number and a 
#string which are both obtained from the metadata of the interacted object. ObjectID determiens for this script
#which object is being looked at and inputString determines what text was inputted during that segment.
func _on_player_pass_input(objectID, inputString):
	#Office input Puzzles
	if (objectID == 1):
		if (inputString == fileCabinetPass || inputString == fileCabinetPass2 ||fileFlag):
			fileFlag = true
			bookKey = true
			emit_signal("solvedPuzzle")
			player.descUI.text = "Inside is a page torn from a book. Written in big bold letters reads “In Cold Blood”. This must correlate to something, perhaps a book on the shelf?"
		elif (inputString != fileCabinetPass):
			player.descUI.text = "It isn't budging, guess that wasn't the right code."
	if(objectID == 5):
		if (inputString == portrait1Pass):
			player.descUI.text = "Wow that for sure did something :smile:"

func _on_player_item_check(objectID):
	if (objectID == 2):
		if bookKey2:
			player.descUI.text = '"In Cold Blood,” This must be where that key belongs! Flipping open the book, nestled deep in the pages of the thick carved book is a plump bloody heart, wrapped in a plastic bag.'
		elif bookKey:
			player.descUI.text = '"In Cold Blood" this must be it! This isn’t even a real book. It’s locked, it sounds like there’s something inside. *slosh*'
		else:
			pass
	if (objectID == 3):
		if officeKey:
			player.descUI.text = "The key fits perfectly, I wonder what else the Doctor is hiding… This is the end of the playtest :smile:"
		else:
			pass
	if (objectID == 4):
		$Office/OmniLight3D.visible = !$Office/OmniLight3D.visible
		player.descUI.visible = false
	if (objectID == 5):
		if fingerKey:
			player.descUI.text = "It worked! A log book? Maybe I can find something about myself."
		else:
			pass

#INDEX:
#1 - FileCabinet
#2 - "Cold Blood" Book
#3 - OfficeDoor
#4 - Lamp
#5 - OfficeSafe
