extends Node

#References
@onready var player = $player
#ALSO NOTE: In comments I have included an index at the bottom of this code for easier management of what is linked to what

#Inventory Items
var officeKey = false
#bookKey 1 is from file cabinet, 2 is actual key for it
var bookKey = false
var fingerKey = false
var brainKey = false
var morgueKey = false
var scalpelKey = false
var autop1Key = false
var autop2Key = false
var sawKey = false
var lungKey = false
#The actual key
var autopsy2GigaKey = false
#Used to make sure the body doesn't try and make the now deleted eyeball visible again
var eyeFlag = false
var frameCount = 0

#Passwords
@export var portrait1Pass = "Darwin"
@export var fileCabinetPass = "B_G_R_Y"
@export var fileCabinetPass2 = "b_g_r_y"
#@export var fileCabinetPass3 = "BLUE_GREEN_RED_YELLOW"

signal solvedPuzzle
signal notBlind

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
	if (objectID == 6):
		if (autop1Key || inputString == "424"):
			if (player.global_position.distance_to($Autopsy1/Autopsy1Door/Pos1.global_position) > player.global_position.distance_to($Autopsy1/Autopsy1Door/Pos2.global_position)):
				player.global_position = $Autopsy1/Autopsy1Door/Pos1.global_position
				
			else: player.global_position = $Autopsy1/Autopsy1Door/Pos2.global_position
			autop1Key = true
		else: player.descUI.text = "It's still not budging."
	if (objectID == 9):
		if (autop2Key || inputString == "24/7/25"):
			if (player.global_position.distance_to($Autopsy2/Autopsy2Door/Pos1.global_position) > player.global_position.distance_to($Autopsy2/Autopsy2Door/Pos2.global_position)):
				player.global_position = $Autopsy2/Autopsy2Door/Pos1.global_position
			else: player.global_position = $Autopsy2/Autopsy2Door/Pos2.global_position
			autop2Key = true
			player.descUI.text = ""
		else: player.descUI.text = "There seems to be some scratches on the door, 'DD/DD/DDDD' it looks like."

func _on_player_item_check(objectID):
	if (objectID == 2):
		if (bookKey):
			if autopsy2GigaKey:
					player.descUI.text = '"In Cold Blood,” This must be where that key belongs! Flipping open the book, nestled deep in the pages of the thick carved book is a plump bloody heart. I have set it on the desk.'
					$Office/heart.visible = true
					$Office/heart/StaticBody3D/CollisionShape3D.disabled = false
			elif bookKey:
					player.descUI.text = '"In Cold Blood" this must be it! This isn’t even a real book. It’s locked, it sounds like there’s something inside. *slosh*'
		else: pass
	if (objectID == 3):
		player.global_position = $Courtyard/Courtyard/StairBody/StairExit.global_position
	if (objectID == 4):
		$Office/LampLight.visible = !$Office/LampLight.visible
		player.descUI.visible = false
	if (objectID == 5):
		if fingerKey:
			player.descUI.text = "It worked! A log book? Maybe I can find something about myself."
			$Office/LogBook.visible = true
			$Office/LogBook/StaticBody3D/CollisionShape3D.disabled = false
		else:
			pass
	if (objectID == 7):
		if (brainKey):
			if (morgueKey):
				if (player.global_position.distance_to($Autopsy1/Autopsy1Door2/Pos1.global_position) > player.global_position.distance_to($Autopsy1/Autopsy1Door2/Pos2.global_position)):
					player.global_position = $Autopsy1/Autopsy1Door2/Pos1.global_position
				else: player.global_position = $Autopsy1/Autopsy1Door2/Pos2.global_position
			elif (brainKey): player.descUI.text = "It’s locked. Must be a way to unlock this door."
		else: pass
	if (objectID == 8):
		brainKey = true
		$Morgue/Brain.queue_free()
	if (objectID == 10):
		player.global_position = $Courtyard/Courtyard/StairBody/OfficeEntrance.global_position
	if (objectID == 11):
		if (brainKey):
			morgueKey = true
			$Morgue/Key.queue_free()
		else: player.descUI.text = ""
	if (objectID == 12):
		scalpelKey = true
		$Autopsy1/Scalpel.queue_free()
	if (objectID == 13):
		if (brainKey):
			if (scalpelKey && !eyeFlag):
				player.descUI.text = "They don’t need two eyes; after all, they’re already dead."
				$Morgue/Eyeball.visible = true
			elif eyeFlag: player.descUI.text = "It's missing an eye now."
		else: player.descUI.text = ""
	if (objectID == 14):
		emit_signal("notBlind")
		eyeFlag = true
		$Morgue/Eyeball.queue_free()
	if (objectID == 15):
		$Autopsy1/Clue1.global_position = $Clue1Pos.global_position
		frameCount += 1
		$Autopsy1/Clue1/StaticBody3D/CollisionShape3D.disabled = true
	if (objectID == 16):
		$Autopsy1/Clue2.global_position = $Clue2Pos.global_position
		frameCount += 1
		$Autopsy1/Clue2/StaticBody3D/CollisionShape3D.disabled = true
	if (objectID == 17):
		if (brainKey):
			if morgueKey:
				$Autopsy1/Clue3.global_position = $Clue3Pos.global_position
				frameCount += 1
				$Autopsy1/Clue3/StaticBody3D/CollisionShape3D.disabled = true
			else: player.descUI.text = "Hmm... some piece of paper."
		else: player.descUI.text = ""
	if (objectID == 18):
		$Autopsy1/Clue4.global_position = $Clue4Pos.global_position
		frameCount += 1
		$Autopsy1/Clue4/StaticBody3D/CollisionShape3D.disabled = true
	if (objectID == 19):
		if (frameCount >= 4):
			player.descUI.text = "Hey it looks like these pieces make a code. '424' I think."
		else: pass
	if (objectID == 20):
		if (scalpelKey && !fingerKey):
			fingerKey = true
			player.descUI.text = "A finger this might come in 'handy'... haha..."
		elif (fingerKey): player.descUI.text = "I already have enough fingers."
		else: pass
	if (objectID == 21):
		autopsy2GigaKey = true
		$Autopsy2/Key.queue_free()
	if (objectID == 22):
		sawKey = true
		$Autopsy1/saw.queue_free()
	if (objectID == 23):
		if (sawKey && !lungKey):
			player.descUI.text = "This is so grotesque..."
			$Autopsy2/Lung.visible = true
			$Autopsy2/Lung/StaticBody3D/CollisionShape3D.disabled = false
		else: pass
	if (objectID == 24):
		lungKey = true
		player.SPEED = 6
		$Autopsy2/Lung.queue_free()
	if (objectID == 25):
		pass
		#Transition

#INDEX:
#1 - FileCabinet
#2 - "Cold Blood" Book
#3 - OfficeDoor
#4 - Lamp
#5 - OfficeSafe
#6 - Autopsy1 - Courtyard Door
#7 - Autopsy1 - Morgue Door
#8 - Brain
#9 - Autopsy2 - Courtyard Door
#10 - Office Stairs
#11 - Morgue Key
#12 - Scalpel
#13 - MorgueCorpse
#14 - Eyeball
#15 - clue1
#16 - clue2
#17 - clue3
#18 - clue4
#19 - Frame
#20 - Bodies
#21 - Autopsy2Key
#22 - Saw
#23 - Autopsy2Corpse
#24 - Lung
#25 - Heart
