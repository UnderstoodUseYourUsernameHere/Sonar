extends Node2D

const TILE_SIZE: int = 30
const MOVE_TIME_PER_TILE: float = 0.16

const MOVE_ACTIONS: Dictionary = {
	"move_up": Vector2i(0, -1),
	"move_down": Vector2i(0, 1),
	"move_left": Vector2i(-1, 0),
	"move_right": Vector2i(1, 0)
}

const BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 1.0)
const WALL_COLOR: Color = Color(0.12, 0.90, 0.38, 1.0)
const PLAYER_COLOR: Color = Color(0.96, 0.98, 1.0, 1.0)

const PLAYER_TURN_SPEED: float = 25.0
const PLAYER_STRETCH: float = 0.3

const PING_SPEED: float = 200.0 ## This is how fast the ring/circle grows 
const PING_MAX_RADIUS: float = 10.5 * TILE_SIZE
const PING_COOLDOWN: float = 0.7 
const PING_RING_WIDTH: float = 2.0 ## I like it at TWO, no more, no more, no esse. 
const PING_RING_COLOR: Color = Color(0.35, 1.0, 0.35, 1.0)
const PING_NOISE_RANGE_TILES: float = 11.0 ## How far the monster can hear a ping, its larger than the radius on purpose

const FOOTSTEP_NOISE_RANGE_TILES: float = 2.5 ## I think this might be TOO HIGH, but also i dont care, but also i do care...
const FOOTSTEP_RING_COLOR: Color = Color(0.35, 1.0, 0.35, 1.0)

const SENSE_RANGE_TILES: float = 8.0 ## When its actively hunting
const SENSE_RANGE_QUIET_TILES: float = 4.0 ## Wandering
const SENSE_INTERVAL_FAR: float = 0.9
const SENSE_INTERVAL_NEAR: float = 0.22
const SENSE_ARC_DURATION: float = 0.7
const SENSE_ARC_SPAN: float = 0.9 ## Radians at full width, damn i hate math
const SENSE_ARC_SPEED: float = 95.0 ## How many pixels per second outward
const SENSE_ARC_START: float = TILE_SIZE * 0.55
const SENSE_STAMP_DURATION: float = 0.55
const SENSE_JITTER_MAX: float = TILE_SIZE * 1.1
const SENSE_COLOR: Color = Color(1.0, 0.25, 0.30, 1.0)

const AWARENESS_PER_PING: float = 0.45
const AWARENESS_PER_FOOTSTEP: float = 0.06
const AWARENESS_DECAY_PER_SECOND: float = 0.04

const AWARENESS_FALLOFF_TILES: float = 10.0
const AWARENESS_FALLOFF_FLOOR: float = 0.15
 
const AWARENESS_STALK_THRESHOLD: float = 0.5 ## Enters stalking above this
const AWARENESS_STALK_EXIT: float = 0.25 ## Exits stalking below this
const AWARENESS_STALK_DECAY_PER_SECOND: float = 0.02

const MONSTER_STALK_MOVE_TIME: float = 0.17
const MONSTER_STALK_DISTANCE_START: int = 5
const MONSTER_STALK_DISTANCE_MIN: int = 3
const MONSTER_STALK_CREEP_SECONDS: float = 3.5

const MONSTER_STALK_BACKOFF_SECONDS: float = 8.0 ## How long it takes for the monster to backoff if the player remains silent for this amount of seconds
const MONSTER_STALK_NOISE_CREEP_BONUS: float = 2.0 ## Every noise it hears while stalking removes this amount from the creep timer
const MONSTER_LUNGE_PAUSE: float = 1.1 ## How long the monster takes to switch to hunting, but visually
const MONSTER_LUNGE_RING_COLOR: Color = Color(1.0, 0.15, 0.2, 1.0)

const AWARENESS_HUNT_THRESHOLD: float = 1.0
const AWARENESS_AFTER_LOST_HUNT: float = 0.3
const MONSTER_HUNT_MOVE_TIME: float = 0.15 
const MONSTER_HUNT_LOSE_SECONDS: float = 2.5
const MONSTER_HUNT_PROXIMITY_TILES: float = 2.0
const MONSTER_ATTACK_TRIGGER_DISTANCE: float = TILE_SIZE * 0.9
const MONSTER_ATTACK_WINDUP: float = 0.30

const WALL_DIM_SEEN_ALPHA: float = 0.35 ## A wall thats been seen before never dims below this(its going to be an alpha, sigma oh my god!!!!)
const WALL_FLASH_DURATION: float = 1.2

const SCAN_RAY_COUNT: int = 520
const SCAN_POINT_LENGTH: float = 3.2
const SCAN_POINT_WIDTH: float = 1.4
const SCAN_JITTER: float = 0.6
const SCAN_MAX_POINTS: int = 5000
const SCAN_HOLD_DURATION: float = 8.0
const SCAN_FADE_DURATION: float = 12.0

const MONSTER_ROAM_WAIT: float = 0.75
const MONSTER_ROAM_MIN_DISTANCE: int = 8
const MONSTER_ROAM_ATTEMPTS: int = 40

const MONSTER_GUARD_CHANCE: float = 0.40
const MONSTER_GUARD_RADIUS: int = 5

const MONSTER_ROAM_MOVE_TIME: float = 0.26
const MONSTER_INVESTIGATE_MOVE_TIME: float = 0.18
const MONSTER_SEARCH_MOVE_TIME: float = 0.16

const MONSTER_SEARCH_DURATION: float = 5.5 
const MONSTER_SEARCH_RADIUS: int = 4
const MONSTER_SEARCH_WAIT: float = 0.25
const MONSTER_SNAPSHOT_FADE_DURATION: float = 1.5

const MONSTER_COLOR: Color = Color(0.85, 0.12, 0.15, 1.0)
const MONSTER_DOT_COUNT: int = 13
const MONSTER_DOT_COUNT_VARIANCE: int = 5
const MONSTER_CLUSTER_RADIUS: float = TILE_SIZE * 0.38
const MONSTER_SCAN_RADIUS: float  = TILE_SIZE * 0.42

const MONSTER_LISTEN_PAUSE: float = 0.7

const MONSTER_SCAN_RETURN_COLOR: Color = Color(1.0, 0.12, 0.20, 1.0)
const MONSTER_SCAN_RETURN_DURATION: float = 3.0

const CARD_COLOR: Color = Color(1.0, 0.82, 0.18, 1.0)
const CARD_DIM_ALPHA: float = 0.30
const CARD_FLASH_DURATION: float = 1.0

const EXIT_LOCKED_COLOR: Color = Color(0.25, 0.55, 1.0, 1.0)
const EXIT_OPEN_COLOR: Color = Color(0.2, 1.0, 0.45, 1.0)
const EXIT_DIM_ALPHA: float = 0.30
const EXIT_FLASH_DURATION: float = 1.0

const DEBUG_SHOW_MONSTER: bool = true

const TEST_MAP_ROWS: Array[String] = [
	"################################",
	"#.....#........#...............#",
	"#.....#..##....#...####........#",
	"#.....#..##....#...#..#....K...#",
	"#..E..#........#...#..#........#",
	"#.....####.#####...#..####.#####",
	"#..........#.......#...........#",
	"#.....#....#.......#...........#",
	"###.###....#...##..#...##..#...#",
	"#..........#...#...#...#...#...#",
	"#...##.....#...#...#...#...#...#",
	"#...#......#...#...#...#...#...#",
	"#...#......##.##...#...##.##...#",
	"#...#....................M.....#",
	"#...####.#######.#######.#######",
	"#......#.......#.......#.......#",
	"#..##..#..##...#..###..#...##..#",
	"#..#...#..#....#..#....#...#...#",
	"#..#...#..#....#..#X#..#...#...#",
	"#..#...#..#....#..#.#..#...#...#",
	"#......#.......#....#..........#",
	"#......#.......#....#..........#",
	"#..........#...........#.......#",
	"################################"
]

const USE_PROCEDURAL_MAP: bool = true
const GEN_WIDTH: int = 32
const GEN_HEIGHT: int = 24
const GEN_MAP_ATTEMPTS: int = 50
const GEN_ROOM_ATTEMPTS: int = 120
const GEN_MIN_ROOMS: int = 6
const GEN_MAX_ROOMS: int = 12
const GEN_ROOM_MIN_WIDTH: int = 4
const GEN_ROOM_MAX_WIDTH: int = 8
const GEN_ROOM_MIN_HEIGHT: int = 3
const GEN_ROOM_MAX_HEIGHT: int = 6
const GEN_EXTRA_LOOPS: int = 4
const GEN_MIN_ENTRANCE_TO_CARD: int = 18

