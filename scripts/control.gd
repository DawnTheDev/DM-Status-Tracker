extends Control

var selected: bool
var current

var TrackerPool = [
	Singleton.Tracker1,
	Singleton.Tracker2,
	Singleton.Tracker3,
	Singleton.Tracker4,
	Singleton.Tracker5,
	Singleton.Tracker6,
	Singleton.Tracker7,
	Singleton.Tracker8,
	Singleton.Tracker9,
	Singleton.Tracker10,
	Singleton.Tracker11,
	Singleton.Tracker12,
	Singleton.Tracker13,
	Singleton.Tracker14,
	Singleton.Tracker15
]

@onready var CellPools = [
	$ScrollContainer/HBoxContainer/TrackerCell1/cell,
	$ScrollContainer/HBoxContainer/TrackerCell2/cell
]

var CurTracker

@onready var nameWindow = $TrackerEditWindow
@onready var BloodEditWindow = $BloodEditWindow
@onready var RateEditWindow = $RateEditWindow
@onready var EffectsEditWindow = $EffectsEditWindow
@onready var SourceList = $RateEditWindow/SourceList

@onready var effectcs = $EffectsEditWindow/CustomBlock/Source
@onready var effectduration = $EffectsEditWindow/CustomBlock/LineEdit

var windowopened: bool
var TempDict = {}
var TempEffectDict = {}

func _ready() -> void:
	var cells = $ScrollContainer/HBoxContainer.get_children()
	for cell in cells:
		var btn: Button = cell.get_node("Cell")
		
		btn.pressed.connect(_on_cell_pressed.bind(btn))

func _physics_process(_delta: float) -> void:
	if current == null: return
	CurTracker = TrackerPool[current - 1]
	#print(current)

func _on_cell_pressed(btn: Button):
	var id = btn.get_meta("id")
	var panel = getCell(btn)
	
	
	if not selected: #HAVE NOT SELECTED ANYTHING
		var themeoverride = StyleBoxFlat.new()
		themeoverride.bg_color = Color(0.082, 0.475, 0.082, 0.624)
		themeoverride.set_corner_radius_all(15)
		panel.remove_theme_stylebox_override("panel")
		panel.add_theme_stylebox_override("panel", themeoverride)
		
		current = id
		selected = not selected
	
	elif selected and current == id: #DESELECTING CUURENT PANEL
		var themeoverride = StyleBoxFlat.new()
		themeoverride.bg_color = Color(0.082, 0.082, 0.082, 0.624)
		themeoverride.set_corner_radius_all(15)
		panel.remove_theme_stylebox_override("panel")
		panel.add_theme_stylebox_override("panel", themeoverride)
		
		current = null
		CurTracker = null
		selected = not selected
	
	else: #ALREADY SELECTED AND SELECT NEW ONE
		var previousPanel = CellPools[current - 1]
			
		var themeoverride = StyleBoxFlat.new()
		themeoverride.bg_color = Color(0.082, 0.082, 0.082, 0.624)
		themeoverride.set_corner_radius_all(15)
		previousPanel.remove_theme_stylebox_override("panel")
		previousPanel.add_theme_stylebox_override("panel", themeoverride)
		
		var newthemeoverride = StyleBoxFlat.new()
		newthemeoverride.bg_color = Color(0.082, 0.475, 0.082, 0.624)
		newthemeoverride.set_corner_radius_all(15)
		panel.remove_theme_stylebox_override("panel")
		panel.add_theme_stylebox_override("panel", newthemeoverride)
		
		current = id
		


func _on_edit_name_pressed() -> void:
	if current == null: return
	if windowopened: return
	
	nameWindow.get_node("Name").text = ""
	windowopened = true
	nameWindow.visible = true
	$TrackerEditWindow/Warning.visible = false


func getCell(btn: Button):
	var id = btn.get_meta("id")
	
	return CellPools[id - 1]

func CleanText(text: String):
	var cleanedtext = text.replace(" ", "")
	
	if cleanedtext == "":
		return false
	else:
		return true

