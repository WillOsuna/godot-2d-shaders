extends Control
## Shader gallery: browse every demo scene, read what each shader does and
## tweak its uniforms live.
## Keys: Left / Right = previous / next, L = list, T = tweak panel,
## H = hide the interface.

const LIST_PATH: String = "res://willosuna_shaders/gallery/shader_list.json"
const ACCENT: Color = Color(0.45, 0.85, 1.0)
const BG: Color = Color(0.06, 0.05, 0.1)
const PANEL: Color = Color(0.1, 0.09, 0.16, 0.94)
const TEXT: Color = Color(0.92, 0.9, 0.97)
const DIM: Color = Color(0.66, 0.63, 0.78)

var entries: Array = []
var pack_name: String = ""
var index: int = 0
var has_tweak: bool = true

var tour: bool = false
var dwell: float = 2.0
var stills_dir: String = ""
var still_at: float = 1.2
var only: PackedStringArray = PackedStringArray()
var tweak_in_tour: bool = false

var _clock: float = 0.0
var _shot_done: bool = false
var _demo: Node = null
var _port: SubViewport = null
var _title: Label = null
var _cat: Label = null
var _count: Label = null
var _about: Label = null
var _use: Label = null
var _list: ItemList = null
var _tweak: PanelContainer = null
var _tweak_box: VBoxContainer = null
var _ui: Array[Control] = []


func _ready() -> void:
	var f: FileAccess = FileAccess.open(LIST_PATH, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())
	entries = data["shaders"]
	pack_name = data["pack"]
	has_tweak = data["tweak_panel"]
	_parse_args()
	_build_ui()
	if tour and tweak_in_tour and has_tweak:
		_tweak.visible = true
	_show(index)


func _parse_args() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a == "--tour":
			tour = true
		elif a == "--tweak":
			tweak_in_tour = true
		elif a.begins_with("--dwell="):
			dwell = a.trim_prefix("--dwell=").to_float()
		elif a.begins_with("--still-at="):
			still_at = a.trim_prefix("--still-at=").to_float()
		elif a.begins_with("--stills="):
			stills_dir = a.trim_prefix("--stills=")
		elif a.begins_with("--only="):
			only = a.trim_prefix("--only=").split(",")
	if only.size() > 0:
		var kept: Array = []
		for e: Dictionary in entries:
			if only.has(String(e["name"])):
				kept.append(e)
		entries = kept


func _label(size: int, color: Color) -> Label:
	var l: Label = Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _box(color: Color) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = color
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 6.0
	s.content_margin_bottom = 6.0
	return s


func _button(text: String, x: float, w: float, cb: Callable) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.position = Vector2(x, 12)
	b.size = Vector2(w, 36)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_stylebox_override("normal", _box(Color(0.17, 0.15, 0.26)))
	b.add_theme_stylebox_override("hover", _box(Color(0.25, 0.22, 0.38)))
	b.add_theme_stylebox_override("pressed", _box(Color(0.3, 0.27, 0.45)))
	b.pressed.connect(cb)
	return b