class ScanPoint:
	var position: Vector2
	var tangent: Vector2
	var distance: float = 0.0
	var born_time: float = 0.0
	var is_monster_return: bool = false

class SonarPulse:
	var origin: Vector2
	var origin_cell: Vector2i
	var radius: float = 0.0
	var previous_radius: float = 0.0
	var hits: Array[ScanPoint] = []
	var next_hit_index: int = 0
	var wave_directions: PackedVector2Array = PackedVector2Array()
	var wave_stop_distances: PackedFloat32Array = PackedFloat32Array()
	var monster_position_at_ping: Vector2 = Vector2.ZERO
	var monster_center_distance_at_ping: float = INF
	var monster_scan_was_hit: bool = false
	var monster_snapshot_revealed: bool = false
	
	func _init(start_origin: Vector2, start_cell: Vector2i) -> void:
		origin = start_origin
		origin_cell = start_cell

class SenseArc:
	var origin: Vector2
	var angle: float = 0.0
	var closeness: float = 0.0 ## 0 is furthest, 1 is closest
	var born_time: float = 0.0
	

enum MonsterState {
	ROAMING,
	INVESTIGATING,
	SEARCHING,
	STALKING,
	HUNTING
}

var map_width: int = 0
var map_height: int = 0
var map_is_valid: bool = false

var map_rows: Array[String] = []
var map_rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var retry_map_seed: int = 0
static var retry_map_seed_is_set: bool = false
var current_map_seed: int = 0

var player_cell: Vector2i = Vector2i.ZERO
var player_draw_position: Vector2 = Vector2.ZERO
var player_facing: Vector2i = Vector2i(0, -1)
var player_draw_angle: float = -PI / 2.0 

var is_moving: bool = false
var move_source: Vector2 = Vector2.ZERO
var move_destination: Vector2 = Vector2.ZERO
var move_destination_cell: Vector2i = Vector2i.ZERO
var move_elapsed: float = 0.0

var buffered_direction: Vector2i = Vector2i.ZERO
var held_directions: Array[Vector2i] = []
var move_carry: float = 0.0

var game_time: float = 0.0
var game_over: bool = false
var active_pulses: Array[SonarPulse] = []
var wall_cells: Array[Vector2i] = []
var walkable_cells: Array[Vector2i] = []
var scan_points: Array[ScanPoint] = []
var scan_rng: RandomNumberGenerator = RandomNumberGenerator.new()

var last_ping_time: float = -1000.0

var last_noise_cell: Vector2i = Vector2i.ZERO
var last_noise_time: float = -1000.0
var last_noise_range_tiles: float = 0.0
var last_noise_loudness: float = 0.0
var monster_awareness: float = 0.0

var monster_cell: Vector2i = Vector2i.ZERO
var monster_draw_position: Vector2 = Vector2.ZERO
var monster_dot_offsets: Array[Vector2] = []
var monster_dot_sizes: Array[float] = []

var is_monster_moving: bool = false

var monster_move_source: Vector2 = Vector2.ZERO
var monster_move_destination: Vector2 = Vector2.ZERO
var monster_move_destination_cell: Vector2i = Vector2i.ZERO
var monster_move_elapsed: float = 0.0
var monster_current_move_time: float = MONSTER_ROAM_MOVE_TIME

var monster_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var monster_roam_wait_remaining: float = 0.0

var monster_state: MonsterState = MonsterState.ROAMING
var monster_last_heard_noise_time: float = -1000.0
var monster_investigation_target: Vector2i = Vector2i.ZERO
var monster_needs_new_path: bool = false

var monster_search_center: Vector2i = Vector2i.ZERO
var monster_search_time_remaining: float = 0.0
var monster_search_wait_remaining: float = 0.0 
var monster_snapshot_position: Vector2 = Vector2.ZERO
var monster_snapshot_time: float = -1000.0

var sense_arcs: Array[SenseArc] = []
var next_sense_time: float = 0.0
var monster_sense_position: Vector2 = Vector2.ZERO
var monster_sense_time: float = -1000.0
var monster_sense_confidence: float = 0.0

var monster_stalk_target: Vector2i = Vector2i.ZERO
var monster_stalk_distance: int = MONSTER_STALK_DISTANCE_START
var monster_stalk_creep_remaining: float = 0.0
var monster_stalk_quiet_time: float = 0.0

var monster_lunge_remaining: float = 0.0
var monster_lunge_start_time: float = -1000.0

var monster_hunt_target: Vector2i = Vector2i.ZERO
var monster_hunt_lose_remaining: float = 0.0
var monster_is_attacking: bool = false
var monster_attack_remaining: float = 0.0
var monster_attack_start_time: float = -1000.0
var monster_listen_remaining: float = 0.0

var card_cell: Vector2i = Vector2i.ZERO
var card_draw_position: Vector2 = Vector2.ZERO
var card_discovered: bool = false
var card_last_lit_time: float = -1000.0
var has_access_card: bool = false

var exit_cell: Vector2i = Vector2i.ZERO
var exit_draw_position: Vector2 = Vector2.ZERO
var exit_discovered: bool = false
var exit_last_lit_time: float = -1000.0
var has_won: bool = false

var astar: AStarGrid2D = AStarGrid2D.new() ## I really like this name for some reason!
var monster_path: Array[Vector2i] = []

func _ready() -> void:
	if retry_map_seed_is_set:
		map_rng.seed = retry_map_seed
		retry_map_seed_is_set = false
	else:
		map_rng.randomize()
	current_map_seed = map_rng.seed
	
	if USE_PROCEDURAL_MAP:
		map_rows = _generate_map()
	else:
		map_rows = TEST_MAP_ROWS
		
	if not _parse_map():
		set_process(false)
		return
	
	map_is_valid = true
	monster_rng.randomize()
	scan_rng.randomize()
	 
	player_draw_position = _cell_center(player_cell)
	player_draw_angle = Vector2(player_facing).angle()
	monster_draw_position = _cell_center(monster_cell)
	card_draw_position = _cell_center(card_cell)
	exit_draw_position = _cell_center(exit_cell)
	
	_build_monster_shape()
	_build_astar()
	
	monster_path.clear()
	monster_roam_wait_remaining = 0.5
	queue_redraw()

func _check_player_caught(delta: float) -> void:
	if game_over:
		return
	
	var distance: float = player_draw_position.distance_to(monster_draw_position)
	if monster_is_attacking:
		monster_attack_remaining -= delta
		
		if monster_attack_remaining > 0.0:
			return
		
		if distance <= MONSTER_ATTACK_TRIGGER_DISTANCE:
			game_over = true
			active_pulses.clear()
			monster_path.clear()
			return
		
		monster_is_attacking = false
		_begin_monster_hunting(player_cell)
		return
		
	if distance <= MONSTER_ATTACK_TRIGGER_DISTANCE:
		monster_is_attacking = true
		monster_attack_remaining = MONSTER_ATTACK_WINDUP
		monster_attack_start_time = game_time
		monster_path.clear()

func _draw_game_over() -> void:
	var screen_size: Vector2 = Vector2(
		map_width * TILE_SIZE,
		map_height * TILE_SIZE
	)
	
	draw_rect(
		Rect2(Vector2.ZERO, screen_size),
		Color(0.3, 0.0, 0.0, 0.70),
		true
	)
	
	var font: Font = ThemeDB.fallback_font
	
	draw_string(
		font,
		Vector2(0.0, 330.0),
		"SIGNAL LOST",
		HORIZONTAL_ALIGNMENT_CENTER,
		screen_size.x,
		42,
		Color(1.0, 0.20, 0.25, 1.0)
	)
	
	draw_string(
		font,
		Vector2(0.0, 380.0),
		"PRESS R TO RESTART",
		HORIZONTAL_ALIGNMENT_CENTER,
		screen_size.x,
		20,
		Color(1.0, 0.85, 0.85, 1.0)
	)