func _on_t_confirm_pressed() -> void:
	var customName = nameWindow.get_node("Name").text
	if CleanText(customName):
		CellPools[current - 1].get_node("Name").text = customName
		
		nameWindow.get_node("Name").text = ""
		windowopened = false
		nameWindow.visible = false
		$TrackerEditWindow/Warning.visible = false
	else:
		$TrackerEditWindow/Warning.visible = true


func _on_t_cancel_pressed() -> void:
	nameWindow.get_node("Name").text = ""
	windowopened = false
	nameWindow.visible = false
	$TrackerEditWindow/Warning.visible = false


func _on_edit_blood_pressed() -> void:
	if windowopened: return
	
	windowopened = true
	BloodEditWindow.get_node("maxbloodamount").text = ""
	BloodEditWindow.visible = true
	$BloodEditWindow/Warning.visible = false


func _on_b_confirm_pressed() -> void:
	if current == null: return
	
	if CleanText(BloodEditWindow.get_node("maxbloodamount").text):
		
		if not BloodEditWindow.get_node("maxbloodamount").text.is_valid_int():
			$BloodEditWindow/Warning.visible = true
			$BloodEditWindow/Warning.text = "Max blood must an int value."
			return
		
		var maxblood = CellPools[current - 1].get_node("BloodPanel").get_node("maxblood")
		maxblood.text = BloodEditWindow.get_node("maxbloodamount").text
		#maxblood.label_settings.font_color = Color.GREEN
		
		CurTracker["maxblood"] = int(BloodEditWindow.get_node("maxbloodamount").text)
		CurTracker["blood"] = CurTracker["maxblood"]
		
		$BloodEditWindow/Warning.visible = false
		windowopened = false
		BloodEditWindow.get_node("maxbloodamount").text = ""
		BloodEditWindow.visible = false
	
	else:
		$BloodEditWindow/Warning.visible = true
		$BloodEditWindow/Warning.text = "Max blood must not be empty."


func _on_b_cancel_pressed() -> void:
	$BloodEditWindow/Warning.visible = false
	windowopened = false
	BloodEditWindow.get_node("maxbloodamount").text = ""
	BloodEditWindow.visible = false

func controlRateWindow(state):
	
	if not state:
		windowopened = false
		RateEditWindow.visible = false
		$RateEditWindow/CustomBlock/Source.text = ""
		$RateEditWindow/CustomBlock/rate.value = 0
		$RateEditWindow/CustomBlock/Duration.text = ""
		$RateEditWindow/CustomBlock/prefix.text = "Negative"
		$RateEditWindow/Warning.visible = false
		print(1)
	
	else:
		windowopened = true
		RateEditWindow.visible = true
		$RateEditWindow/CustomBlock/Source.text = ""
		$RateEditWindow/CustomBlock/rate.value = 0
		$RateEditWindow/CustomBlock/Duration.text = ""
		$RateEditWindow/CustomBlock/prefix.text = "Negative"
		$RateEditWindow/Warning.visible = false
		SourceList.clear()

func UpdateSourcesList():
	for i in CurTracker["Sources"]:
		#print(i + ": " + str(CurTracker["Sources"][i][0]) + "(" + str(CurTracker["Sources"][i][1]) + ")")
		SourceList.add_item(i + ": " + str(CurTracker["Sources"][i][0]) + "(" + str(CurTracker["Sources"][i][1]) + ")")

func _on_edit_rate_pressed() -> void:
	if windowopened: return
	if current == null: return
	
	controlRateWindow(true)
	UpdateSourcesList()


func _on_prefix_pressed() -> void:
	if $RateEditWindow/CustomBlock/prefix.text == "Negative":
		$RateEditWindow/CustomBlock/prefix.text = "Positive"
	else:
		$RateEditWindow/CustomBlock/prefix.text = "Negative"

