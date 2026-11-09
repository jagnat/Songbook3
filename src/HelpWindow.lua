HelpWindow = class(Turbine.UI.Lotro.Window)

function HelpWindow:Constructor(disabled)
	Turbine.UI.Lotro.Window.Constructor(self)

	self:SetZOrder(100)
	self:SetSize(410, 500)
	self:SetPosition(Turbine.UI.Display:GetWidth() / 2 - 205, Turbine.UI.Display:GetHeight() / 2 - 250)
	self:SetText("Help")
	self:SetVisible(false)
	self:SetOpacity(0.9)

	self.onDisabledChanged = nil
	self.firstLoad = true

	self.frame = Turbine.UI.Control()
	self.frame:SetParent(self)
	self.frame:SetPosition(5, 40)
	self.frame:SetSize(400, 420)
	self.frame:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
	self.frame:SetBackground(gDir .. "Help_window.tga")

	self.disableCheck = Turbine.UI.Lotro.CheckBox()
	self.disableCheck:SetParent(self)
	self.disableCheck:SetPosition(50, 460)
	self.disableCheck:SetSize(200, 20)
	self.disableCheck:SetText(" Don't Show this again.")
	self.disableCheck:SetChecked(disabled)
	self.disableCheck.CheckedChanged = function(sender, args)
		if self.onDisabledChanged then self.onDisabledChanged(sender:IsChecked()) end
	end
end

-- only the first call after loading the plugin can show the window
function HelpWindow:ShowOnFirstLoad(disabled)
	if self.firstLoad and not disabled then
		self:SetVisible(true)
	end
	self.firstLoad = false
end