func _draw_victory() -> void:
	var screen_size: Vector2 = Vector2(
		map_width * TILE_SIZE,
		map_height * TILE_SIZE
	)
	
	draw_rect(
		Rect2(Vector2.ZERO, screen_size),
		Color(0.0, 0.16, 0.08, 0.78),
		true
	)
	
	var font: Font = ThemeDB.fallback_font
	
	draw_string(
		font,
		Vector2(0.0, 320.0),
		"ACCESS GRANTED",
		HORIZONTAL_ALIGNMENT_CENTER,
		screen_size.x,
		42,
		Color(0.3, 1.0, 0.55, 1.0)
	)
	
	draw_string(
		font,
		Vector2(0.0, 365.0),
		"YOU HAVE ESCAPED THE STATION!",
		HORIZONTAL_ALIGNMENT_CENTER,
		screen_size.x,
		22,
		Color(0.75, 1.0, 0.82, 1.0)
	)
	
	draw_string(
		font,
		Vector2(0.0, 405.0),
		"PRESS R TO PLAY AGAIN",
		HORIZONTAL_ALIGNMENT_CENTER,
		screen_size.x,
		18,
		Color(0.75, 1.0, 0.82, 1.0)
	)

func _parse_map() -> bool:
	if map_rows.is_empty():
		push_error("map_rows cant be empty!")
		return false
	
	wall_cells.clear()
	walkable_cells.clear()
	map_height = map_rows.size()
	map_width = map_rows[0].length()
	
	var start_count: int = 0
	var monster_count: int = 0 
	var card_count: int = 0
	var exit_count: int = 0
	
	for y in range(map_height):
		var row: String = map_rows[y]
		
		if row.length() != map_width:
			push_error("map_rows row %d has %d characters; expected %d!" % [y, row.length(), map_width])
			return false
		
		for x in range(map_width): 
			var tile: String = row.substr(x, 1)
			
			if tile == "E":
				start_count += 1
				player_cell = Vector2i(x, y)
			elif tile == "M":
				monster_count += 1 
				monster_cell = Vector2i(x, y)
			elif tile == "K":
				card_count += 1
				card_cell = Vector2i(x, y)
			elif tile == "X":
				exit_count += 1
				exit_cell = Vector2i(x, y)
			elif tile == "#":
				wall_cells.append(Vector2i(x, y))
			elif tile != ".":
				push_error("Unsupported map character '%s' at cell (%d, %d)!" % [tile, x, y])
				return false
			if tile != "#":
				walkable_cells.append(Vector2i(x, y))
	if start_count != 1:
		push_error("Expected exactly one E start marker but found %d!" % [start_count])
		return false
	if monster_count != 1:
		push_error("Expected exactly one M monster marker but found %d!" % [monster_count])
		return false
	if card_count != 1:
		push_error("Expected exactly one K access card but found %d!" % [card_count])
		return false
	if exit_count != 1:
		push_error("Expected exactly one X exit marker but found %d!" % [exit_count])
		return false
	return true

func _generate_map() -> Array[String]:
	for _attempt in range(GEN_MAP_ATTEMPTS):
		var rows: Array[String] = _try_generate_map()
		
		if not rows.is_empty():
			return rows
		
	push_warning("Map generation failed! Using test map.")
	return TEST_MAP_ROWS

func _try_generate_map() -> Array[String]:
	var rows: Array[String] = []
	var grid: Array = []
	
	for y in range(GEN_HEIGHT):
		var row: Array = []
		for x in range(GEN_WIDTH):
			row.append("#")
		grid.append(row)
	
	var rooms: Array[Rect2i] = []
	
	for _attempt in range(GEN_ROOM_ATTEMPTS):
		var w: int = map_rng.randi_range(GEN_ROOM_MIN_WIDTH, GEN_ROOM_MAX_WIDTH)
		var h: int = map_rng.randi_range(GEN_ROOM_MIN_HEIGHT, GEN_ROOM_MAX_HEIGHT)
		var x: int = map_rng.randi_range(1, GEN_WIDTH - w - 1)
		var y: int = map_rng.randi_range(1, GEN_HEIGHT - h - 1)
		var room: Rect2i = Rect2i(x, y, w, h)
		
		if _room_overlaps(room, rooms):
			continue
		
		_carve_rect(grid, room)
		rooms.append(room)
		
		if rooms.size() >= GEN_MAX_ROOMS:
			break
		
	if rooms.size() < GEN_MIN_ROOMS:
		return rows
	
	rooms.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.get_center().x + a.get_center().y * 0.5 < b.get_center().x + b.get_center().y * 0.5)
	
	for i in range(1, rooms.size()):
		_carve_corridor(grid, rooms[i - 1].get_center(), rooms[i].get_center())
	
	for _loop in range(GEN_EXTRA_LOOPS):
		var a: int = map_rng.randi_range(0, rooms.size() - 1)
		var b: int = map_rng.randi_range(0, rooms.size() - 1)
		
		if a != b:
			_carve_corridor(grid, rooms[a].get_center(), rooms[b].get_center())
	
	for room in rooms:
		if room.size.x >= 6 and room.size.y >= 5:
			var center: Vector2i = room.get_center()
			grid[center.y][center.x] = "#"
			grid[center.y][center.x - 1] = "#"
	
	if not _place_markers(grid):
		return rows
	
	for y in range(GEN_HEIGHT):
		var line: String = ""
		for x in range(GEN_WIDTH):
			line += grid[y][x]
		rows.append(line)
	
	return rows

func _room_overlaps(room: Rect2i, rooms: Array[Rect2i]) -> bool:
	var padded_room: Rect2i = room.grow(1)
	
	for other_room in rooms:
		if padded_room.intersects(other_room):
			return true
	
	return false

