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
const PLAYER_STRETCH: float = 0.12

const PING_SPEED: float = 320.0 ## This is how fast the ring/circle grows 
const PING_MAX_RADIUS: float = 8.5 * TILE_SIZE
const PING_COOLDOWN: float = 0.6
const PING_RING_WIDTH: float = 1.0
const PING_RING_COLOR: Color = Color(0.35, 1.0, 0.35, 1.0)
const PING_NOISE_RANGE_TILES: float = 12.0 ## How far the monster can hear a ping, its larger than the radius on purpose

const FOOTSTEP_NOISE_RANGE_TILES: float = 3.5
const FOOTSTEP_RING_COLOR: Color = Color(0.35, 1.0, 0.35, 1.0)

const AWARENESS_PER_PING: float = 0.45
const AWARENESS_PER_FOOTSTEP: float = 0.06
const AWARENESS_DECAY_PER_SECOND: float = 0.04
 
const AWARENESS_STALK_THRESHOLD: float = 0.5 ## Enters stalking above this
const AWARENESS_STALK_EXIT: float = 0.25 ## Exits stalking below this
const AWARENESS_STALK_DECAY_PER_SECOND: float = 0.02

const MONSTER_STALK_MOVE_TIME: float = 0.16
const MONSTER_STALK_DISTANCE_START: int = 6
const MONSTER_STALK_DISTANCE_MIN: int = 2
const MONSTER_STALK_CREEP_SECONDS: float = 3.0

const AWARENESS_HUNT_THRESHOLD: float = 1.0
const AWARENESS_AFTER_LOST_HUNT: float = 0.3
const MONSTER_HUNT_MOVE_TIME: float = 0.11 
const MONSTER_HUNT_LOSE_SECONDS: float = 2.5
const MONSTER_HUNT_PROXIMITY_TILES: float = 2.0

const WALL_DIM_SEEN_ALPHA: float = 0.18 ## A wall thats been seen before never dims below this(its going to be an alpha, sigma oh my god!!!!)
const WALL_FLASH_DURATION: float = 1.2

const MONSTER_CATCH_DISTANCE: float = TILE_SIZE * 0.30

const MONSTER_ROAM_WAIT: float = 0.75
const MONSTER_ROAM_MIN_DISTANCE: int = 8
const MONSTER_ROAM_ATTEMPTS: int = 40

const MONSTER_ROAM_MOVE_TIME: float = 0.26
const MONSTER_INVESTIGATE_MOVE_TIME: float = 0.18
const MONSTER_SEARCH_MOVE_TIME: float = 0.20

const MONSTER_SEARCH_DURATION: float = 4.5 
const MONSTER_SEARCH_RADIUS: int = 3
const MONSTER_SEARCH_WAIT: float = 0.25
const MONSTER_SNAPSHOT_FADE_DURATION: float = 1.5

const MONSTER_COLOR: Color = Color(0.85, 0.12, 0.15, 1.0)
const MONSTER_DOT_COUNT: int = 11
const MONSTER_DOT_COUNT_VARIANCE: int = 3
const MONSTER_CLUSTER_RADIUS: float = TILE_SIZE * 0.38


const CARD_COLOR: Color = Color(1.0, 0.82, 0.18, 1.0)
const CARD_DIM_ALPHA: float = 0.30
const CARD_FLASH_DURATION: float = 1.0

const EXIT_LOCKED_COLOR: Color = Color(0.25, 0.55, 1.0, 1.0)
const EXIT_OPEN_COLOR: Color = Color(0.2, 1.0, 0.45, 1.0)
const EXIT_DIM_ALPHA: float = 0.30
const EXIT_FLASH_DURATION: float = 1.0

const DEBUG_SHOW_MONSTER: bool = true

const MAP_ROWS: Array[String] = [
	"################################",
	"#......#..........#............#",
	"#......#..........#............#",
	"#..E...........................#",
	"#......#..........#............#",
	"#.##.####....##...####.###.#####",
	"#......#.....##...#............#",
	"#......#.....##...#............#",
	"#......#.....##...#............#",
	"#......#..........#.....X......#",
	"##...###...##.....####.#####.###",
	"#......#...##.....#............#",
	"#......#...##.....#............#",
	"#......#...##.....#............#",
	"#......#..........#............#",
	"####.####.....########...#######",
	"#......#......#....#...........#",
	"#......#......#....#...........#",
	"#......#......#................#",
	"#......#......#....#.....K.....#",
	"#..............................#",
	"#..............................#",
	"#......................M.......#",
	"################################"
]

