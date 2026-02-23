-- Fanuilos, le linnathon

-- Songbook 3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InstrumentSlots = class(Turbine.UI.Control)

function InstrumentSlots:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.slots = {}
	self.slotPx = 37
	self.spacingPx = 3
	self.dragActive = false

	self:BuildSlots()
	self:UpdateLayout()
	self:SetVisible(CharSettings.InstrSlots[1].visible)

end

function InstrumentSlots:BuildSlots()
	for _, row in ipairs(self.slots) do
		for _, slot in ipairs(row) do
			slot:SetParent(nil)
		end
	end

	self.slots = {};

	for i = 1, CharSettings.InstrumentSlots_Rows do
		self.slots[i] = {}
		for j = 1, CharSettings.InstrumentSlots do
			local slot = Turbine.UI.Quickslot();
			slot:SetParent(self);
			-- slot:SetPosition()
			slot:SetSize(self.slotPx, self.slotPx);
			slot:SetZOrder(100);
			slot:SetAllowDrop(true);

			local slotSetting = CharSettings.InstrSlots[i][tostring(j)]

			-- Load shortcuts from user prefs
			if slotSetting and slotSetting.data ~= "" then
				pcall(function()
					local sc = Turbine.UI.Lotro.Shortcut( slotSetting.qsType, slotSetting.qsData);
					slot:SetShortcut(sc);
				end);
			end

			-- Set callback to save shortcuts to user prefs
			slot.ShortcutChanged = function(sender, args)
				pcall(function() 
					local sc = sender:GetShortcut();
					slotSetting.qsType = tostring(sc:GetType());
					slotSetting.qsData = sc:GetData();
				end);
			end

			slot.DragLeave = function(sender, args)
				if (instrdrag) then 
					slotSetting.qsType ="";
					slotSetting.qsData = "";
					local sc = Turbine.UI.Lotro.Shortcut( "", "");
					self.instrSlot[j][i]:SetShortcut(sc);
					instrdrag = false;
				end
			end

			slot.MouseDown = function(sender, args)
				if (args.Button == Turbine.UI.MouseButton.Left) then
					instrdrag = true
				end
			end

			self.slots[i][i] = slot;
		end
	end
end

function InstrumentSlots:UpdateLayout()
	local height = 0
	local width = 0
	for i, row in ipairs(self.slots) do
		for j, slot in ipairs(row) do
			local x = (j - 1) * (self.slotSize + self.spacing)
			local y = (i - 1) * (self.slotSize + self.spacing)
			slot:SetPosition(x, y)
		end
		local rowWidth = #row * (self.slotSize + self.spacing)
		if rowWidth > width then width = rowWidth end
	end
	height = #self.slots * (self.slotSize + self.spacing)
	self:SetSize(width, height)
end

function InstrumentSlots:Toggle()
	local hMod = InstrumentSlots_Shift * CharSettings.InstrumentSlots_Rows;
	CharSettings.InstrSlots[1]["visible"] = not CharSettings.InstrSlots[1]["visible"];
	self:SetVisible(CharSettings.InstrSlots[1]["visible"]);
end

function InstrumentSlots:Clear()
	for i, row in ipairs(self.slots) do
		for j, slot in ipairs(row) do
			local data = CharSettings.InstrSlots[i][tostring(j)]
			data.qsType = ""
			data.qsData = ""
			slot:SetShortcut(Turbine.UI.Lotro.Shortcut("", ""))
		end
	end
end

function InstrumentSlots:AddSlotCol()
	for i = 1, CharSettings.InstrumentSlots_Rows do
		local newIndex = CharSettings.InstrSlots[i].number + 1
		CharSettings.InstrSlots[i][tostring(newIndex)] = { qsType = "", qsData = "" }
		CharSettings.InstrSlots[i].number = newIndex
	end
	self:BuildSlots()
	self:UpdateLayout()
end

function InstrumentSlots:DelSlotCol()
	for i = 1, CharSettings.InstrumentSlots_Rows do
		local current = CharSettings.InstrSlots[i].number
		if current > 1 then
			CharSettings.InstrSlots[i][tostring(current)] = nil
			CharSettings.InstrSlots[i].number = current - 1
		end
	end
	self:BuildSlots()
	self:UpdateLayout()
end

function InstrumentSlots:AddSlotRow()
	local newRow = CharSettings.InstrumentSlots_Rows + 1
	CharSettings.InstrSlots[newRow] = { number = CharSettings.InstrSlots[1].number }
	for j = 1, CharSettings.InstrSlots[1].number do
		CharSettings.InstrSlots[newRow][tostring(j)] = { qsType = "", qsData = "" }
	end
	CharSettings.InstrumentSlots_Rows = newRow
	self:BuildSlots()
	self:UpdateLayout()
end

function InstrumentSlots:DelSlotRow()
	local current = CharSettings.InstrumentSlots_Rows
	if current > 1 then
		CharSettings.InstrSlots[current] = nil
		CharSettings.InstrumentSlots_Rows = current - 1
	end
	self:BuildSlots()
	self:UpdateLayout()
end
