
InstrumentSlotsPanel = class(Turbine.UI.Control)

local SLOT_PITCH = 40
local SLOT_SIZE = 37
local ROW_PITCH = 45
local ROW_HEIGHT = 38

-- settings is CharSettings; InstrSlots rows are persisted in place
function InstrumentSlotsPanel:Constructor(settings)
	Turbine.UI.Control.Constructor(self)

	self.settings = settings
	self.slots = {}
	self.dragging = false

	for row = 1, settings.InstrumentSlots_Rows do
		self.slots[row] = {}
		for col = 1, settings.InstrSlots[row]["number"] do
			self:CreateSlot(row, col)
		end
	end

	self:UpdateGeometry()
	Turbine.UI.Control.SetVisible(self, self:IsSlotsVisible())
end

function InstrumentSlotsPanel:SlotData(row, col)
	return self.settings.InstrSlots[row][tostring(col)]
end

function InstrumentSlotsPanel:CreateSlot(row, col)
	local slot = Turbine.UI.Lotro.Quickslot()
	slot:SetParent(self)
	slot:SetSize(SLOT_SIZE, SLOT_SIZE)
	slot:SetZOrder(100)
	slot:SetAllowDrop(true)
	self.slots[row][col] = slot

	local data = self:SlotData(row, col)
	if not data then
		data = { qsType = "", qsData = "" }
		self.settings.InstrSlots[row][tostring(col)] = data
	end

	pcall(function()
		slot:SetShortcut(Turbine.UI.Lotro.Shortcut(data.qsType, data.qsData))
	end)

	slot.ShortcutChanged = function(sender, args)
		pcall(function()
			local sc = sender:GetShortcut()
			local d = self:SlotData(row, col)
			d.qsType = tostring(sc:GetType())
			d.qsData = sc:GetData()
		end)
	end

	slot.DragLeave = function(sender, args)
		if self.dragging then
			local d = self:SlotData(row, col)
			d.qsType = ""
			d.qsData = ""
			sender:SetShortcut(Turbine.UI.Lotro.Shortcut("", ""))
			self.dragging = false
		end
	end

	slot.MouseDown = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Left then
			self.dragging = true
		end
	end
end

-- row 1 is at the bottom, higher rows stack above it
function InstrumentSlotsPanel:UpdateGeometry()
	local rows = self.settings.InstrumentSlots_Rows
	for row = 1, rows do
		for col, slot in ipairs(self.slots[row]) do
			slot:SetPosition(SLOT_PITCH * (col - 1), ROW_PITCH * (rows - row))
		end
	end
	self:SetSize(SLOT_PITCH * self.settings.InstrSlots[1]["number"], ROW_PITCH * (rows - 1) + ROW_HEIGHT)
end

function InstrumentSlotsPanel:IsSlotsVisible()
	return self.settings.InstrSlots[1]["visible"]
end

function InstrumentSlotsPanel:SetSlotsVisible(visible)
	self.settings.InstrSlots[1]["visible"] = visible
	Turbine.UI.Control.SetVisible(self, visible)
end

-- vertical space the window reserves for the panel
function InstrumentSlotsPanel:GetPreferredHeight()
	if not self:IsSlotsVisible() then return 0 end
	return ROW_PITCH * self.settings.InstrumentSlots_Rows
end

function InstrumentSlotsPanel:ClearSlots()
	for row = 1, self.settings.InstrumentSlots_Rows do
		for col = 1, self.settings.InstrSlots[row]["number"] do
			local d = self:SlotData(row, col)
			d.qsType = ""
			d.qsData = ""
			self.slots[row][col]:SetShortcut(Turbine.UI.Lotro.Shortcut("", ""))
		end
	end
end

function InstrumentSlotsPanel:AddSlot()
	local newCol = self.settings.InstrSlots[1]["number"] + 1
	for row = 1, self.settings.InstrumentSlots_Rows do
		self.settings.InstrSlots[row]["number"] = newCol
		self.settings.InstrSlots[row][tostring(newCol)] = { qsType = "", qsData = "" }
		self:CreateSlot(row, newCol)
	end
	self:UpdateGeometry()
end

function InstrumentSlotsPanel:RemoveSlot()
	for row = 1, self.settings.InstrumentSlots_Rows do
		local number = self.settings.InstrSlots[row]["number"]
		if number > 1 then
			self.slots[row][number]:SetVisible(false)
			self.slots[row][number] = nil
			self.settings.InstrSlots[row][tostring(number)] = nil
			self.settings.InstrSlots[row]["number"] = number - 1
		end
	end
	self:UpdateGeometry()
end

function InstrumentSlotsPanel:AddRow()
	if not self:IsSlotsVisible() then return end
	local settings = self.settings
	local newRow = settings.InstrumentSlots_Rows + 1
	local number = settings.InstrSlots[1]["number"]

	settings.InstrumentSlots_Rows = newRow
	settings.InstrSlots[newRow] = { visible = true, number = number }
	self.slots[newRow] = {}
	for col = 1, number do
		settings.InstrSlots[newRow][tostring(col)] = { qsType = "", qsData = "" }
		self:CreateSlot(newRow, col)
	end
	self:UpdateGeometry()
end

function InstrumentSlotsPanel:RemoveRow()
	if not self:IsSlotsVisible() then return end
	local settings = self.settings
	local rows = settings.InstrumentSlots_Rows
	if rows <= 1 then return end

	for col = 1, settings.InstrSlots[rows]["number"] do
		self.slots[rows][col]:SetVisible(false)
	end
	self.slots[rows] = nil
	settings.InstrSlots[rows] = nil
	settings.InstrumentSlots_Rows = rows - 1
	self:UpdateGeometry()
end