func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = BG
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var view: SubViewportContainer = SubViewportContainer.new()
	view.position = Vector2(0, 60)
	view.size = Vector2(1280, 570)
	view.stretch = true
	add_child(view)
	_port = SubViewport.new()
	_port.size = Vector2i(1280, 570)
	_port.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.add_child(_port)

	var top: Panel = Panel.new()
	top.size = Vector2(1280, 60)
	top.add_theme_stylebox_override("panel", _box(PANEL))
	add_child(top)
	_title = _label(26, TEXT)
	_title.position = Vector2(16, 12)
	top.add_child(_title)
	_cat = _label(16, ACCENT)
	_cat.position = Vector2(560, 20)
	top.add_child(_cat)
	_count = _label(16, DIM)
	_count.position = Vector2(820, 20)
	top.add_child(_count)
	top.add_child(_button("<", 930, 44, _prev))
	top.add_child(_button(">", 980, 44, _next))
	top.add_child(_button("List", 1032, 70, _toggle_list))
	if has_tweak:
		top.add_child(_button("Tweak", 1108, 80, _toggle_tweak))
	top.add_child(_button("Hide", 1194, 74, _toggle_ui))

	var bottom: Panel = Panel.new()
	bottom.position = Vector2(0, 630)
	bottom.size = Vector2(1280, 90)
	bottom.add_theme_stylebox_override("panel", _box(PANEL))
	add_child(bottom)
	_about = _label(17, TEXT)
	_about.position = Vector2(16, 8)
	_about.size = Vector2(1248, 50)
	_about.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom.add_child(_about)
	_use = _label(14, DIM)
	_use.position = Vector2(16, 62)
	bottom.add_child(_use)

	_list = ItemList.new()
	_list.position = Vector2(0, 60)
	_list.size = Vector2(330, 570)
	_list.add_theme_font_size_override("font_size", 15)
	_list.add_theme_stylebox_override("panel", _box(PANEL))
	_list.visible = false
	for i: int in entries.size():
		var e: Dictionary = entries[i]
		_list.add_item("%02d  %s" % [i + 1, String(e["title"])])
	_list.item_selected.connect(_on_pick)
	add_child(_list)

	_tweak = PanelContainer.new()
	_tweak.position = Vector2(920, 60)
	_tweak.size = Vector2(360, 570)
	_tweak.add_theme_stylebox_override("panel", _box(PANEL))
	_tweak.visible = false
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(340, 556)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tweak.add_child(scroll)
	_tweak_box = VBoxContainer.new()
	_tweak_box.custom_minimum_size = Vector2(320, 0)
	scroll.add_child(_tweak_box)
	add_child(_tweak)
	_ui = [top, bottom]


