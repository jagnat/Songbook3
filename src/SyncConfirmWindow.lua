-- asks whether to start the sync when some parts are not ready
SyncConfirmWindow = class(Turbine.UI.Lotro.Window)

function SyncConfirmWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor(self)

	self:SetSize(300, 185)
	self:SetPosition(Turbine.UI.Display:GetWidth() / 2 - 100, Turbine.UI.Display:GetHeight() / 2 - 100)
	self:SetText("Sync Start")
	self:SetZOrder(100)

	self.message = Turbine.UI.Label()
	self.message:SetParent(self)
	self.message:SetSize(280, 50)
	self.message:SetPosition(10, 50)
	self.message:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)

	-- yes runs the start alias through the quickslot; no just closes
	self.yesSlot, self.yesIcon = self:CreateButton(80, "Yes",
		Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"]))
	self.noSlot, self.noIcon = self:CreateButton(185, "No", nil)

	self:SetPending(false)
end

function SyncConfirmWindow:CreateButton(left, image, shortcut)
	local slot = Turbine.UI.Lotro.Quickslot()
	slot:SetParent(self)
	slot:SetPosition(left, 120)
	slot:SetSize(35, 20)
	slot:SetZOrder(100)
	slot:SetAllowDrop(false)
	if shortcut then slot:SetShortcut(shortcut) end

	local icon = Turbine.UI.Control()
	icon:SetParent(self)
	icon:SetPosition(left, 120)
	icon:SetSize(35, 20)
	icon:SetZOrder(110)
	icon:SetMouseVisible(false)
	icon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
	icon:SetBackground(gDir .. image .. ".tga")

	slot.DragDrop = function(sender, args)
		if shortcut then slot:SetShortcut(shortcut) end
	end
	slot.MouseEnter = function(sender, args)
		icon:SetBackground(gDir .. image .. "_hover.tga")
	end
	slot.MouseLeave = function(sender, args)
		icon:SetBackground(gDir .. image .. ".tga")
	end
	slot.MouseDown = function(sender, args)
		icon:SetBackground(gDir .. image .. "_down.tga")
	end
	slot.MouseUp = function(sender, args)
		icon:SetBackground(gDir .. image .. "_hover.tga")
		self:SetVisible(false)
	end

	return slot, icon
end

-- pending shows the yes/no prompt; otherwise there is nothing to start
function SyncConfirmWindow:SetPending(pending)
	if pending then
		self.message:SetText("Some parts don't have correct state. Do you want to start?")
	else
		self.message:SetText("Nothing to Start")
	end
	self.yesSlot:SetVisible(pending)
	self.noSlot:SetVisible(pending)
	self.yesIcon:SetVisible(pending)
	self.noIcon:SetVisible(pending)
end