class SonarPulse:
	var origin: Vector2
	var origin_cell: Vector2i
	var radius: float = 0.0
	var previous_radius: float = 0.0
	
	func _init(start_origin: Vector2, start_cell: Vector2i) -> void:
		origin = start_origin
		origin_cell = start_cell

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
var wall_last_lit: Dictionary = {}

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

var monster_stalk_target: Vector2i = Vector2i.ZERO
var monster_stalk_distance: int = MONSTER_STALK_DISTANCE_START
var monster_stalk_creep_remaining: float = 0.0

var monster_hunt_target: Vector2i = Vector2i.ZERO
var monster_hunt_lose_remaining: float = 0.0

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
	if not _parse_map():
		set_process(false)
		return
	
	map_is_valid = true
	monster_rng.randomize()
	 
	player_draw_position = _cell_center(player_cell)
	player_draw_angle = Vector2(player_facing).angle()
	monster_draw_position = _cell_center(monster_cell)
	card_draw_position = _cell_center(card_cell)
	exit_draw_position = _cell_center(exit_cell)
	
	_build_monster_shape()
	_build_astar()
	
	monster_path.clear()
	monster_roam_wait_remaining = 0.5
	
	if monster_path.is_empty():
		push_warning("No monster route was found at beginning?")
	print("Offsets: ", monster_dot_offsets.size(), " | Sizes: ", monster_dot_sizes.size())
	print("Debug path: ", monster_path)
	queue_redraw()

func _check_player_caught() -> void:
	if game_over:
		return
	
	var distance: float = player_draw_position.distance_to(monster_draw_position)
	if distance > MONSTER_CATCH_DISTANCE:
		return
	
	game_over = true
	active_pulses.clear()
	monster_path.clear()

