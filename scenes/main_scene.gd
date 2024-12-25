extends Node2D

class_name MainScene

signal filtered

@export var new_collection_button: Button
@export var load_collection_button: Button
@export var view_collections_screen: Control
@export var collection_view: Control
@export var skylander_display: PackedScene
@export var default_co1lection: Array[Skylander]
@export var scroll_container: GridContainer
@export var name_collection_dialog: Control
@export var done_naming_button: Button
@export var collection_name_editor: LineEdit
@export var amount_collected_label: Label
@export var load_collection_dialog: FileDialog
@export var skylander_collection_exporter: SkylanderCollection
@export var collection_name_label: Label
@export var delete_collections_dialog: FileDialog
@export var settings_screen: Control
@export var vert_scroller: CollectionScroller
@export var exit_program_button: Button
@export var back_to_menu_button: Button
@export var vers_label: Label

var collection_name: String = "unnamed_collection"
var save_directory: String

var file

var figures_collected_amount: int = 0
var total_figures: int = 0
var current_filter_val: int = 26

var estimated_collection_value: float = 0.0

var loaded_collection: Array[Skylander]

const MAGIC: Color = Color.WEB_PURPLE
const TECH: Color = Color.GOLDENROD
const FIRE: Color = Color.FIREBRICK
const WATER: Color = Color.DARK_TURQUOISE
const LIFE: Color = Color.DARK_GREEN
const UNDEAD: Color = Color.DARK_SLATE_GRAY
const AIR: Color = Color.AZURE
const EARTH: Color = Color.SADDLE_BROWN
const LIGHT: Color = Color.GOLD
const DARK: Color = Color.MIDNIGHT_BLUE

const SERIES_1: Color = Color.LIME_GREEN
const SERIES_2: Color = Color.ORANGE
const SERIES_3: Color = Color.DODGER_BLUE
const SERIES_4: Color = Color.DARK_RED
const SERIES_5: Color = Color.DIM_GRAY
const SERIES_6: Color = Color.REBECCA_PURPLE

const CORE: int = 0
const IN_GAME_VAR: int = 1
const CHASE_VAR: int = 2
const LIMITED_ED: int = 3
const PKG_VAR: int = 4
const TRAP_CRYSTAL: int = 5
const CREATION_CRYSTAL: int = 6
const ADVENTURE_PIECE: int = 7
const MAGIC_ITEM: int = 8
const LIGHTCORE: int = 9
const GIANT: int = 10
const SWAPPER: int = 11
const TRAP_MASTER: int = 12
const SUPERCHARGER: int = 13
const VEHICLE: int = 14
const SENSEI: int = 15
const SENSEI_VILLAIN: int = 16
const SPYROS_ADV: int = 17
const GIANTS: int = 18
const SWAP_FORCE: int = 19
const TRAP_TEAM: int = 20
const SUPERCHARGERS: int = 21
const IMAGINATORS: int = 22
const GAME_DISK: int = 23
const PORTALS: int = 24
const MINIS: int = 25
const NONE: int = 26

var first_calc: bool = true

var screen_size: Vector2

func update_save_directory() -> String:
	save_directory = str(OS.get_user_data_dir(), "/", collection_name, ".skylanderscollection.tres")
	print("update_save_directory() ran. save_directory is [", save_directory, "].")
	return save_directory

func get_collection_name(path: String):
	path = path.trim_prefix(str("user://", OS.get_user_data_dir(), "/"))
	if path.begins_with("user://"):
		path = path.trim_prefix("user://")
	if path.ends_with(".skylanderscollection.tres"):
		path = path.trim_suffix(".skylanderscollection.tres")
	else:
		if path.ends_with(".skylanders_on.tres.remap"):
			path = path.trim_suffix(".skylanderscollection.tres.remap")
	collection_name = path
	print("get_collection_name() was called. path is [", path, "]. collection_name will be set to this.")
	return collection_name

func check_for_existing_save(path: String) -> bool:
	var file_exist: bool = false
	if ResourceLoader.exists(path):
		file_exist = true
	else:
		file_exist = false
	print("check_for_existing_save(path) was called. file_exist is [", file_exist, "].")
	return file_exist

