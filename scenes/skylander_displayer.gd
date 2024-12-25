extends Control

class_name SkylanderDisplayer

signal update_display
signal save_collection
signal get_initial_collector_stats

@export var skylander_name_label: Label
@export var skylander_element: Label
@export var skylander_info: Label
@export var collected_button: CheckButton
@export var does_figure_work_button: CheckButton
@export var figure_condition_dropdown: OptionButton
@export var figure_picture_texture_rect: TextureRect
@export var skylander: Skylander
@export var backdrop_a: ColorRect
@export var backdrop_b: ColorRect
@export var notes: Label

var screen_size: Vector2

var called_by_ready: bool = true
var is_initial_calc: bool = true

func _ready():
	if skylander.figure_is_collected == skylander.NOT_COLLECTED:
		modulate = Color(1.0, 1.0, 1.0, 0.5)
		collected_button.set("button_pressed", false)
	else:
		collected_button.set("button_pressed", true)
		
	figure_condition_dropdown.set("selected", skylander.figure_condition)
	
	if skylander.does_figure_work == true:
		does_figure_work_button.set("button_pressed", true)
	else:
		does_figure_work_button.set("button_pressed", false)
		
	screen_size = get_viewport().get_visible_rect().size
	
	figure_picture_texture_rect.texture = skylander.image
	
	notes.text = skylander.notes
	
	if screen_size.x != 1080 or screen_size.y != 2340:
		scale = Vector2(screen_size.x / 1080, screen_size.y / 2340)
	
	if is_initial_calc == true:
		get_initial_collector_stats.emit(false, 0)
	
	called_by_ready = false

func _on_condition_dropdown_item_selected(index: int) -> void:
	skylander.figure_condition = figure_condition_dropdown.selected
	if called_by_ready == false:
		update_display.emit(false, skylander.place_in_array_index)

func _on_does_figure_work_button_toggled(toggled_on: bool) -> void:
	skylander.does_figure_work = toggled_on
	if called_by_ready == false:
		save_collection.emit(is_initial_calc)
		update_display.emit(false, skylander.place_in_array_index)

func _on_collected_button_toggled(toggled_on: bool) -> void:
	skylander.figure_is_collected = toggled_on
	if toggled_on == true:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.5)
	if called_by_ready == false:
		save_collection.emit(is_initial_calc)
		update_display.emit(false, skylander.place_in_array_index)