func _draw_game_over() -> void:
	var screen_size: Vector2 = Vector2(
		map_width * TILE_SIZE,
		map_height * TILE_SIZE
	)
	
	draw_rect(
		Rect2(Vector2.ZERO, screen_size),
		Color(0.2, 0.0, 0.0, 0.72),
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
		Color(1.0, 0.25, 0.25, 1.0)
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
	if MAP_ROWS.is_empty():
		push_error("MAP_ROWS cant be empty!")
		return false
	
	wall_cells.clear()
	walkable_cells.clear()
	map_height = MAP_ROWS.size()
	map_width = MAP_ROWS[0].length()
	
	var start_count: int = 0
	var monster_count: int = 0 
	var card_count: int = 0
	var exit_count: int = 0
	
	for y in range(map_height):
		var row: String = MAP_ROWS[y]
		
		if row.length() != map_width:
			push_error("MAP_ROWS row %d has %d characters; expected %d!" % [y, row.length(), map_width])
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
	
	monster_state = MonsterState.STALKING
	monster_stalk_target = target_cell
	monster_path.clear()
	monster_needs_new_path = true

func _set_monster_stalk_path() -> void:
	_set_monster_path(monster_stalk_target)
	var kept_steps: int = maxi(monster_path.size() - monster_stalk_distance, 0) ## This should in theory cut off the steps before it actually reaches the player, to actually... stalk
	monster_path.resize(kept_steps)

func _update_monster_stalking(delta: float) -> void:
	if monster_awareness < AWARENESS_STALK_EXIT:
		_begin_monster_search(monster_cell) ## If it loses interest it looks around where it is then wanders away
		return
	
	if is_monster_moving:
		return
	
	if monster_needs_new_path:
		_set_monster_stalk_path()
		monster_needs_new_path = false
		return
	
	if not monster_path.is_empty():
		return
	
	monster_stalk_creep_remaining -= delta
	if monster_stalk_creep_remaining <= 0.0:
		monster_stalk_creep_remaining = MONSTER_STALK_CREEP_SECONDS
		
		if monster_stalk_distance > MONSTER_STALK_DISTANCE_MIN:
			monster_stalk_distance -= 1
			monster_needs_new_path = true
		else:
			_begin_monster_hunting(monster_stalk_target)

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

func _pick_monster_search_target() -> Vector2i:
	var candidates: Array[Vector2i] = []
	
	for cell in walkable_cells:
		var distance: int = (
			absi(cell.x - monster_search_center.x) + absi(cell.y - monster_search_center.y)
		)
		
		if (
			distance > 0 
			and distance <= MONSTER_SEARCH_RADIUS
			and cell != monster_cell
		):
			candidates.append(cell)
	if candidates.is_empty():
		return monster_search_center
	
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
	
	var target_cell: Vector2i = _pick_monster_search_target()
	
	if target_cell != monster_cell:
		_set_monster_path(target_cell)
	
	monster_search_wait_remaining = MONSTER_SEARCH_WAIT

func _process(delta: float) -> void:
	if not map_is_valid:
		return
	
	if game_over or has_won:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		
		queue_redraw()
		return
	
	game_time += delta
	
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
	_update_monster_ai(delta)
	_check_card_collection()
	_check_player_caught()
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
	
	var tile: String = MAP_ROWS[cell.y].substr(cell.x, 1)
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
	
	return MAP_ROWS[cell.y].substr(cell.x, 1) == "#"

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

func _try_emit_ping() -> void:
	if game_time - last_ping_time < PING_COOLDOWN:
		return
	
	var origin: Vector2 = player_draw_position
	var origin_cell: Vector2i = _cell_from_position(origin)
	
	active_pulses.append(SonarPulse.new(origin, origin_cell))
	
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
		_reveal_walls_for_pulse(pulse)
		_reveal_monster_for_pulse(pulse)
		_reveal_card_for_pulse(pulse)
		_reveal_exit_for_pulse(pulse)
	
	for i in range(active_pulses.size() - 1, -1, -1):
		if active_pulses[i].radius >= PING_MAX_RADIUS:
			active_pulses.remove_at(i)

func _update_monster_ai(delta: float) -> void:
	var decay_rate: float = AWARENESS_DECAY_PER_SECOND
	if monster_state == MonsterState.STALKING:
		decay_rate = AWARENESS_STALK_DECAY_PER_SECOND
	elif monster_state == MonsterState.HUNTING:
		decay_rate = 0.0
	monster_awareness = maxf(monster_awareness - AWARENESS_DECAY_PER_SECOND * delta, 0.0)
	
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
	monster_awareness = minf(monster_awareness + last_noise_loudness, 1.0)
	
	var noise_distance: float = monster_draw_position.distance_to(_cell_center(last_noise_cell))
	var noise_is_close: bool = noise_distance <= MONSTER_HUNT_PROXIMITY_TILES * TILE_SIZE
	var stalking_and_close: bool = monster_state == MonsterState.STALKING and noise_is_close
	
	if monster_awareness >= AWARENESS_HUNT_THRESHOLD or stalking_and_close:
		_begin_monster_hunting(last_noise_cell)
	elif monster_awareness >= AWARENESS_STALK_THRESHOLD:
		_begin_monster_stalking(last_noise_cell)
	else:
		_begin_monster_investigation(last_noise_cell)

func _reveal_walls_for_pulse(pulse: SonarPulse) -> void:
	for cell in wall_cells:
		var distance: float = pulse.origin.distance_to(_cell_center(cell))
		
		if distance > pulse.previous_radius and distance <= pulse.radius:
			if _has_line_of_sight(pulse.origin_cell, cell):
				wall_last_lit[cell] = game_time

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
	var distance: float = pulse.origin.distance_to(monster_draw_position)
	var ring_reached_monster: bool = (
		distance > pulse.previous_radius
		and distance <= pulse.radius
	)
	if not ring_reached_monster:
		return
	
	var current_monster_cell: Vector2i = _cell_from_position(monster_draw_position)
	
	if not _has_line_of_sight(
		pulse.origin_cell,
		current_monster_cell
	):
		return
	
	_build_monster_shape()
	monster_snapshot_position = monster_draw_position
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
	_draw_revealed_walls()
	_draw_pulses()
	_draw_access_card()
	_draw_exit_marker()
	_draw_monster_snapshot()
	
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

func _draw_revealed_walls() -> void:
	for cell in wall_cells:
		if not wall_last_lit.has(cell):
			continue
		
		var seconds_since_lit: float = game_time - wall_last_lit[cell]
		
		var flash: float = clampf(
			1.0 - seconds_since_lit / WALL_FLASH_DURATION,
			0.0,
			1.0
		)
		flash = flash * flash
		
		var alpha: float = lerpf(WALL_DIM_SEEN_ALPHA, 1.0, flash)
		var color: Color = Color(WALL_COLOR, alpha)
		
		var wall_rect: Rect2 = Rect2(
			Vector2(
				float(cell.x * TILE_SIZE) + 2.0,
				float(cell.y * TILE_SIZE) + 2.0
			),
			
			Vector2(
				float(TILE_SIZE) - 4.0,
				float(TILE_SIZE) - 4.0
			)
		)
		draw_rect(wall_rect, color, false, 1.5)

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
		
		draw_arc(
			pulse.origin,
			pulse.radius,
			0.0,
			TAU,
			64,
			Color(PING_RING_COLOR, alpha),
			PING_RING_WIDTH,
			true
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
