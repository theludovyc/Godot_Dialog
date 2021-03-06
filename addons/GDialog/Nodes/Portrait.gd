extends Control

const positions = {
	'left': Vector2(-400, 0),
	'center_left': Vector2(-200, 0),
	'center': Vector2(0, 0),
	'center_right': Vector2(200, 0),
	'right': Vector2(+400, 0)
	}

var character_data = {
	'name': 'Default',
	'image': "res://addons/GDialog/Example Assets/portraits/df-3.png",
	'color': Color(0.973511, 1, 0.152344),
	'file': '',
	'mirror_portraits': false
}

var position:Vector2

var single_portrait_mode = false
var direction = 'left'
var debug = false
var fading_out = false

func _ready():
	if debug:
		print('Character data loaded: ', character_data)
		print(rect_position, $TextureRect.rect_size)
	
func set_offset(offset_x:float, offset_y:float):
	position = Vector2(offset_x, offset_y)

func set_portrait(path:String) -> void:
	if ResourceLoader.exists(path):
		$TextureRect.texture = load(path)
	else:
		$TextureRect.texture = ImageTexture.new()

func set_mirror(value):
	if character_data.has('mirror_portraits'):
		if character_data['mirror_portraits']:
			$TextureRect.flip_h = !value
		else:
			$TextureRect.flip_h = value
	else:
		$TextureRect.flip_h = value

func move_to_position(position_offset, time = 0.5):
	direction = positions.keys()[position_offset]

	rect_position = positions[direction]

	rect_position += position
	
	if $TextureRect.get('texture'):
		rect_position -= Vector2(
			$TextureRect.texture.get_width() / 2,
			$TextureRect.texture.get_height()
		) * rect_scale
	
	fade_in()

# Tween stuff
func fade_in(time = 0.5):
	modulate = Color(1,1,1, 0)
	
	tween_modulate(modulate, Color(1,1,1, 1), time)
	
	if single_portrait_mode == false:
		var end_pos = Vector2(0, -40) # starting at center
		
		if direction == 'right':
			rect_position.x += 40
			
			end_pos = Vector2(-40, 0)
		elif direction == 'left':
			rect_position.x -= 40
			
			end_pos = Vector2(+40, 0)
		else:
			rect_position += Vector2(0, 40)

		$TweenPosition.interpolate_property(
			self, "rect_position", rect_position, rect_position + end_pos, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$TweenPosition.start()

func fade_out(time = 0.5):
	tween_modulate(modulate, Color(1,1,1, 0), time)

func focus():
	if not fading_out:
		tween_modulate(modulate, Color(1,1,1, 1))
		var _parent = get_parent()
		if _parent:
			# Make sure that this portrait is the last to be _draw -ed
			_parent.move_child(self, _parent.get_child_count())

func focusout():
	var alpha = 1
	if single_portrait_mode:
		alpha = 0
	if not fading_out:
		tween_modulate(modulate, Color(0.5,0.5,0.5, alpha))
		var _parent = get_parent()
		if _parent:
			# Render this portrait first
			_parent.move_child(self, 0)

func tween_modulate(from_value, to_value, time = 0.5):
	$Tween.interpolate_property(
		self, "modulate", from_value, to_value, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()
	return $Tween

func is_scene(path) -> bool:
	if '.tscn' in path.to_lower():
		return true
	return false