func _show(i: int) -> void:
	if entries.is_empty():
		return
	index = wrapi(i, 0, entries.size())
	var e: Dictionary = entries[index]
	if _demo != null:
		_demo.queue_free()
		_demo = null
	var scene: PackedScene = load(String(e["scene"])) as PackedScene
	_demo = scene.instantiate()
	_port.add_child(_demo)
	_title.text = String(e["title"])
	var fs: int = 26
	var font: Font = _title.get_theme_font("font")
	while fs > 16 and font.get_string_size(_title.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 530.0:
		fs -= 1
	_title.add_theme_font_size_override("font_size", fs)
	_cat.text = String(e["category"]).to_upper()
	_count.text = "%d / %d" % [index + 1, entries.size()]
	_about.text = String(e["about"])
	_use.text = "%s   |   use on: %s   |   Left / Right browse, L list, T tweak, H hide" % [String(e["shader"]), String(e["use"])]
	_clock = 0.0
	_shot_done = false
	if _list.item_count > index:
		_list.select(index)
	if _tweak.visible:
		_build_tweak.call_deferred()


func _prev() -> void:
	_show(index - 1)


func _next() -> void:
	_show(index + 1)


func _on_pick(i: int) -> void:
	_show(i)


func _toggle_list() -> void:
	_list.visible = not _list.visible


func _toggle_tweak() -> void:
	_tweak.visible = not _tweak.visible
	if _tweak.visible:
		_build_tweak()


func _toggle_ui() -> void:
	var v: bool = not _ui[0].visible
	for c: Control in _ui:
		c.visible = v
	if not v:
		_list.visible = false
		_tweak.visible = false


func _target() -> CanvasItem:
	if _demo == null:
		return null
	for n: Node in _demo.find_children("*", "", true, false):
		if n.is_in_group(&"shd_target"):
			return n as CanvasItem
	return null


func _default_of(mat: ShaderMaterial, uname: StringName) -> Variant:
	var v: Variant = mat.get_shader_parameter(uname)
	if v == null:
		v = RenderingServer.shader_get_parameter_default(mat.shader.get_rid(), uname)
	return v


func _stop_animators(target: CanvasItem, uname: String) -> void:
	for n: Node in get_tree().get_nodes_in_group(&"shd_anim"):
		if n.get_parent() == target and String(n.get("param")) == uname:
			n.set("enabled", false)


func _build_tweak() -> void:
	for c: Node in _tweak_box.get_children():
		c.queue_free()
	var t: CanvasItem = _target()
	if t == null or not (t.material is ShaderMaterial):
		return
	var mat: ShaderMaterial = t.material as ShaderMaterial
	var head: Label = _label(18, ACCENT)
	head.text = "UNIFORMS (live)"
	_tweak_box.add_child(head)
	for u: Dictionary in mat.shader.get_shader_uniform_list():
		var uname: String = String(u["name"])
		var utype: int = int(u["type"])
		var hint: int = int(u["hint"])
		var hs: String = String(u["hint_string"])
		var cur: Variant = _default_of(mat, StringName(uname))
		var name_l: Label = _label(15, TEXT)
		name_l.text = uname
		_tweak_box.add_child(name_l)
		if (utype == TYPE_FLOAT or utype == TYPE_INT) and hint == PROPERTY_HINT_RANGE:
			var parts: PackedStringArray = hs.split(",")
			var s: HSlider = HSlider.new()
			s.min_value = parts[0].to_float()
			s.max_value = parts[1].to_float()
			s.step = parts[2].to_float() if parts.size() > 2 else (1.0 if utype == TYPE_INT else 0.01)
			s.custom_minimum_size = Vector2(300, 22)
			s.value = float(cur) if cur != null else s.min_value
			var vl: Label = _label(13, DIM)
			vl.text = str(snappedf(s.value, 0.001))
			_tweak_box.add_child(s)
			_tweak_box.add_child(vl)
			s.value_changed.connect(func(v: float) -> void:
				_stop_animators(t, uname)
				vl.text = str(snappedf(v, 0.001))
				if utype == TYPE_INT:
					mat.set_shader_parameter(uname, int(v))
				else:
					mat.set_shader_parameter(uname, v))
		elif utype == TYPE_BOOL:
			var cb: CheckBox = CheckBox.new()
			cb.button_pressed = bool(cur) if cur != null else false
			cb.text = "on"
			_tweak_box.add_child(cb)
			cb.toggled.connect(func(on: bool) -> void:
				_stop_animators(t, uname)
				mat.set_shader_parameter(uname, on))
		elif utype == TYPE_COLOR:
			var cp: ColorPickerButton = ColorPickerButton.new()
			cp.custom_minimum_size = Vector2(300, 26)
			cp.color = cur if cur is Color else Color.WHITE
			_tweak_box.add_child(cp)
			cp.color_changed.connect(func(c: Color) -> void:
				_stop_animators(t, uname)
				mat.set_shader_parameter(uname, c))
		else:
			var info: Label = _label(13, DIM)
			info.text = "(texture)" if utype == TYPE_OBJECT else str(cur)
			_tweak_box.add_child(info)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var k: Key = (event as InputEventKey).keycode
		if k == KEY_RIGHT:
			_next()
		elif k == KEY_LEFT:
			_prev()
		elif k == KEY_L:
			_toggle_list()
		elif k == KEY_T and has_tweak:
			_toggle_tweak()
		elif k == KEY_H:
			_toggle_ui()


func _process(delta: float) -> void:
	if not tour:
		return
	_clock += delta
	var at: float = float(entries[index].get("still", still_at))
	if stills_dir != "" and not _shot_done and _clock >= at:
		_shot_done = true
		var n: String = String(entries[index]["name"])
		get_viewport().get_texture().get_image().save_png(stills_dir.path_join(n + ".png"))
		_port.get_texture().get_image().save_png(stills_dir.path_join(n + "_demo.png"))
	if _clock >= dwell:
		if index + 1 >= entries.size():
			get_tree().quit()
		else:
			_show(index + 1)
