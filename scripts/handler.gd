extends Node

var editing
var curTracker

var tempDict = {}

@onready var editWindow = $bg/EditWindow
@onready var editmaxblood = $bg/EditWindow/MaxBlood
@onready var editName = $bg/EditWindow/Name

@onready var rateEditWindow = $bg/RateEditWindow
@onready var list = $bg/RateEditWindow/SourcesList

@onready var customrate = $bg/RateEditWindow/RateAddConfig/rate
@onready var customsource = $bg/RateEditWindow/RateAddConfig/Source

@onready var loglist = $bg/logs/bg/log

var windowopened: bool

var Tracker = Singleton.Tracker1
var Sources = Singleton.Tracker1["Sources"]

func _ready():
	for EditButton in $bg/EditButtons.get_children():
		EditButton.pressed.connect(edit.bind(EditButton))
	
	for RateEditBtn in $bg/RateEditButtons.get_children():
		RateEditBtn.pressed.connect(_on_rateedit_pressed.bind(RateEditBtn))
	
	for ApplyBtn in $bg/ApplyButtons.get_children():
		ApplyBtn.pressed.connect(OnApply.bind(ApplyBtn))
	
	for ResetBtn in $bg/ResetButtons.get_children():
		ResetBtn.pressed.connect(OnReset.bind(ResetBtn))

# EDIT WINDOW

func edit(btn: Button) -> void:
	if windowopened: return
	updateEditing(btn.get_meta("id"))
	UpdateSources(btn.get_meta("id"))
	
	$bg/EditWindow/Error.visible = false
	editWindow.visible = true
	windowopened = true

func editconfirm() -> void:
	
	var cleanedtext = editName.text.replace(" ", "")
	if cleanedtext == "":
		$bg/EditWindow/Error.visible = true
		return
	
	editWindow.visible = false
	var previousMaxblood = Tracker["maxblood"]
	editing.text = editName.text
	editing.get_node("Blood").text = str(editmaxblood.value) + "(100.0%)"
	editing.get_node("Blood").label_settings.font_color = Color.GREEN
	Tracker["blood"] = editmaxblood.value
	Tracker["maxblood"] = editmaxblood.value
	
	loglist.add_item("Edited " + editName.text + ", changed max blood to " + str(editmaxblood.value) + " from " + str(previousMaxblood))
	
	editmaxblood.value = 0
	editName.text = ""
	$bg/EditWindow/Error.visible = false
	windowopened = false


func editcancel() -> void:
	editWindow.visile = false
	editmaxblood.valaue = 0
	editName.text = ""
	windowopened = false
	$bg/EditWindow/Error.visible = false

# RATE EDIT WINDOW

func _on_rateedit_pressed(btn: Button) -> void:
	if windowopened: return
	customsource.text = ""
	customrate.value = 0
	
	rateEditWindow.visible = true
	windowopened = true
	UpdateSources(btn.get_meta("id"))
	updateEditing(btn.get_meta("id"))
	updateList()

func _on_add_pressed() -> void:
	var cleanedtext = customsource.text.replace(" ", "")
	if cleanedtext == "":
		$bg/RateEditWindow/RateAddConfig/Error.visible = true
		$bg/RateEditWindow/RateAddConfig/Error.text = "Source must be specified."
		return
	
	
	if customrate.value == 0:
		$bg/RateEditWindow/RateAddConfig/Error.visible = true
		$bg/RateEditWindow/RateAddConfig/Error.text = "Rate must not be 0."
		return
	
	$bg/RateEditWindow/RateAddConfig/Error.visible = false
	
	tempDict[customsource.text + ": " + str(customrate.value)] = customsource.text
	Sources[customsource.text] = customrate.value
	updateList()
	
	loglist.add_item("Added bleed rate " + customsource.text + " with strenght of " + str(customrate.value) + " for " + editing.text)
	
	customsource.text = ""
	customrate.value = 0

func onDelete():
	var selected = list.get_selected_items()
	#print(selected)
	
	if selected.size() > 0:
		var indextoremove = selected[0]
		var key = tempDict[list.get_item_text(indextoremove)]
		
		loglist.add_item("Deleted blood rate " + key + " from " + editing.text)
		
		Sources.erase(key)
		tempDict.erase(list.get_item_text(indextoremove))
		
		list.remove_item(indextoremove)
		
	else:
		print("Nothing selected")