func rename_file_until_file_doesnt_exist(file_name: String):
	print("rename_file_until_file_doesnt_exist(file_name) is running...")
	var num: int = 0
	while check_for_existing_save(save_directory) == true:
		print("collection_name at start of loop is [", collection_name, "].")
		collection_name = str(collection_name, "_", num)
		update_save_directory()
		print("collection_name at end of loop is [", collection_name, "].")

func update_collection_stats(_update_all: bool, _id: int):
	#print("COLLECTION STATS ARE BEING UPDATED...")
	if collection_name:
		collection_name_label.text = collection_name
	else:
		collection_name_label.text = collection_name
	figures_collected_amount = 0
	total_figures = 0
	estimated_collection_value = 0.0
	for i in default_co1lection:
		total_figures += 1
	for index in loaded_collection:
		if index:
			if index.figure_is_collected == index.COLLECTED:
				figures_collected_amount += 1
				estimated_collection_value = index.estimated_val + estimated_collection_value
			amount_collected_label.text = str("Collected ", figures_collected_amount, " out of ", total_figures, "!\n",
				"Collection estimated to value ~$", estimated_collection_value, "!")
	if first_calc == true:
		first_calc = false

func clear_displayers():
	print("CLEAR_DISPLAYERS() CALLED... Children of GridContainer are being removed from the scene.")
	for child in scroll_container.get_children():
		child.call_deferred("queue_free")

