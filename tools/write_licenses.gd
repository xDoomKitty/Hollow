extends SceneTree
func _initialize():
	var file=FileAccess.open("res://assets/ENGINE_NOTICES.txt",FileAccess.WRITE)
	file.store_string("GODOT ENGINE AND INCLUDED COMPONENTS\n\n"+Engine.get_license_text()+"\n\n")
	file.store_string("Copyright inventory:\n"+JSON.stringify(Engine.get_copyright_info(),"  ")+"\n\n")
	var licenses=Engine.get_license_info()
	for name in licenses: file.store_string(str(name)+"\n"+str(licenses[name])+"\n\n")
	file.close()
	print("Engine notices written")
	quit()
