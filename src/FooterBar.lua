FooterBar = class(Turbine.UI.Control)

local BUTTON_TOP = 0

function FooterBar:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.onRefreshClicked = nil
	self.onSettingsClicked = nil
	self.onSyncInfoClicked = nil

	self.refreshBtn = self:CreateButton(130, Strings["ui_refresh"], function() return self.onRefreshClicked end)
	self.settingsBtn = self:CreateButton(110, Strings["ui_settings"], function() return self.onSettingsClicked end)
	self.syncInfoBtn = self:CreateButton(110, Strings["ui_syncinfo"], function() return self.onSyncInfoClicked end)

	self:Layout()
end

function FooterBar:CreateButton(width, text, getHandler)
	local button = Turbine.UI.Lotro.Button()
	button:SetParent(self)
	button:SetSize(width, 20)
	button:SetText(text)
	button.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Left then
			local handler = getHandler()
			if handler then handler() end
		end
	end
	return button
end

function FooterBar:Layout()
	local width = self:GetWidth()
	self.refreshBtn:SetPosition(20, BUTTON_TOP)
	self.settingsBtn:SetPosition(width / 2 - 55, BUTTON_TOP)
	self.syncInfoBtn:SetPosition(width - 150, BUTTON_TOP)
end

function FooterBar:SetSize(width, height)
	Turbine.UI.Control.SetSize(self, width, height)
	self:Layout()
end

function FooterBar:SetWidth(width)
	Turbine.UI.Control.SetWidth(self, width)
	self:Layout()
end

function FooterBar:SetRefreshing(refreshing)
	self.refreshBtn:SetEnabled(not refreshing)
	self.refreshBtn:SetText(refreshing and Strings["ui_refreshing"] or Strings["ui_refresh"])
end