func onClose():
	rateEditWindow.visible = false
	UpdateRate()
	windowopened = false

func updateList():
	list.clear()
	
	for i in Sources:
		list.add_item(i + ": " + str(Sources[i]))
		

func OnApply(btn: Button):
	if windowopened: return
	var id = btn.get_meta("id")
	UpdateSources(id)
	updateEditing(id)
	
	var previousblood = Tracker["blood"]
	
	Tracker["blood"] += Tracker["rate"]
	if Tracker["blood"] > Tracker["maxblood"]:
		Tracker["blood"] = Tracker["maxblood"]
	
	if Tracker["blood"] < 0.0:
		Tracker["blood"] = 0.0
	
	var factor = pow(10.0, 2)
	var percentage = ceil((Tracker["blood"] / Tracker["maxblood"] * 100) * factor) / factor
	editing.get_node("Blood").text = str(Tracker["blood"]) + "(" + str(percentage) + "%)"
	
	var startColor = Color.GREEN
	var EndColor = Color.RED
	
	var normVal = (Tracker["blood"] - 0.0) / (Tracker["maxblood"] - 0.0)
	var interpolatedColor = EndColor.lerp(startColor, normVal)
	
	editing.get_node("Blood").label_settings.font_color = interpolatedColor
	
	loglist.add_item("Applied rate of " + str(Tracker["rate"]) + " to " + editing.text + ", changed from " + str(previousblood) + " to " + str(Tracker["blood"]))

func OnReset(btn: Button):
	if windowopened: return
	var id = btn.get_meta("id")
	UpdateSources(id)
	updateEditing(id)
	
	loglist.add_item("Resetted " + editing.text + "'s blood from " + str(Tracker["blood"]) + " to " + str(Tracker["maxblood"]))
	Tracker["blood"] = Tracker["maxblood"]
	editing.get_node("Blood").text = str(Tracker["blood"]) + "(100.0%)"
	editing.get_node("Blood").label_settings.font_color = Color.GREEN

func UpdateSources(ID):
	if ID == 1:
		Sources = Singleton.Tracker1["Sources"]
		Tracker = Singleton.Tracker1
	elif ID == 2:
		Sources = Singleton.Tracker2["Sources"]
		Tracker = Singleton.Tracker2
	elif ID == 3:
		Sources = Singleton.Tracker3["Sources"]
		Tracker = Singleton.Tracker3
	elif ID == 4:
		Sources = Singleton.Tracker4["Sources"]
		Tracker = Singleton.Tracker4
	elif ID == 5:
		Sources = Singleton.Tracker5["Sources"]
		Tracker = Singleton.Tracker5
	elif ID == 6:
		Sources = Singleton.Tracker6["Sources"]
		Tracker = Singleton.Tracker6
	elif ID == 7:
		Sources = Singleton.Tracker7["Sources"]
		Tracker = Singleton.Tracker7
	elif ID == 8:
		Sources = Singleton.Tracker8["Sources"]
		Tracker = Singleton.Tracker8
	elif ID == 9:
		Sources = Singleton.Tracker9["Sources"]
		Tracker = Singleton.Tracker9

func updateEditing(ID):
	#print(ID)
	if ID == 1:
		editing = $"bg/Trackers/1"
	elif ID == 2:
		editing = $"bg/Trackers/2"
	elif ID == 3:
		editing = $"bg/Trackers/3"
	elif ID == 4:
		editing = $"bg/Trackers/4"
	elif ID == 5:
		editing = $"bg/Trackers/5"
	elif ID == 6:
		editing = $"bg/Trackers/6"
	elif ID == 7:
		editing = $"bg/Trackers/7"
	elif ID == 8:
		editing = $"bg/Trackers/8"
	elif ID == 9:
		editing = $"bg/Trackers/9"

func UpdateRate():
	var base = 2
	
	for i in Sources:
		base += Sources[i]
	
	if base <= 0:
		editing.get_node("rate").text = str(base)
	else:
		editing.get_node("rate").text = "+" + str(base)
	
	Tracker["rate"] = base

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print(curTracker)


func _on_logs_pressed() -> void:
	$bg/logs/bg.visible = not $bg/logs/bg.visible