func _on_add_pressed() -> void:
	var cs = $RateEditWindow/CustomBlock/Source
	var rate = $RateEditWindow/CustomBlock/rate
	var duration = $RateEditWindow/CustomBlock/Duration
	var warning = $RateEditWindow/Warning
	var prefix = $RateEditWindow/CustomBlock/prefix
	
	if not CleanText(cs.text):
		warning.text = "Source must be specified."
		warning.visible = true
		return
	
	if rate.value == 0:
		warning.text = "Rate must not be 0."
		warning.visible = true
		return
	
	if not CleanText(duration.text) or not duration.text.is_valid_int():
		warning.text = "Duration must be a valid int."
		warning.visible = true
		return
	
	warning.visible = false
	
	var newrate
	if prefix.text == "Negative":
		newrate = rate.value * -1
	else:
		newrate = rate.value
	
	TempDict[cs.text + ": " + str(newrate) + "(" + duration.text + ")"] = cs.text
	CurTracker["Sources"][cs.text] = [newrate, int(duration.text)]
	
	UpdateSourcesList()
	
	cs.text = ""
	rate.value = 0
	duration.text = ""

func calculateRate():
	var base = 2
	
	for i in CurTracker["Sources"]:
		base += CurTracker["Sources"][i][0]
	
	var rate = CellPools[current - 1].get_node("BloodPanel").get_node("rate")
	
	if base <= 0:
		rate.text = str(base)
	else:
		rate.text = "+" + str(base)
	
	CurTracker["rate"] = base

func _on_r_delete_pressed() -> void:
	var chosenItem = SourceList.get_selected_items()
	if chosenItem.size() > 0:
		var indextoremove = chosenItem[0]
		var key = TempDict[SourceList.get_item_text(indextoremove)]
		
		#loglist.add_item("Deleted blood rate " + key + " from " + editing.text)
		
		CurTracker["Sources"].erase(key)
		TempDict.erase(SourceList.get_item_text(indextoremove))
		
		SourceList.remove_item(indextoremove)
		
	else:
		print("Nothing selected")


func _on_r_confirm_pressed() -> void:
	controlRateWindow(false)
	calculateRate()


func _on_edit_effects_pressed() -> void:
	if windowopened: return
	if current == null: return
	windowopened = true
	EffectsEditWindow.visible = true
	
	effectcs.text = ""
	effectduration.text = ""
	UpdateEffectsList()

func UpdateEffectsList():
	$EffectsEditWindow/SourceList.clear()
	for i in CurTracker["effects"]:
		$EffectsEditWindow/SourceList.add_item(i + ": " + str(CurTracker["effects"][i]))

func _on_eadd_pressed() -> void:
	
	if not CleanText(effectcs.text):
		$EffectsEditWindow/Warning.text = "Source must be specified."
		$EffectsEditWindow/Warning.visible = true
		return
	
	if not CleanText(effectduration.text) or not effectduration.text.is_valid_int():
		$EffectsEditWindow/Warning.text = "Duration must a a valid int."
		$EffectsEditWindow/Warning.visible = true
		return
	
	$EffectsEditWindow/Warning.visible = false
	
	TempEffectDict[effectcs.text + ": " + effectduration.text] = effectcs.text
	CurTracker["effects"][effectcs.text] = int(effectduration.text)
	UpdateEffectsList()
	
	effectcs.text = ""
	effectduration.text = ""


func _on_e_confirm_pressed() -> void:
	var Effects = CellPools[current - 1].get_node("StatusNotes").get_node("Label")
	
	var curStr: String
	for i in CurTracker["effects"]:
		curStr += i + "(" + str(CurTracker["effects"][i]) + ") "
	
	Effects.text = curStr
	
	windowopened = false
	EffectsEditWindow.visible = false
	
	effectcs.text = ""
	effectduration.text = ""


