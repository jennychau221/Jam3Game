extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !$VideoStreamPlayer.is_playing():
		$VideoStreamPlayer.play()
	if !$AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.play()


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	print("press")

func _on_credits_button_pressed():
	$CreditsScreen.visible = true
	$CreditsScreen/ExitCreditsButton.visible = true
	$CreditsButton.visible = false
	$StartButton.visible = false



func _on_exit_credits_button_pressed():
	$CreditsScreen.visible = false
	$CreditsScreen/ExitCreditsButton.visible = false
	$CreditsButton.visible = true
	$StartButton.visible = true
