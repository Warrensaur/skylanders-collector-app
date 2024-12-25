extends Resource

class_name Skylander

const SPYROS_ADVENTURE: int = 0
const GIANTS: int = 1
const SWAP_FORCE: int = 2
const TRAP_TEAM: int = 3
const SUPERCHARGERS: int = 4
const IMAGINATORS: int = 5

const GREEN: int = 0
const ORANGE: int = 1
const BLUE: int = 2
const RED: int = 3
const ENGINE: int = 4
const SENSEI: int = 5
const TRAP: int = 6
const CRYSTAL: int = 7

const COLLECTED: bool = true
const NOT_COLLECTED: bool = false

const BASE_FIGURE: int = 0
const IN_GAME_VARIANT: int = 1
const CHASE_VARIANT: int = 2
const LIMITED_EDITION: int = 3
const PACKAGE_VARIANT: int = 4

const SERIES_1: int = 0
const SERIES_2: int = 1
const SERIES_3: int = 2
const SERIES_4: int = 3
const SERIES_5: int = 4
const SERIES_6: int = 5
const NO_SERIES: int = 6
const EONS_ELITE: int = 7
const ADVENTURE_PIECE: int = 8
const ADVENTURE_ITEM: int = 9
const VILLAIN_TRAP: int = 10
const CREATION_CRYSTAL: int = 11

const NEW_IN_BOX: int = 0
const IN_OPEN_BOX: int = 1
const IN_DAMAGED_BOX: int = 2
const LOOSE_WITH_PERIPHERALS: int = 3
const LOOSE_WITH_SOME_PERIPHERALS: int = 3
const LOOSE_WITHOUT_PERIPHERALS: int = 4
const DAMAGED_FIGURE: int = 5

const PLAYABLE: bool = true
const NOT_PLAYABLE: bool = false

@export var character_name: String
@export var element: String
@export var image: CompressedTexture2D
@export var released_with_game: String
@export var base_is: String
@export var figure_type: String
@export var series: String
@export var figure_is_collected: bool
@export var min_value: float
@export var max_value: float
@export var does_figure_work: bool
@export var figure_condition: int
@export var estimated_val: float
@export var place_in_array_index: int
@export var notes: String

func _ready():
	estimated_val = get_estimated_value()
	print("figure estimated val updated. it is ", estimated_val)

func get_estimated_value() -> float:
	var points: float = 0.0
	if does_figure_work == true:
		points += 1
	else:
		points -= 1
	match figure_condition:
		NEW_IN_BOX:
			points += 4
		IN_OPEN_BOX:
			points += 3
		IN_DAMAGED_BOX:
			points += 2
		LOOSE_WITHOUT_PERIPHERALS:
			points += 0
		LOOSE_WITH_PERIPHERALS:
			points += 1
		DAMAGED_FIGURE:
			points -= 1
	if points <= 0:
		points = 0
	var temp_num: float = (points * 100) / 5
	temp_num = (temp_num * max_value) / 100
	estimated_val = snapped(temp_num, 0.01)
	return estimated_val
