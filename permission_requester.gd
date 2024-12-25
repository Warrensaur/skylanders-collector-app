extends Control

class_name PermissionRequester

const PERMS_SAVER: String = "user://perms_given.txt"
const DISCLAIMER_NOTICE: String = "user://disclaimer_acknowledgment.txt"

var perms_saved: bool = false
var disclaimer_acknowledged: bool
var sav_data: bool

@export var disclaimer_acknowledgment_control: Control
@export var disclaimer_blackout: ColorRect
@export var main_scene: Node2D

func _ready():
	var screen_size: Vector2 = main_scene.screen_size
	var centered_coords: Vector2 = Vector2((screen_size.x / 2), (screen_size.y / 2))
	disclaimer_acknowledgment_control.global_position = centered_coords
	if FileAccess.file_exists(DISCLAIMER_NOTICE):
		var file_ = FileAccess.open(DISCLAIMER_NOTICE, FileAccess.READ)
		disclaimer_acknowledged = file_.get_var()
	if disclaimer_acknowledged == false:
		disclaimer_acknowledgment_control.visible = true
		disclaimer_blackout.visible = true
	else:
		disclaimer_acknowledgment_control.visible = false
		disclaimer_blackout.visible = false
	perms_saved = OS.request_permissions()
	sav_data = perms_saved
	if perms_saved == true:
		print("Permissions have been granted...")
	else:
		print("Permissions have not been granted... granting them now.")
		OS.request_permissions()
		perms_saved = OS.request_permissions()
	if FileAccess.file_exists(PERMS_SAVER):
		var file = FileAccess.open(PERMS_SAVER, FileAccess.READ)
		file.store_var(sav_data)
		print("File existed. sav_data was saved and is ", sav_data, ".")
	else:
		var file = FileAccess.open(PERMS_SAVER, FileAccess.WRITE)
		file.store_var(sav_data)
		print("File did not exist. sav_data was saved in a new file and is ", sav_data, ".")

func _on_disclaimer_acknowledgment_pressed() -> void:
	if disclaimer_acknowledged == false:
		disclaimer_acknowledged = true
		var file_ = FileAccess.open(DISCLAIMER_NOTICE, FileAccess.WRITE)
		file_.store_var(disclaimer_acknowledged)
	disclaimer_acknowledgment_control.visible = false
	disclaimer_blackout.visible = false