func _carve_rect(grid: Array, room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			grid[y][x] = "."

func _carve_corridor(grid: Array, from_cell: Vector2i, to_cell: Vector2i) -> void:
	if map_rng.randf() < 0.5:
		for x in range(
			mini(from_cell.x, to_cell.x),
			maxi(from_cell.x, to_cell.x) + 1
		):
			grid[from_cell.y][x] = "."
		
		for y in range(
			mini(from_cell.y, to_cell.y,),
			maxi(from_cell.y, to_cell.y) + 1
		):
			grid[y][to_cell.x] = "."
	else:
		for y in range(
			mini(from_cell.y, to_cell.y),
			maxi(from_cell.y, to_cell.y) + 1
		):
			grid[y][from_cell.x] ="."
		
		for x in range(
			mini(from_cell.x, to_cell.x),
			maxi(from_cell.x, to_cell.x) + 1
		):
			grid[to_cell.y][x] = "."

func _grid_distances(grid: Array, start: Vector2i) -> Dictionary:
	var distances: Dictionary = {start: 0}
	var queue: Array[Vector2i] = [start]
	var head: int = 0
	
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		
		for direction in MOVE_ACTIONS.values():
			var next_cell: Vector2i = cell + direction
			
			if grid[next_cell.y][next_cell.x] != ".":
				continue
			
			if distances.has(next_cell):
				continue
			
			distances[next_cell] = distances[cell] + 1
			queue.append(next_cell)
	return distances

func _max_distance(distances: Dictionary) -> int:
	var best: int = 0
	for value in distances.values():
		best = maxi(best, value)
	return best

func _place_markers(grid: Array) -> bool:
	var floor_cells: Array[Vector2i] = []
	
	for y in range(GEN_HEIGHT):
		for x in range(GEN_WIDTH):
			if grid[y][x] == ".":
				floor_cells.append(Vector2i(x, y))
	
	var entrance: Vector2i = floor_cells[map_rng.randi_range(0, floor_cells.size() - 1)]
	var from_entrance: Dictionary = _grid_distances(grid, entrance)
	
	if from_entrance.size() != floor_cells.size():
		return false
	
	var max_from_entrance: int = _max_distance(from_entrance)
	var card_options: Array[Vector2i] = []
	
	for cell in floor_cells:
		if from_entrance[cell] >= max_from_entrance * 0.6:
			card_options.append(cell)
	
	var card: Vector2i = card_options[map_rng.randi_range(0, card_options.size() - 1)]
	
	if from_entrance[card] < GEN_MIN_ENTRANCE_TO_CARD:
		return false
	
	var from_card: Dictionary = _grid_distances(grid, card)
	var max_from_card: int = _max_distance(from_card)
	var exit_options: Array[Vector2i] = []
	
	for cell in floor_cells:
		if from_card[cell] >= max_from_card * 0.6 and from_entrance[cell] >= 8:
			exit_options.append(cell)
	
	if exit_options.is_empty():
		return false
	
	var exit: Vector2i = exit_options[map_rng.randi_range(0, exit_options.size() - 1)]
	var monster_options: Array[Vector2i] = []
	
	for cell in floor_cells:
		var near_card: bool = from_card[cell] >= 5 and from_card[cell] <= 10
		if near_card and from_entrance[cell] >= 14 and cell != exit:
			monster_options.append(cell)
	
	if monster_options.is_empty():
		return false
	
	var monster: Vector2i = monster_options[map_rng.randi_range(0, monster_options.size() - 1)]
	
	grid[entrance.y][entrance.x] = "E"
	grid[card.y][card.x] = "K"
	grid[exit.y][exit.x] = "X"
	grid[monster.y][monster.x] = "M"
	return true

func _build_astar() -> void:
	astar.region = Rect2i(0, 0, map_width, map_height)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	astar.update()
	
	for cell in wall_cells:
		astar.set_point_solid(cell, true)

func _set_monster_path(target_cell: Vector2i) -> void:
	monster_path = astar.get_id_path(monster_cell, target_cell)
	
	if not monster_path.is_empty() and monster_path[0] == monster_cell:
		monster_path.pop_front()

func _monster_move_time_for_state() -> float:
	match monster_state:
		MonsterState.INVESTIGATING:
			return MONSTER_INVESTIGATE_MOVE_TIME
		MonsterState.SEARCHING:
			return MONSTER_SEARCH_MOVE_TIME
		MonsterState.STALKING:
			return MONSTER_STALK_MOVE_TIME
		MonsterState.HUNTING:
			return MONSTER_HUNT_MOVE_TIME
		_:
			return MONSTER_ROAM_MOVE_TIME

func _pick_roam_target() -> Vector2i:
	if walkable_cells.is_empty():
		return monster_cell
	
	if monster_rng.randf() < MONSTER_GUARD_CHANCE:
		var objective_cell: Vector2i = card_cell
		
		if has_access_card:
			objective_cell = exit_cell
		
		return _pick_cell_near(
			objective_cell,
			MONSTER_GUARD_RADIUS
		)
	
	for _attempt in range(MONSTER_ROAM_ATTEMPTS):
		var random_index: int = monster_rng.randi_range(0, walkable_cells.size() - 1)
		var candidate: Vector2i = walkable_cells[random_index]
		
		var distance: int = (
			absi(candidate.x - monster_cell.x) + absi(candidate.y - monster_cell.y)
		)
		if candidate != monster_cell and distance >= MONSTER_ROAM_MIN_DISTANCE:
			return candidate
	
	var fallback_index: int = monster_rng.randi_range(0, walkable_cells.size()- 1)
	
	return walkable_cells[fallback_index]

func _update_monster_movement(delta: float) -> void:
	if monster_is_attacking and not is_monster_moving:
		return
	
	if monster_listen_remaining > 0.0:
		monster_listen_remaining -= delta
		
		if not is_monster_moving:
			return
	
	if is_monster_moving:
		monster_move_elapsed += delta
		
		var progress: float = minf(
			monster_move_elapsed / monster_current_move_time,
			1.0
		)
		
		monster_draw_position = monster_move_source.lerp(
			monster_move_destination,
			progress
		)
		
		if progress >= 1.0:
			monster_cell = monster_move_destination_cell
			monster_draw_position = monster_move_destination
			is_monster_moving = false
	
	if monster_listen_remaining > 0.0 and not is_monster_moving:
		return
	
	if not is_monster_moving and not monster_path.is_empty():
		monster_move_destination_cell = monster_path.pop_front()
		monster_move_source = monster_draw_position
		monster_move_destination = _cell_center(monster_move_destination_cell)
		monster_move_elapsed = 0.0
		monster_current_move_time = _monster_move_time_for_state()
		is_monster_moving = true
		

func _update_monster_roaming(delta: float) -> void:
	if is_monster_moving:
		return
	
	if not monster_path.is_empty():
		return
	
	monster_roam_wait_remaining -= delta
	
	if monster_roam_wait_remaining > 0.0:
		return
	
	var target_cell: Vector2i = _pick_roam_target()
	_set_monster_path(target_cell)
	
	monster_roam_wait_remaining = MONSTER_ROAM_WAIT

func _begin_monster_investigation(target_cell: Vector2i) -> void:
	monster_state = MonsterState.INVESTIGATING
	monster_investigation_target = target_cell
	
	monster_path.clear()
	
	monster_needs_new_path = true
	monster_roam_wait_remaining = 0
	

func _begin_monster_search(center_cell: Vector2i) -> void:
	monster_state = MonsterState.SEARCHING
	monster_search_center = center_cell 
	monster_search_time_remaining = MONSTER_SEARCH_DURATION
	monster_search_wait_remaining = 0.0
	monster_path.clear()

func _begin_monster_stalking(target_cell: Vector2i) -> void:
	if monster_state != MonsterState.STALKING:
		monster_stalk_distance = MONSTER_STALK_DISTANCE_START
		monster_stalk_creep_remaining = MONSTER_STALK_CREEP_SECONDS
		monster_stalk_quiet_time = 0.0
		monster_lunge_remaining = 0.0
	
	monster_state = MonsterState.STALKING
	monster_stalk_target = target_cell
	monster_path.clear()
	monster_needs_new_path = true

func _set_monster_stalk_path() -> void:
	_set_monster_path(monster_stalk_target)
	var kept_steps: int = maxi(monster_path.size() - monster_stalk_distance, 0) ## This should in theory cut off the steps before it actually reaches the player, to actually... stalk
	monster_path.resize(kept_steps)

func _update_monster_stalking(delta: float) -> void:
	if monster_lunge_remaining > 0.0:
		monster_lunge_remaining -= delta
		monster_path.clear()
		
		if monster_lunge_remaining <= 0.0:
			_begin_monster_hunting(player_cell)
			
		return
	
	if monster_awareness < AWARENESS_STALK_EXIT:
		_begin_monster_search(monster_cell) ## If it loses interest it looks around where it is then wanders away
		return
		
	monster_stalk_quiet_time += delta
	
	if is_monster_moving:
		return
	
	if monster_needs_new_path:
		_set_monster_stalk_path()
		monster_needs_new_path = false
		return
	
	if not monster_path.is_empty():
		return
		
	if monster_stalk_quiet_time >= MONSTER_STALK_BACKOFF_SECONDS:
		monster_stalk_quiet_time = 0.0
		monster_stalk_creep_remaining = MONSTER_STALK_CREEP_SECONDS
			
		if monster_stalk_distance < MONSTER_STALK_DISTANCE_START:
			monster_stalk_distance += 1
			monster_needs_new_path = true
			
		return
	
	monster_stalk_creep_remaining -= delta
	if monster_stalk_creep_remaining <= 0.0:
		monster_stalk_creep_remaining = MONSTER_STALK_CREEP_SECONDS
		
		if monster_stalk_distance > MONSTER_STALK_DISTANCE_MIN:
			monster_stalk_distance -= 1
			monster_needs_new_path = true
		else:
			monster_lunge_remaining = MONSTER_LUNGE_PAUSE
			monster_lunge_start_time = game_time
			monster_path.clear()

func _begin_monster_hunting(target_cell: Vector2i) -> void:
	monster_state = MonsterState.HUNTING
	monster_awareness = 1.0
	monster_hunt_target = target_cell
	monster_hunt_lose_remaining = MONSTER_HUNT_LOSE_SECONDS
	monster_path.clear()
	monster_needs_new_path = true

func _update_monster_hunting(delta: float) -> void:
	if is_monster_moving:
		return
	
	if monster_needs_new_path:
		_set_monster_path(monster_hunt_target)
		monster_needs_new_path = false
		return
	
	if not monster_path.is_empty():
		return
	
	monster_hunt_lose_remaining -= delta
	if monster_hunt_lose_remaining <= 0.0:
		monster_awareness = AWARENESS_AFTER_LOST_HUNT
		_begin_monster_search(monster_hunt_target)

func _pick_cell_near(center: Vector2i, radius: int) -> Vector2i:
	var candidates: Array[Vector2i] = []
	
	for cell in walkable_cells:
		var distance: int = (
			absi(cell.x - center.x) + absi(cell.y - center.y)
		)
		
		if (
			distance > 0 
			and distance <= radius
			and cell != monster_cell
		):
			candidates.append(cell)
	if candidates.is_empty():
		return center
	
	var random_index: int = monster_rng.randi_range(0, candidates.size() - 1)
	
	return candidates[random_index]

func _update_monster_investigating() -> void:
	if is_monster_moving:
		return
	
	if monster_needs_new_path:
		_set_monster_path(monster_investigation_target)
		monster_needs_new_path = false
	
	if monster_path.is_empty():
		if monster_cell == monster_investigation_target:
			_begin_monster_search(monster_investigation_target)
		else:
			push_warning("Monster couldnt reach ping location?!")
			monster_state = MonsterState.ROAMING
			monster_roam_wait_remaining = MONSTER_ROAM_WAIT
	
		return


func _update_monster_searching(delta: float) -> void:
	monster_search_time_remaining -= delta
	
	if monster_search_time_remaining <= 0.0:
		monster_path.clear()
		
		if not is_monster_moving:
			monster_state = MonsterState.ROAMING
			monster_roam_wait_remaining = MONSTER_ROAM_WAIT
		
		return
	
	if is_monster_moving:
		return
	
	if not monster_path.is_empty():
		return
	
	monster_search_wait_remaining -= delta
	
	if monster_search_wait_remaining > 0.0:
		return
	
	var target_cell: Vector2i = _pick_cell_near(
		monster_search_center,
		MONSTER_SEARCH_RADIUS
	)
	
	if target_cell != monster_cell:
		_set_monster_path(target_cell)
	
	monster_search_wait_remaining = MONSTER_SEARCH_WAIT

func _process(delta: float) -> void:
	if not map_is_valid:
		return
	
	if game_over or has_won:
		if Input.is_action_just_pressed("restart"):
			retry_map_seed = current_map_seed
			retry_map_seed_is_set = true
			get_tree().reload_current_scene()
		
		queue_redraw()
		return
	
	game_time += delta
	_update_scan_points()
	
	if Input.is_action_just_pressed("ping"):
		_try_emit_ping()
	
	_update_held_directions()
	var target_angle: float = Vector2(player_facing).angle()
	player_draw_angle = lerp_angle(player_draw_angle, target_angle, minf(PLAYER_TURN_SPEED * delta, 1.0))
	
	if is_moving:
		move_elapsed += delta
		
		var progress: float = minf(move_elapsed / MOVE_TIME_PER_TILE, 1.0)
		
		player_draw_position = move_source.lerp(move_destination, progress)
		
		if progress >= 1.0:
			move_carry = minf(move_elapsed - MOVE_TIME_PER_TILE, MOVE_TIME_PER_TILE * 0.5)
			player_cell = move_destination_cell
			player_draw_position = move_destination
			is_moving = false
			_make_noise(player_cell, FOOTSTEP_NOISE_RANGE_TILES, AWARENESS_PER_FOOTSTEP)
	
	if not is_moving:
		var next_direction: Vector2i = _choose_move_direction()
		buffered_direction = Vector2i.ZERO
		
		if next_direction != Vector2i.ZERO:
			_try_start_move(next_direction)
		
		move_carry = 0.0
	
	_update_pulses(delta)
	_update_monster_movement(delta)
	_update_proximity_sense()
	_update_monster_ai(delta)
	_check_card_collection()
	_check_player_caught(delta)
	_check_for_victory()
	
	queue_redraw()

func _update_held_directions() -> void:
	for action in MOVE_ACTIONS:
		var direction: Vector2i = MOVE_ACTIONS[action]
		
		if Input.is_action_just_pressed(action):
			held_directions.erase(direction)
			held_directions.append(direction)
			buffered_direction = direction
		elif not Input.is_action_pressed(action):
			held_directions.erase(direction)

func _choose_move_direction() -> Vector2i:
	var candidates: Array[Vector2i] = []
	
	if buffered_direction != Vector2i.ZERO:
		candidates.append(buffered_direction)
	
	for i in range(held_directions.size() -1, -1, -1):
		candidates.append(held_directions[i])
	
	for direction in candidates:
		if _is_walkable(player_cell + direction):
			return direction
	
	if candidates.is_empty():
		return Vector2i.ZERO
	return candidates[0]
 
func _try_start_move(direction: Vector2i) -> void:
	if player_facing != direction:
		player_facing = direction
	
	var destination_cell: Vector2i = player_cell + direction
	
	if not _is_walkable(destination_cell):
		return
	
	move_destination_cell = destination_cell
	move_source = player_draw_position
	move_destination = _cell_center(destination_cell)
	move_elapsed = move_carry
	is_moving = true
	

func _is_walkable(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0:
		return false
	if cell.x >= map_width or cell.y >= map_height:
		return false
	
	var tile: String = map_rows[cell.y].substr(cell.x, 1)
	return tile != "#"
	

func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(
		(float(cell.x) + 0.5) * TILE_SIZE,
		(float(cell.y) + 0.5) * TILE_SIZE
	)

func _cell_from_position(pixel_position: Vector2) -> Vector2i:
	return Vector2i(
		floori(pixel_position.x / TILE_SIZE),
		floori(pixel_position.y / TILE_SIZE)
	)

func _is_wall(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0:
		return true
	if cell.x >= map_width or cell.y >= map_height:
		return true
	
	return map_rows[cell.y].substr(cell.x, 1) == "#"

func _has_line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var x: int = from_cell.x
	var y: int = from_cell.y
	
	var dx: int = absi(to_cell.x - from_cell.x)
	var dy: int = -absi(to_cell.y - from_cell.y)
	var step_x: int = 1 if from_cell.x < to_cell.x else -1
	var step_y: int = 1 if from_cell.y < to_cell.y else -1 
	var error: int = dx + dy
	
	while true: 
		if x == to_cell.x and y == to_cell.y:
			return true
		
		var is_start: bool = (x == from_cell.x and y == from_cell.y)
		if not is_start and _is_wall(Vector2i(x, y)):
			return false
			
		var error_doubled: int = 2 * error
		
		if error_doubled >= dy:
			error += dy
			x += step_x
		
		if error_doubled <= dx: 
			error += dx
			y += step_y
	return true

func _cast_scan_ray(origin: Vector2, direction: Vector2, max_distance: float) -> ScanPoint:
	var cell: Vector2i = _cell_from_position(origin)
	var step_x: int = 1 if direction.x > 0.0 else -1
	var step_y: int = 1 if direction.y > 0.0 else -1
	
	var t_max_x: float  = INF
	var t_delta_x: float = INF
	if not is_zero_approx(direction.x):
		var boundary_x: float = float(cell.x + (1 if step_x > 0 else 0)) * TILE_SIZE
		t_max_x = (boundary_x - origin.x) / direction.x
		t_delta_x = TILE_SIZE / absf(direction.x)
	
	var t_max_y: float = INF
	var t_delta_y: float = INF
	if not is_zero_approx(direction.y):
		var boundary_y: float = float(cell.y + (1 if step_y > 0 else 0)) * TILE_SIZE
		t_max_y = (boundary_y - origin.y) / direction.y
		t_delta_y = TILE_SIZE / absf(direction.y)
	
	for _step in range(64):
		var t: float
		var tangent: Vector2
		
		if t_max_x < t_max_y:
			t = t_max_x
			t_max_x += t_delta_x
			cell.x += step_x
			tangent = Vector2(0.0, 1.0)
		else:
			t = t_max_y
			t_max_y += t_delta_y
			cell.y += step_y
			tangent = Vector2(1.0, 0.0)
		
		if t > max_distance:
			return null
		
		if _is_wall(cell):
			var point: ScanPoint = ScanPoint.new()
			point.position = origin + direction * t
			point.tangent = tangent
			point.distance = t 
			return point
	return null

func _monster_ray_hit_distance(origin: Vector2, direction: Vector2, monster_position: Vector2) -> float:
	var to_monster: Vector2 = monster_position - origin
	var along: float = to_monster.dot(direction)
	
	if along <= 0.0:
		return INF
	
	var miss_squared: float = to_monster.length_squared() - along * along
	var radius_squared: float = MONSTER_SCAN_RADIUS * MONSTER_SCAN_RADIUS
	
	if miss_squared > radius_squared:
		return INF
	
	var hit_distance: float = along - sqrt(radius_squared - miss_squared) 
	
	if hit_distance <= 0.0:
		return INF
	
	return hit_distance

func _build_pulse_hits(pulse: SonarPulse) -> void:
	var angle_offset: float = scan_rng.randf_range(0.0, TAU / SCAN_RAY_COUNT)
	
	for ray_index in range(SCAN_RAY_COUNT):
		var angle: float = angle_offset + TAU * float(ray_index) / SCAN_RAY_COUNT
		var direction: Vector2 = Vector2.from_angle(angle)
		var hit: ScanPoint = _cast_scan_ray(pulse.origin, direction, PING_MAX_RADIUS)
		pulse.wave_directions.append(direction)
		
		var wall_distance: float = PING_MAX_RADIUS
		
		if hit != null:
			wall_distance = hit.distance
			
		var monster_distance: float = _monster_ray_hit_distance(pulse.origin, direction, pulse.monster_position_at_ping)
			
		if monster_distance < wall_distance:
			pulse.wave_stop_distances.append(monster_distance)
			var return_point: ScanPoint = ScanPoint.new()
			return_point.position = pulse.origin + direction * monster_distance
			
			var outward: Vector2 = (
				return_point.position - pulse.monster_position_at_ping
			).normalized()
			return_point.tangent = Vector2(-outward.y, outward.x)
			
			return_point.distance = monster_distance
			return_point.is_monster_return = true
			pulse.hits.append(return_point)
			pulse.monster_scan_was_hit = true
			continue
		
		if hit == null:
			pulse.wave_stop_distances.append(PING_MAX_RADIUS)
			continue
		
		pulse.wave_stop_distances.append(hit.distance)
		
		hit.position += Vector2(
			scan_rng.randf_range(-SCAN_JITTER, SCAN_JITTER),
			scan_rng.randf_range(-SCAN_JITTER, SCAN_JITTER)
		)
		pulse.hits.append(hit)
	
	pulse.hits.sort_custom(func(a: ScanPoint, b: ScanPoint) -> bool: return a.distance < b.distance)

func _try_emit_ping() -> void:
	if game_time - last_ping_time < PING_COOLDOWN:
		return
	
	var origin: Vector2 = player_draw_position
	var origin_cell: Vector2i = _cell_from_position(origin)
	
	var pulse: SonarPulse = SonarPulse.new(origin, origin_cell)
	pulse.monster_position_at_ping = monster_draw_position
	pulse.monster_center_distance_at_ping = origin.distance_to(pulse.monster_position_at_ping)
	_build_pulse_hits(pulse)
	active_pulses.append(pulse)
		
	_make_noise(origin_cell, PING_NOISE_RANGE_TILES, AWARENESS_PER_PING)
	last_ping_time = game_time

func _make_noise(cell: Vector2i, range_tiles: float, loudness: float) -> void:
	if is_equal_approx(last_noise_time, game_time) and loudness < last_noise_loudness:
		return
	
	last_noise_cell = cell
	last_noise_time = game_time
	last_noise_range_tiles = range_tiles
	last_noise_loudness = loudness

func _monster_can_hear(cell: Vector2i, range_tiles: float) -> bool:
	var distance: float = monster_draw_position.distance_to(_cell_center(cell))
	return distance <= range_tiles * TILE_SIZE
 
func _update_pulses(delta: float) -> void:
	if active_pulses.is_empty():
		return
	
	for pulse in active_pulses:
		pulse.previous_radius = pulse.radius
		pulse.radius = minf(pulse.radius + PING_SPEED * delta, PING_MAX_RADIUS)
		_reveal_scan_for_pulse(pulse)
		_reveal_monster_for_pulse(pulse)
		_reveal_card_for_pulse(pulse)
		_reveal_exit_for_pulse(pulse)
	
	for i in range(active_pulses.size() - 1, -1, -1):
		if active_pulses[i].radius >= PING_MAX_RADIUS:
			active_pulses.remove_at(i)

func _sense_range_for_state() -> float:
	match monster_state:
		MonsterState.ROAMING, MonsterState.SEARCHING:
			return SENSE_RANGE_QUIET_TILES
		_:
			return SENSE_RANGE_TILES

func _update_proximity_sense() -> void:
	for i in range(sense_arcs.size() -1, -1, -1):
		if game_time - sense_arcs[i].born_time > SENSE_ARC_DURATION:
			sense_arcs.remove_at(i)
	
	if game_time < next_sense_time:
		return
	
	var to_monster: Vector2 = monster_draw_position - player_draw_position
	var distance_tiles: float = to_monster.length() / TILE_SIZE
	var range_tiles: float = _sense_range_for_state()
	
	if distance_tiles > range_tiles:
		next_sense_time = game_time + SENSE_INTERVAL_FAR
		return
	
	var closeness: float = 1.0 - clampf(distance_tiles / range_tiles, 0.0, 1.0)
	
	next_sense_time = game_time + lerpf(SENSE_INTERVAL_FAR, SENSE_INTERVAL_NEAR, closeness)
	
	var arc: SenseArc = SenseArc.new()
	arc.origin = player_draw_position
	arc.angle = to_monster.angle()
	arc.closeness = closeness
	arc.born_time = game_time
	sense_arcs.append(arc)
	
	var jitter: float = SENSE_JITTER_MAX * (1.0 - closeness)
	
	if not _has_line_of_sight(player_cell, _cell_from_position(monster_draw_position)):
		jitter += SENSE_JITTER_MAX * 0.6
	
	monster_sense_position = monster_draw_position + Vector2(
		monster_rng.randf_range(-jitter, jitter),
		monster_rng.randf_range(-jitter, jitter)
	)
	monster_sense_time = game_time
	monster_sense_confidence = closeness

func _update_monster_ai(delta: float) -> void:
	if monster_is_attacking:
		return
		
	var decay_rate: float = AWARENESS_DECAY_PER_SECOND
	if monster_state == MonsterState.STALKING:
		decay_rate = AWARENESS_STALK_DECAY_PER_SECOND
	elif monster_state == MonsterState.HUNTING:
		decay_rate = 0.0
	monster_awareness = maxf(monster_awareness - decay_rate * delta, 0.0)
	
	if last_noise_time > monster_last_heard_noise_time:
		monster_last_heard_noise_time = last_noise_time
		
		if _monster_can_hear(last_noise_cell, last_noise_range_tiles):
			_on_monster_heard_noise()
	
	match monster_state:
		MonsterState.ROAMING:
			_update_monster_roaming(delta)
		
		MonsterState.INVESTIGATING:
			_update_monster_investigating()
		
		MonsterState.SEARCHING:
			_update_monster_searching(delta)
		
		MonsterState.STALKING:
			_update_monster_stalking(delta)
		
		MonsterState.HUNTING:
			_update_monster_hunting(delta)

func _on_monster_heard_noise() -> void:
	if monster_state == MonsterState.HUNTING and last_noise_loudness < AWARENESS_PER_PING:
		return
	var noise_distance: float = monster_draw_position.distance_to(_cell_center(last_noise_cell))
	var noise_is_close: bool = noise_distance <= MONSTER_HUNT_PROXIMITY_TILES * TILE_SIZE
	var stalking_and_close: bool = monster_state == MonsterState.STALKING and noise_is_close
	
	var falloff: float = clampf(1.0 - (noise_distance / TILE_SIZE) / AWARENESS_FALLOFF_TILES, AWARENESS_FALLOFF_FLOOR, 1.0)
	monster_awareness = minf(monster_awareness + last_noise_loudness * falloff, 1.0)
	
	if last_noise_loudness >= AWARENESS_PER_PING and monster_state != MonsterState.HUNTING:
		monster_listen_remaining = MONSTER_LISTEN_PAUSE
	
	if monster_state == MonsterState.STALKING:
		monster_stalk_quiet_time = 0.0
		monster_stalk_creep_remaining -= MONSTER_STALK_NOISE_CREEP_BONUS
		
		if monster_lunge_remaining > 0.0:
			return
	
	if monster_awareness >= AWARENESS_HUNT_THRESHOLD or stalking_and_close:
		_begin_monster_hunting(last_noise_cell)
	elif monster_awareness >= AWARENESS_STALK_THRESHOLD:
		_begin_monster_stalking(last_noise_cell)
	else:
		_begin_monster_investigation(last_noise_cell)

func _reveal_scan_for_pulse(pulse: SonarPulse) -> void:
	while pulse.next_hit_index < pulse.hits.size():
		var hit: ScanPoint = pulse.hits[pulse.next_hit_index]
		
		if hit.distance > pulse.radius:
			return
		
		hit.born_time = game_time
		scan_points.append(hit)
		pulse.next_hit_index += 1

func _update_scan_points() -> void:
	var total_life: float = WALL_FLASH_DURATION + SCAN_HOLD_DURATION + SCAN_FADE_DURATION
	while not scan_points.is_empty():
		var oldest_point: ScanPoint = scan_points[0]
		var point_lifetime: float = total_life
		
		if oldest_point.is_monster_return:
			point_lifetime = MONSTER_SCAN_RETURN_DURATION
		
		if game_time - oldest_point.born_time < point_lifetime:
			break
		
		scan_points.remove_at(0)
	
	while scan_points.size() > SCAN_MAX_POINTS:
		scan_points.remove_at(0)

func _reveal_card_for_pulse(pulse: SonarPulse) -> void:
	if has_access_card:
		return
	
	var distance: float = pulse.origin.distance_to(card_draw_position)
	var ring_reached_card: bool = (
		distance > pulse.previous_radius
		and distance <= pulse.radius
	)
	if not ring_reached_card:
		return
	
	if not _has_line_of_sight(pulse.origin_cell, card_cell):
		return
	
	card_discovered = true
	card_last_lit_time = game_time

func _reveal_exit_for_pulse(pulse: SonarPulse) -> void:
	var distance: float = pulse.origin.distance_to(exit_draw_position)
	var ring_reached_exit: bool = (
		distance > pulse.previous_radius
		and distance <= pulse.radius
	)
	if not ring_reached_exit:
		return
	
	if not _has_line_of_sight(pulse.origin_cell, exit_cell):
		return
	
	exit_discovered = true
	exit_last_lit_time = game_time
 
func _reveal_monster_for_pulse(pulse: SonarPulse) -> void:
	if not pulse.monster_scan_was_hit:
		return
	
	if pulse.monster_snapshot_revealed:
		return
	
	var surface_distance: float = maxf(
		pulse.monster_center_distance_at_ping - MONSTER_SCAN_RADIUS, 0.0
	)
	
	if surface_distance > pulse.radius:
		return
	
	pulse.monster_snapshot_revealed = true
	_build_monster_shape()
	monster_snapshot_position = pulse.monster_position_at_ping
	monster_snapshot_time = game_time

func _check_card_collection() -> void:
	if has_access_card:
		return
	
	if player_cell != card_cell:
		return
	
	has_access_card = true
	card_discovered = true

func _check_for_victory() -> void:
	if has_won or game_over:
		return
	
	if not has_access_card:
		return
	
	if player_cell != exit_cell:
		return
	
	has_won = true
	active_pulses.clear()
	monster_path.clear()

func _draw() -> void:
	if not map_is_valid:
		return
	
	var map_pixel_size: Vector2 = Vector2(
		map_width * TILE_SIZE,
		map_height * TILE_SIZE
	)
	
	draw_rect(
		Rect2(Vector2.ZERO, map_pixel_size),
		BACKGROUND_COLOR,
		true
	)
	_draw_scan_points()
	_draw_pulses()
	_draw_access_card()
	_draw_exit_marker()
	_draw_sense_arcs()
	_draw_sense_contact()
	_draw_monster_snapshot()
	_draw_monster_lunge()
	_draw_monster_attack()
	
	if DEBUG_SHOW_MONSTER:
		_draw_debug_path()
		_draw_monster_ai_debug()
		_draw_awareness_debug()
		draw_arc(monster_draw_position, PING_NOISE_RANGE_TILES * TILE_SIZE, 0.0, TAU, 64, Color(1.0, 0.3, 0.3, 0.15), 1.0, true)
		_draw_monster_at(monster_draw_position, 0.35)
	
	_draw_footsteps_ring()
	_draw_player()
	_draw_hud()
	
	if game_over:
		_draw_game_over()
	elif has_won:
		_draw_victory()

func _build_monster_shape() -> void:
	monster_dot_offsets.clear()
	monster_dot_sizes.clear()
	
	var dot_count: int = MONSTER_DOT_COUNT + monster_rng.randi_range(
		-MONSTER_DOT_COUNT_VARIANCE,
		MONSTER_DOT_COUNT_VARIANCE
	)
	
	for _dot_index in range(dot_count):
		var angle: float = monster_rng.randf_range(0.0, TAU)
		var distance: float = monster_rng.randf_range(0.0, MONSTER_CLUSTER_RADIUS)
		
		var dot_offset: Vector2 = Vector2.from_angle(angle) * distance
		var dot_radius: float = monster_rng.randf_range(1.5, 4.0)
		
		monster_dot_offsets.append(dot_offset)
		monster_dot_sizes.append(dot_radius)

func _draw_scan_points() -> void:
	if scan_points.is_empty():
		return
	
	var segments: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	
	segments.resize(scan_points.size() * 2)
	colors.resize(scan_points.size())
	
	for index in range(scan_points.size()):
		var point: ScanPoint = scan_points[index]
		var half_segment: Vector2 = point.tangent * (SCAN_POINT_LENGTH * 0.5)
		
		segments[index * 2] = point.position - half_segment
		segments[index * 2 + 1] = point.position + half_segment
		var point_age: float = game_time - point.born_time
		
		if point.is_monster_return:
			var return_alpha: float = clampf(
				1.0 - point_age / MONSTER_SCAN_RETURN_DURATION,
				0.0,
				1.0
			)
			colors[index] = Color(MONSTER_SCAN_RETURN_COLOR, return_alpha)
		else:
			colors[index] = Color(WALL_COLOR, _scan_point_alpha(point_age))
		
	draw_multiline_colors(segments, colors, SCAN_POINT_WIDTH)

func _scan_point_alpha(age: float) -> float:
	if age < WALL_FLASH_DURATION:
		var flash: float = 1.0 - age / WALL_FLASH_DURATION
		return lerpf(WALL_DIM_SEEN_ALPHA, 1.0, flash * flash)
	
	var memory_age: float = age - WALL_FLASH_DURATION - SCAN_HOLD_DURATION
	
	if memory_age <= 0.0:
		return WALL_DIM_SEEN_ALPHA
	
	return WALL_DIM_SEEN_ALPHA * clampf(1.0 - memory_age / SCAN_FADE_DURATION, 0.0, 1.0)

func _draw_access_card() -> void:
	if has_access_card: 
		return
	
	if not card_discovered:
		return
	
	var seconds_since_lit: float = game_time - card_last_lit_time
	
	var flash: float = clampf(
		1.0 - seconds_since_lit / CARD_FLASH_DURATION,
		0.0,
		1.0
	)
	
	var alpha: float = lerpf(
		CARD_DIM_ALPHA,
		1.0,
		flash
	)
	
	var color: Color = Color(CARD_COLOR, alpha)
	
	var card_rect: Rect2 = Rect2(
		card_draw_position - Vector2(12.0, 8.0),
		Vector2(24.0, 16.0)
	)
	
	draw_rect(card_rect, color, false, 2.0)
	
	draw_line(
		card_draw_position + Vector2(-7.0, 3.0),
		card_draw_position + Vector2(7.0, 3.0),
		color,
		2.0
	)
	
	draw_circle(
		card_draw_position + Vector2(-6.0, -3.0),
		2.0,
		color
	)

func _draw_exit_marker() -> void:
	if not exit_discovered:
		return
	
	var seconds_since_lit: float = game_time - exit_last_lit_time
	
	var flash: float = clampf(
		1.0 - seconds_since_lit / EXIT_FLASH_DURATION,
		0.0,
		1.0
	)
	
	var alpha: float = lerpf(EXIT_DIM_ALPHA, 1.0, flash)
	
	var base_color: Color
	if has_access_card: 
		base_color = EXIT_OPEN_COLOR
	else:
		base_color = EXIT_LOCKED_COLOR
	
	var color: Color = Color(base_color, alpha)
	
	var door_rect: Rect2 = Rect2(
		exit_draw_position - Vector2(8.0, 11.0),
		Vector2(16.0, 22.0)
	)
	
	draw_rect(door_rect, color, false, 2.0)
	draw_circle(exit_draw_position + Vector2(4.0, 0.0), 2.0, color)

func _draw_pulses() -> void:
	for pulse in active_pulses:
		var life: float = pulse.radius / PING_MAX_RADIUS
		var alpha: float = 1.0 - life
		
		_draw_ping_front(pulse, alpha)

func _draw_ping_front(pulse: SonarPulse, alpha: float) -> void:
	var segments: PackedVector2Array = PackedVector2Array()
	var ray_count: int = pulse.wave_directions.size()
	
	for ray_index in range(ray_count):
		var next_index: int = (ray_index + 1) % ray_count
		
		if pulse.radius >= pulse.wave_stop_distances[ray_index]:
			continue
		
		if pulse.radius >= pulse.wave_stop_distances[next_index]:
			continue
		
		var start: Vector2 = (
			pulse.origin + pulse.wave_directions[ray_index] * pulse.radius
		)
		
		var end: Vector2 = (
			pulse.origin + pulse.wave_directions[next_index] * pulse.radius
		)
		
		segments.append(start)
		segments.append(end)
	
	if segments.is_empty():
		return
	
	draw_multiline(
		segments,
		Color(PING_RING_COLOR, alpha),
		PING_RING_WIDTH
	)

func _draw_player() -> void:
	var forward: Vector2 = Vector2.from_angle(player_draw_angle)
	var side: Vector2 = Vector2(-forward.y, forward.x)
	
	var stretch: float = 0.0
	
	if is_moving:
		var progress: float = clampf(move_elapsed / MOVE_TIME_PER_TILE, 0.0, 1.0)
		stretch = sin(progress * PI) * PLAYER_STRETCH
	
	var center: Vector2 = player_draw_position
	
	var nose: Vector2 = (
		center + forward * TILE_SIZE * (0.30 + stretch)
	)
	
	var rear_center: Vector2 = (
		center - forward * TILE_SIZE * (0.20 + stretch)
	)
	
	var half_width: float = TILE_SIZE * (0.20 - stretch * 0.5)
	
	var triangle: PackedVector2Array = PackedVector2Array([
		nose,
		rear_center + side * half_width,
		rear_center - side * half_width
	])
	
	draw_colored_polygon(triangle, PLAYER_COLOR)

func _draw_footsteps_ring() -> void:
	if not is_moving:
		return
	
	draw_arc(
		player_draw_position,
		FOOTSTEP_NOISE_RANGE_TILES * TILE_SIZE,
		0.0,
		TAU,
		48,
		FOOTSTEP_RING_COLOR,
		1.0,
		true
	)

func _draw_monster_at(center: Vector2, alpha: float) -> void:
	var color: Color = Color(MONSTER_COLOR, alpha)
	
	for dot_index in range(monster_dot_offsets.size()):
		var dot_position: Vector2 = center + monster_dot_offsets[dot_index]
		var dot_radius: float = monster_dot_sizes[dot_index]
		
		draw_circle(dot_position, dot_radius, color)

func _draw_monster_snapshot() -> void:
	var snapshot_age: float = game_time - monster_snapshot_time
	
	if snapshot_age < 0.0:
		return
	
	if snapshot_age > MONSTER_SNAPSHOT_FADE_DURATION:
		return
	
	var alpha: float = clampf(
		1.0 - snapshot_age / MONSTER_SNAPSHOT_FADE_DURATION,
		0.0,
		1.0
	)
	
	_draw_monster_at(monster_snapshot_position, alpha)

func _draw_sense_arcs() -> void:
	for arc in sense_arcs:
		var age: float = game_time - arc.born_time
		var t: float = clampf(age / SENSE_ARC_DURATION, 0.0, 1.0)
		
		var radius: float = SENSE_ARC_START + SENSE_ARC_SPEED * age
		var alpha: float  = (1.0 - t) * lerpf(0.30, 0.95, arc.closeness)
		
		var span: float = SENSE_ARC_SPAN * lerpf(1.7, 0.55, arc.closeness)
		
		draw_arc(
			arc.origin,
			radius,
			arc.angle - span * 0.5,
			arc.angle + span * 0.5,
			20,
			Color(SENSE_COLOR, alpha),
			1.5,
			true
		)

func _draw_sense_contact() -> void:
	var age: float = game_time - monster_sense_time
	
	if age < 0.0 or age > SENSE_STAMP_DURATION:
		return
	
	var fade: float =  1.0 - age / SENSE_STAMP_DURATION
	var alpha: float  = fade * lerpf(0.20, 0.75, monster_sense_confidence)
	
	_draw_monster_at(monster_sense_position, alpha)

func _draw_monster_lunge() -> void:
	if monster_lunge_remaining <= 0.0:
		return
	
	var age: float = game_time - monster_lunge_start_time
	var progress: float = clampf(age / MONSTER_LUNGE_PAUSE, 0.0, 1.0)
	
	var radius: float = lerpf(TILE_SIZE * 2.6, TILE_SIZE * 0.4, progress)
	var ring_alpha: float = 0.35 + progress * 0.5
	var monster_alpha: float = 0.4 + progress * 0.5
	
	draw_arc(
		monster_draw_position,
		radius,
		0.0,
		TAU,
		40,
		Color(MONSTER_LUNGE_RING_COLOR, ring_alpha),
		2.0,
		true
	)
	
	_draw_monster_at(monster_draw_position, monster_alpha)

func _draw_monster_attack() -> void:
	if not monster_is_attacking:
		return
	
	var age: float = game_time - monster_attack_start_time
	var progress: float = clampf(age / MONSTER_ATTACK_WINDUP, 0.0, 1.0)
	
	draw_arc(
		monster_draw_position,
		MONSTER_ATTACK_TRIGGER_DISTANCE,
		0.0,
		TAU,
		32,
		Color(MONSTER_LUNGE_RING_COLOR, 0.4 + progress * 0.6),
		3.0,
		true
	)
	
	_draw_monster_at(monster_draw_position, 1.0)

func _draw_monster_ai_debug() -> void:
	var target_center: Vector2
	var marker_color: Color
	
	match monster_state:
		MonsterState.INVESTIGATING:
			target_center = _cell_center(monster_investigation_target)
			marker_color = Color(1.0, 0.55, 0.1, 0.9)
		MonsterState.SEARCHING:
			target_center = _cell_center(monster_search_center)
			marker_color = Color(0.7, 0.2, 1.0, 0.9)
		MonsterState.STALKING:
			target_center = _cell_center(monster_stalk_target)
			marker_color = Color(0.95, 0.95, 0.95, 0.9)
			draw_arc(
				target_center,
				monster_stalk_distance * TILE_SIZE,
				0.0, TAU, 48,
				Color(marker_color, 0.25),
				1.0, true
			)
		MonsterState.HUNTING:
			target_center = _cell_center(monster_hunt_target)
			marker_color = Color(1.0, 0.1, 0.1, 1.0)
		_:
			return
	
	var marker_rect : Rect2 = Rect2(
		target_center - Vector2(8.0, 8.0),
		Vector2(16.0, 16.0)
	)
	
	draw_rect(marker_rect, marker_color, false, 2.0)

func _draw_awareness_debug() -> void:
	var bar_position: Vector2 = monster_draw_position + Vector2(-15.0, -24.0)
	var bar_size: Vector2 = Vector2(30.0, 4.0)
	
	draw_rect(Rect2(bar_position, bar_size), Color(0.3, 0.3, 0.3, 0.8), true)
	draw_rect(Rect2(bar_position, Vector2(bar_size.x * monster_awareness, bar_size.y)), Color(1.0, 0.3, 0.2, 0.9), true)
	
	var state_name: String = MonsterState.keys()[monster_state]
	draw_string(
		ThemeDB.fallback_font,
		bar_position + Vector2(0.0, -4.0),
		state_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		10,
		Color(1.0, 1.0, 1.0, 0.8)
	)

func _draw_debug_path() -> void:
	var color: Color = Color(1.0, 0.85, 0.2, 0.8)
	
	for cell in monster_path:
		var center: Vector2 = _cell_center(cell)
		draw_circle(center, 3.0, color)

func _draw_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	var objective_text: String
	
	if has_access_card:
		objective_text = "OBJECTIVE: FIND THE EXIT"
	else:
		objective_text = "OBJECTIVE: FIND THE ACCESS CARD"
	
	draw_string(
		font,
		Vector2(18.0, 28.0),
		objective_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		500.0,
		16,
		Color(0.75, 1.0, 0.82, 0.9)
	)
	
	var map_label: String = "MAP %d" % current_map_seed
	
	if not USE_PROCEDURAL_MAP:
		map_label = "TEST MAP"
	
	draw_string(
		font,
		Vector2(0.0, 28.0),
		map_label,
		HORIZONTAL_ALIGNMENT_RIGHT,
		map_width * TILE_SIZE - 18.0,
		12,
		Color(0.75, 1.0, 0.82, 0.75)
	)
	
	_draw_ping_cooldown()

func _draw_ping_cooldown() -> void:
	var bar_position: Vector2 = Vector2(18.0, 42.0)
	var bar_size: Vector2 = Vector2(140.0, 8.0)
	
	var cooldown_progress: float = clampf(
		(game_time - last_ping_time) / PING_COOLDOWN,
		0.0,
		1.0
	)
	
	draw_rect(
		Rect2(bar_position, bar_size),
		Color(0.1, 0.25, 0.14, 0.8),
		true
	)
	
	draw_rect(
		Rect2(bar_position, Vector2(bar_size.x * cooldown_progress, bar_size.y)),
		PING_RING_COLOR,
		true
	)
	
	draw_rect(
		Rect2(bar_position, bar_size),
		Color(0.45, 1.0, 0.6, 0.8),
		false,
		1.0
	)