func save_collection(_init_calc: bool):
	print("SAVE_COLLECTION(_init_calc) WAS CALLED...")
	if loaded_collection.is_empty() == true:
		loaded_collection = default_co1lection
		skylander_collection_exporter.collection_array = loaded_collection
		print("loaded_collection was empty. default_collection has been loaded into loaded_collection, 
			and skylander_collection_exporter.collection_array is being set to loaded_collection.")
	else:
		skylander_collection_exporter.collection_array = loaded_collection
		print("loaded_collection was not empty. skylander_collection_exporter.collection_array has been set to loaded_collection.")
	for i in loaded_collection.size():
		loaded_collection[i].place_in_array_index = i
		#print("loaded_collection[", i, "]'s place in array index value is being updated... ", 
		#	loaded_collection[i].character_name, "'s current place_in_array_index is ", 
		#	loaded_collection[i].place_in_array_index, ".")
	skylander_collection_exporter.collection_given_name = collection_name
	print("skylander_collection_exporter is being saved to save_directory, ", update_save_directory(), "...")
	ResourceSaver.save(skylander_collection_exporter, update_save_directory())

func display_skylander_collection(collection: Array[Skylander], init_calc: bool, id: int, update_all: bool):
	if update_all == false:
		print("DISPLAY_SKYLANDER_COLLECTION(COLLECTION, INIT_CALC, ID, UPDATE_ALL) CALLED...
			update_all was false, so an individual skylander_displayer is being updated (at
			index ", id, ").")
		_on_update_display(update_all, id)
	else:
		print("DISPLAY_SKYLANDER_COLLECTION(COLLECTION, INIT_CALC, ID, UPDATE_ALL) CALLED...\n",
			"update_all is true, so the entire stored collection is being displayed.")
		clear_displayers()
		if loaded_collection:
			if collection != loaded_collection:
				print("ERROR... COLLECTION IS NOT THE SAME AS LOADED_COLLECTION (DISPLAY_SKYLANDERS_COLLECTION FUNC.)\n
					Collection will be set to loaded_collection to preserve data, if loaded_collection exists. Otherwise,
					it will be set to default collection.")
				if loaded_collection:
					print("collection has been set to loaded_collection.")
					collection = loaded_collection
				else:
					print("collection has been set to default_collection.")
					collection = default_co1lection
		for index in collection:
			var new_display = skylander_display.instantiate()
			new_display.skylander = index
			new_display.skylander_name_label.text = new_display.skylander.character_name
			new_display.skylander_element.text = new_display.skylander.element
			match new_display.skylander.element:
				"Magic":
					new_display.skylander_name_label.set("theme_override_colors/font_color", MAGIC)
					new_display.skylander_element.set("theme_override_colors/font_color", MAGIC)
					new_display.backdrop_b.set_color(MAGIC)
				"Tech":
					new_display.skylander_name_label.set("theme_override_colors/font_color", TECH)
					new_display.skylander_element.set("theme_override_colors/font_color", TECH)
					new_display.backdrop_b.set_color(TECH)
				"Air":
					new_display.skylander_name_label.set("theme_override_colors/font_color", AIR)
					new_display.skylander_element.set("theme_override_colors/font_color", AIR)
					new_display.backdrop_b.set_color(AIR)
				"Earth":
					new_display.skylander_name_label.set("theme_override_colors/font_color", EARTH)
					new_display.skylander_element.set("theme_override_colors/font_color", EARTH)
					new_display.backdrop_b.set_color(EARTH)
				"Water":
					new_display.skylander_name_label.set("theme_override_colors/font_color", WATER)
					new_display.skylander_element.set("theme_override_colors/font_color", WATER)
					new_display.backdrop_b.set_color(WATER)
				"Fire":
					new_display.skylander_name_label.set("theme_override_colors/font_color", FIRE)
					new_display.skylander_element.set("theme_override_colors/font_color", FIRE)
					new_display.backdrop_b.set_color(FIRE)
				"Life":
					new_display.skylander_name_label.set("theme_override_colors/font_color", LIFE)
					new_display.skylander_element.set("theme_override_colors/font_color", LIFE)
					new_display.backdrop_b.set_color(LIFE)
				"Undead":
					new_display.skylander_name_label.set("theme_override_colors/font_color", UNDEAD)
					new_display.skylander_element.set("theme_override_colors/font_color", UNDEAD)
					new_display.backdrop_b.set_color(UNDEAD)
				"Light":
					new_display.skylander_name_label.set("theme_override_colors/font_color", LIGHT)
					new_display.skylander_element.set("theme_override_colors/font_color", LIGHT)
					new_display.backdrop_b.set_color(LIGHT)
				"Dark":
					new_display.skylander_name_label.set("theme_override_colors/font_color", DARK)
					new_display.skylander_element.set("theme_override_colors/font_color", DARK)
					new_display.backdrop_b.set_color(DARK)
				_:
					new_display.skylander_name_label.set("theme_override_colors/font_color", UNDEAD)
					new_display.skylander_element.set("theme_override_colors/font_color", UNDEAD)
					new_display.backdrop_b.set_color(UNDEAD)
			match new_display.skylander.released_with_game:
				"Spyro's Adventure":
					new_display.backdrop_a.set_color(SERIES_1)
				"Giants":
					new_display.backdrop_a.set_color(SERIES_2)
				"Swap Force":
					new_display.backdrop_a.set_color(SERIES_3)
				"Trap Team":
					new_display.backdrop_a.set_color(SERIES_4)
				"SuperChargers":
					new_display.backdrop_a.set_color(SERIES_5)
				"Imaginators":
					new_display.backdrop_a.set_color(SERIES_6)
			new_display.skylander_info.text = str(
				"Released With: ", new_display.skylander.released_with_game, "\n",
				"Base: ", new_display.skylander.base_is, "\n",
				"Type: ", new_display.skylander.figure_type, "\n",
				"Series: ", new_display.skylander.series, "\n",
				"Value: $", new_display.skylander.min_value, " to $", new_display.skylander.max_value, "\n",
				"Estimated Value: $", new_display.skylander.get_estimated_value()
				)
			new_display.is_initial_calc = init_calc
			new_display.update_display.connect(_on_update_display)
			new_display.update_display.connect(update_collection_stats)
			new_display.save_collection.connect(save_collection)
			new_display.get_initial_collector_stats.connect(update_collection_stats)
			scroll_container.add_child(new_display)
	collection_view.visible = true

func _ready() -> void:
	vers_label.text = str("Warrensaur - Vers. ", ProjectSettings.get("application/config/version"))
	update_save_directory()
	screen_size = get_viewport().get_visible_rect().size
	if screen_size.x != 1080 or screen_size.y != 2340:
		scale = Vector2(screen_size.x / 1080, screen_size.y / 2340)
	load_collection_dialog.set_filters(["*.tres,*.res,*.skylandercollection,*.remap;Resource Files"])
	view_collections_screen.visible = false
	collection_view.visible = false
	name_collection_dialog.visible = false

func _on_update_display(update_all: bool, id: int):
	if update_all == false:
		for child in scroll_container.get_children():
			if child:
				if child.skylander.place_in_array_index == id:
					child.skylander_info.text = str("Released With: ", child.skylander.released_with_game, "\n",
					"Base: ", child.skylander.base_is, "\n",
					"Type: ", child.skylander.figure_type, "\n",
					"Series: ", child.skylander.series, "\n",
					"Value: $", child.skylander.min_value, " to $", child.skylander.max_value, "\n",
					"Estimated Value: $", child.skylander.get_estimated_value())
	else:
		for child in scroll_container.get_children():
			if child:
				child.skylander_info.text = str("Released With: ", child.skylander.released_with_game, "\n",
				"Base: ", child.skylander.base_is, "\n",
				"Type: ", child.skylander.figure_type, "\n",
				"Series: ", child.skylander.series, "\n",
				"Value: $", child.skylander.min_value, " - $", child.skylander.max_value, "\n",
				"Estimated Value: $", child.skylander.get_estimated_value())
		display_skylander_collection(loaded_collection, first_calc, id, update_all)

func _on_start_new_collection_pressed() -> void:
	name_collection_dialog.visible = true

## When a new collection file is named, the user then presses the done button to tell the program they are done, and this saves it.
func _on_done_button_pressed() -> void:
	name_collection_dialog.visible = false
	collection_name = collection_name_editor.text
	update_save_directory()
	if check_for_existing_save(save_directory) == true:
		rename_file_until_file_doesnt_exist(collection_name)
	save_collection(first_calc)
	_on_update_display(true, 0)
	collection_view.visible = true

## When a user presses the Load Collection button on the main menu, this fires. It makes the load collection dialog visible for the player.
func _on_load_collection_pressed() -> void:
	load_collection_dialog.visible = true

## This loads an existing collection file.
func _on_file_dialog_file_selected(path: String) -> void:
	print("A COLLECTION FILE IS BEING LOADED FROM PATH [", path, "]...")
	collection_name = get_collection_name(path)
	print("The collection_name is [", collection_name, "].")
	if ResourceLoader.exists(path):
		print("A file exists at the given path. skylander_collection_exporter will be set to that.")
		skylander_collection_exporter = ResourceLoader.load(path)
		if skylander_collection_exporter.collection_array:
			print("skylander_collection_exporter has a collection_array. Loaded_collection will be set to it.")
			loaded_collection = skylander_collection_exporter.collection_array
		else:
			print("skylander_collection_exporter does not have a collection_array. Loaded_collection will be set to default_collection.")
			loaded_collection = default_co1lection
	else:
		print("A file did not exist at the given path. Loaded_collection is being set to default_collection.")
		loaded_collection = default_co1lection
	if !skylander_collection_exporter.collection_given_name:
		print("skylander_collection_exporter.collection_given_name does not exist. It will be set to collection_name [", collection_name, "].")
		skylander_collection_exporter.collection_given_name = collection_name
	else:
		if skylander_collection_exporter.collection_given_name != collection_name:
			print("skylander_collection_exporter.collection_given_name, ", 
				skylander_collection_exporter.collection_given_name, ", is not the same as collection_name, ", 
				collection_name, ". It will be overwritten with collection_name (", collection_name, ").")
			skylander_collection_exporter.collection_given_name = collection_name
	print("About to call display_skylander_collection(loaded_collection, true (init_calc), 0, true (update_all))...")
	display_skylander_collection(loaded_collection, true, 0, true)

func _on_view_collection_files_pressed() -> void:
	print("Opened the save files.")
	delete_collections_dialog.visible = true

## A collection file is deleted.
func _on_file_dialog_view_collections_file_selected(path: String) -> void:
	print("save file at path [", path, "] has been moved to OS trash.")
	OS.move_to_trash(ProjectSettings.globalize_path(path))

## The settings button on the home screen is pressed.
func _on_settings_pressed() -> void:
	settings_screen.visible = true
	exit_program_button.hide()
	back_to_menu_button.hide()

## The return to main menu button in the Settings screen is pressed.
func _on_return_button_pressed() -> void:
	settings_screen.visible = false
	exit_program_button.show()
	back_to_menu_button.show()

## A filter is chosen from the dropdown menu.
func _on_filter_options_item_selected(index: int) -> void:
	current_filter_val = index
	match index:
		CORE, TRAP_CRYSTAL, CREATION_CRYSTAL, ADVENTURE_PIECE, MAGIC_ITEM, LIGHTCORE, GIANT, SWAPPER, TRAP_MASTER, SUPERCHARGER, VEHICLE, SENSEI, SENSEI_VILLAIN, SPYROS_ADV, GIANTS, SWAP_FORCE, TRAP_TEAM, SUPERCHARGERS, IMAGINATORS:
			for i in scroll_container.get_children():
				if i:
					if i.skylander:
						match index:
							CORE: # Core
								if i.skylander.figure_type != "Core":
									i.visible = false
								else:
									i.visible = true
							TRAP_CRYSTAL: # Traps
								if i.skylander.figure_type != "Trap":
									i.visible = false
								else:
									i.visible = true
							CREATION_CRYSTAL: # Creation Crystals
								if i.skylander.figure_type != "Creation Crystal":
									i.visible = false
								else:
									i.visible = true
							ADVENTURE_PIECE: # Adventure Pieces
								if i.skylander.figure_type != "Adventure Piece":
									i.visible = false
								else:
									i.visible = true
							MAGIC_ITEM: # Magic Items
								if i.skylander.figure_type != "Magic Item":
									i.visible = false
								else:
									i.visible = true
							LIGHTCORE: # LightCore
								if i.skylander.figure_type != "LightCore":
									i.visible = false
								else:
									i.visible = true
							GIANT: # Giants (figures)
								if i.skylander.figure_type != "Giant":
									i.visible = false
								else:
									i.visible = true
							SWAPPER: # Swap Force (figures)
								if i.skylander.figure_type != "Swapper":
									i.visible = false
								else:
									i.visible = true
							TRAP_MASTER: # Trap Master
								if i.skylander.figure_type != "Trap Master":
									i.visible = false
								else:
									i.visible = true
							SUPERCHARGER: # SuperChargers (figures)
								if i.skylander.figure_type != "SuperCharger":
									i.visible = false
								else:
									i.visible = true
							VEHICLE: # Vehicles
								if i.skylander.figure_type != "Vehicle":
									i.visible = false
								else:
									i.visible = true
							SENSEI: # Senseis
								if i.skylander.figure_type != "Sensei":
									i.visible = false
								else:
									i.visible = true
							SENSEI_VILLAIN: # Villains
								if i.skylander.figure_type != "Sensei Villain":
									i.visible = false
								else:
									i.visible = true
							SPYROS_ADV: # Spyro's Adventure
								if i.skylander.released_with_game != "Spyro's Adventure":
									i.visible = false
								else:
									i.visible = true
							GIANTS: # Giants
								if i.skylander.released_with_game != "Giants":
									i.visible = false
								else:
									i.visible = true
							SWAP_FORCE: # Swap Force
								if i.skylander.released_with_game != "Swap Force":
									i.visible = false
								else:
									i.visible = true
							TRAP_TEAM: # Trap Team
								if i.skylander.released_with_game != "Trap Team":
									i.visible = false
								else:
									i.visible = true
							SUPERCHARGERS: # SuperChargers
								if i.skylander.released_with_game != "SuperChargers":
									i.visible = false
								else:
									i.visible = true
							IMAGINATORS: # Imaginators
								if i.skylander.released_with_game != "Imaginators":
									i.visible = false
								else:
									i.visible = true
							MINIS: # Minis
								if i.skylander.figure_type != "Mini" or i.skylander.character_name.findn("Sidekick") == -1:
									i.visible = false
								else:
									i.visible = true
							NONE: # no filter
								i.visible = true
		1: # In-Game Variant
			var in_game_name_array: Array[String] = ["Eon's Elite", "Dark", "Egg Bomber", 
			"Nitro", "Legendary", "Golden Dragonfire Cannon", "Granite", "Jade", "Molten",
			"Scarlet", "Punch", "Gnarly", "Polar", "Jolly", "Kickoff", "Enchanted", 
			"Quickdraw", "Quick Draw", "Volcanic", "Springtime", "Missile-Tow", 
			"Frightful", "Power Blue", "Eggcited", "Birthday Bash", "Eggsellent", 
			"Spring Ahead", "Mystical", "Solar Flare", "Heartbreaker", "Jingle Bell",
			"Candy-Coated", "Hard-Boiled", "King Cobra Cadabra", "Winterfest"]
			for i in scroll_container.get_children():
				i.visible = false
			for n in in_game_name_array:
				for child in scroll_container.get_children():
					if child.skylander.character_name.findn(n) != -1:
						if child.skylander.character_name.findn("Darklight Crypt") == -1 and child.skylander.character_name.findn("Volcanic Vault") == -1:
							child.visible = true
		2: # Chase Variant
			var in_game_name_array: Array[String] = ["Blue Bash", "Red Drill Sergeant",
				"Red Camo", "Silver", "Gold ", "Bronze", "Exclusive", "E3", "Translucent",
				"Rock Candy", "Orange", "Metallic", "Green", "Happy Birthday, Ben", 
				"Frito-Lay", "Sidekick", "Patina", "Pink Barbella", "Chrome", "Snowderdash", 
				"Dec-Ember", "Employee Edition", "Mobile Hot Streak"]
			for i in scroll_container.get_children():
				i.visible = false
			for n in in_game_name_array:
				for child in scroll_container.get_children():
					if child.skylander.character_name.findn(n) != -1:
						child.visible = true
		_:
			print("THOSE HAVE NOT BEEN ADDED TO THE DATABASE YET...")
	filtered.emit()

func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_search_line_edit_text_changed(new_text: String) -> void:
	var search_query: String = new_text
	if search_query:
		for i in scroll_container.get_children():
			i.visible = false
		for n in scroll_container.get_children():
			if n.skylander.character_name.findn(search_query) != -1:
				match current_filter_val:
					CORE: # Core
						if n.skylander.figure_type != "Core":
							n.visible = false
						else:
							n.visible = true
					TRAP_CRYSTAL: # Traps
						if n.skylander.figure_type != "Trap":
							n.visible = false
						else:
							n.visible = true
					CREATION_CRYSTAL: # Creation Crystals
						if n.skylander.figure_type != "Creation Crystal":
							n.visible = false
						else:
							n.visible = true
					ADVENTURE_PIECE: # Adventure Pieces
						if n.skylander.figure_type != "Adventure Piece":
							n.visible = false
						else:
							n.visible = true
					MAGIC_ITEM: # Magic Items
						if n.skylander.figure_type != "Magic Item":
							n.visible = false
						else:
							n.visible = true
					LIGHTCORE: # LightCore
						if n.skylander.figure_type != "LightCore":
							n.visible = false
						else:
							n.visible = true
					GIANT: # Giants (figures)
						if n.skylander.figure_type != "Giant":
							n.visible = false
						else:
							n.visible = true
					SWAPPER: # Swap Force (figures)
						if n.skylander.figure_type != "Swapper":
							n.visible = false
						else:
							n.visible = true
					TRAP_MASTER: # Trap Master
						if n.skylander.figure_type != "Trap Master":
							n.visible = false
						else:
							n.visible = true
					SUPERCHARGER: # SuperChargers (figures)
						if n.skylander.figure_type != "SuperCharger":
							n.visible = false
						else:
							n.visible = true
					VEHICLE: # Vehicles
						if n.skylander.figure_type != "Vehicle":
							n.visible = false
						else:
							n.visible = true
					SENSEI: # Senseis
						if n.skylander.figure_type != "Sensei":
							n.visible = false
						else:
							n.visible = true
					SENSEI_VILLAIN: # Villains
						if n.skylander.figure_type != "Sensei Villain":
							n.visible = false
						else:
							n.visible = true
					SPYROS_ADV: # Spyro's Adventure
						if n.skylander.released_with_game != "Spyro's Adventure":
							n.visible = false
						else:
							n.visible = true
					GIANTS: # Giants
						if n.skylander.released_with_game != "Giants":
							n.visible = false
						else:
							n.visible = true
					SWAP_FORCE: # Swap Force
						if n.skylander.released_with_game != "Swap Force":
							n.visible = false
						else:
							n.visible = true
					TRAP_TEAM: # Trap Team
						if n.skylander.released_with_game != "Trap Team":
							n.visible = false
						else:
							n.visible = true
					SUPERCHARGERS: # SuperChargers
						if n.skylander.released_with_game != "SuperChargers":
							n.visible = false
						else:
							n.visible = true
					IMAGINATORS: # Imaginators
						if n.skylander.released_with_game != "Imaginators":
							n.visible = false
						else:
							n.visible = true
					MINIS: # Minis
						if n.skylander.figure_type != "Mini" or n.skylander.character_name.findn("Sidekick") == -1:
							n.visible = false
						else:
							n.visible = true
					NONE: # no filter
						n.visible = true
					_:
						n.visible = true
	else:
		for i in scroll_container.get_children():
			match current_filter_val:
					CORE: # Core
						if i.skylander.figure_type != "Core":
							i.visible = false
						else:
							i.visible = true
					TRAP_CRYSTAL: # Traps
						if i.skylander.figure_type != "Trap":
							i.visible = false
						else:
							i.visible = true
					CREATION_CRYSTAL: # Creation Crystals
						if i.skylander.figure_type != "Creation Crystal":
							i.visible = false
						else:
							i.visible = true
					ADVENTURE_PIECE: # Adventure Pieces
						if i.skylander.figure_type != "Adventure Piece":
							i.visible = false
						else:
							i.visible = true
					MAGIC_ITEM: # Magic Items
						if i.skylander.figure_type != "Magic Item":
							i.visible = false
						else:
							i.visible = true
					LIGHTCORE: # LightCore
						if i.skylander.figure_type != "LightCore":
							i.visible = false
						else:
							i.visible = true
					GIANT: # Giants (figures)
						if i.skylander.figure_type != "Giant":
							i.visible = false
						else:
							i.visible = true
					SWAPPER: # Swap Force (figures)
						if i.skylander.figure_type != "Swapper":
							i.visible = false
						else:
							i.visible = true
					TRAP_MASTER: # Trap Master
						if i.skylander.figure_type != "Trap Master":
							i.visible = false
						else:
							i.visible = true
					SUPERCHARGER: # SuperChargers (figures)
						if i.skylander.figure_type != "SuperCharger":
							i.visible = false
						else:
							i.visible = true
					VEHICLE: # Vehicles
						if i.skylander.figure_type != "Vehicle":
							i.visible = false
						else:
							i.visible = true
					SENSEI: # Senseis
						if i.skylander.figure_type != "Sensei":
							i.visible = false
						else:
							i.visible = true
					SENSEI_VILLAIN: # Villains
						if i.skylander.figure_type != "Sensei Villain":
							i.visible = false
						else:
							i.visible = true
					SPYROS_ADV: # Spyro's Adventure
						if i.skylander.released_with_game != "Spyro's Adventure":
							i.visible = false
						else:
							i.visible = true
					GIANTS: # Giants
						if i.skylander.released_with_game != "Giants":
							i.visible = false
						else:
							i.visible = true
					SWAP_FORCE: # Swap Force
						if i.skylander.released_with_game != "Swap Force":
							i.visible = false
						else:
							i.visible = true
					TRAP_TEAM: # Trap Team
						if i.skylander.released_with_game != "Trap Team":
							i.visible = false
						else:
							i.visible = true
					SUPERCHARGERS: # SuperChargers
						if i.skylander.released_with_game != "SuperChargers":
							i.visible = false
						else:
							i.visible = true
					IMAGINATORS: # Imaginators
						if i.skylander.released_with_game != "Imaginators":
							i.visible = false
						else:
							i.visible = true
					MINIS: # Minis
						if i.skylander.figure_type != "Mini" or i.skylander.character_name.findn("Sidekick") == -1:
							i.visible = false
						else:
							i.visible = true
					NONE: # no filter
						i.visible = true
					_:
						i.visible = true
	filtered.emit()

func _on_filtered():
	vert_scroller.set("scroll_vertical", lerp(vert_scroller.get("scroll_vertical"), 0, vert_scroller.scroll_factor))

func _on_low_pressed() -> void:
	vert_scroller.scroll_factor = 0.1

func _on_medium_pressed() -> void:
	vert_scroller.scroll_factor = 0.5

func _on_high_pressed() -> void:
	vert_scroller.scroll_factor = 0.9

func _on_back_to_main_menu_pressed() -> void:
	if collection_view.visible == true:
		collection_view.visible = false