func _on_e_delete_pressed() -> void:
	var chosenItem = $EffectsEditWindow/SourceList.get_selected_items()
	if chosenItem.size() > 0:
		var indextoremove = chosenItem[0]
		var key = TempEffectDict[$EffectsEditWindow/SourceList.get_item_text(indextoremove)]
		
		#loglist.add_item("Deleted blood rate " + key + " from " + editing.text)
		
		CurTracker["effects"].erase(key)
		TempEffectDict.erase($EffectsEditWindow/SourceList.get_item_text(indextoremove))
		
		$EffectsEditWindow/SourceList.remove_item(indextoremove)
		
	else:
		print("Nothing selected")


func _on_reset_blood_pressed() -> void:
	if current == null: return
	
	CurTracker["blood"] = CurTracker["maxblood"]
	
	var blood = CellPools[current - 1].get_node("BloodPanel").get_node("blood")
	blood.text = str(CurTracker["blood"]) + "(100%)"
	blood.label_settings.font_color = Color.GREEN


func _on_apply_rate_pressed() -> void:
	if current == null: return
	
	var previousblood = CurTracker["blood"]
	
	CurTracker["blood"] += CurTracker["rate"]
	
	if CurTracker["blood"] > CurTracker["maxblood"]:
		CurTracker["blood"] = CurTracker["maxblood"]
	
	if CurTracker["blood"] < 0.0:
		CurTracker["blood"] = 0.0
	
	var blood = CellPools[current - 1].get_node("BloodPanel").get_node("blood")
	
	var factor = pow(10.0, 2)
	var percentage = ceil((CurTracker["blood"] / CurTracker["maxblood"] * 100) * factor) / factor
	
	blood.text = str(CurTracker["blood"]) + "(" + str(percentage) + "%)"
	
	var startColor = Color.GREEN
	var EndColor = Color.RED
	
	var normVal = (CurTracker["blood"] - 0.0) / (CurTracker["maxblood"] - 0.0)
	var interpolatedColor = EndColor.lerp(startColor, normVal)
	
	blood.label_settings.font_color = interpolatedColor

func UpdateAmmoDisplay():
	
	var AmmoPanel = CellPools[current - 1].get_node("AmmunitionPanel")
	var CurAmmo = AmmoPanel.get_node("CurAmmo")
	var Reserves = AmmoPanel.get_node("Reserves")
	var Ms = AmmoPanel.get_node("MagSize")
	
	CurAmmo.text = str(CurTracker["ammo"])
	Reserves.text = str(CurTracker["reverve"])
	Ms.text = str(CurTracker["magazine"])
	

func _on_a_confirm_pressed() -> void:
	var AmmoDrain = $AmmunitionWindow/AmmoDrain
	var ReserveDrain = $AmmunitionWindow/ReserveDrain
	var MagSize = $AmmunitionWindow/MagSize
	var ReserveAmount = $AmmunitionWindow/ReserveAmount
	
	if AmmoDrain.value <= 0 or ReserveDrain.value <= 0 or MagSize.value <= 0 or ReserveAmount.value <= 0:
		$AmmunitionWindow/Warning.visible = true
		return
	
	$AmmunitionWindow/Warning.visible = false
	
	CurTracker["ammo"] = int(MagSize.value)
	CurTracker["reverve"] = int(ReserveAmount.value)
	CurTracker["magazine"] = int(MagSize.value)
	CurTracker["ammodrain"] = int(AmmoDrain.value)
	CurTracker["reservedrain"] = int(ReserveDrain.value)
	
	UpdateAmmoDisplay()
	$AmmunitionWindow.visible = false
	windowopened = false

func _on_a_cancel_pressed() -> void:
	pass # Replace with function body.


func _on_edit_ammo_pressed() -> void:
	if windowopened or current == null: return
	
	windowopened = true
	var AmmoDrain = $AmmunitionWindow/AmmoDrain
	var ReserveDrain = $AmmunitionWindow/ReserveDrain
	var MagSize = $AmmunitionWindow/MagSize
	var ReserveAmount = $AmmunitionWindow/ReserveAmount
	
	AmmoDrain.value = 3
	ReserveDrain.value = 1
	MagSize.value = 30
	ReserveAmount.value = 0
	
	$AmmunitionWindow.visible = true
