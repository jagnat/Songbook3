-- one row per track of the selected song, showing which players are on it
PlayerSyncInfoWindow = class(ListWindow)

-- position is Settings.PlayersSyncInfoWindowPosition; updated in place
function PlayerSyncInfoWindow:Constructor(position)
	ListWindow.Constructor(self, "Tracks Sync Info", 400, 300)
	self.position = position

	local displayWidth, displayHeight = Turbine.UI.Display.GetSize()
	position.Left, position.Top, position.Width, position.Height = Utils.ClampToDisplay(
		position.Left, position.Top, position.Width, position.Height, displayWidth, displayHeight)

	self:SetPosition(position.Left, position.Top)
	self:SetSize(position.Width, position.Height)
	self:LayoutList()
end

function PlayerSyncInfoWindow:SavePosition()
	self.position.Left = self:GetLeft()
	self.position.Top = self:GetTop()
	self.position.Width = self:GetWidth()
	self.position.Height = self:GetHeight()
end

function PlayerSyncInfoWindow:ResizeEnded()
	self.position.Width = self:GetWidth()
	self.position.Height = self:GetHeight()
end

function PlayerSyncInfoWindow:Activated(sender, args)
	local width, height = self:GetSize()
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize()
	local left, top, changed
	left, top, width, height, changed = Utils.ClampToDisplay(self:GetLeft(), self:GetTop(), width, height, displayWidth, displayHeight)

	self.position.Left = left
	self.position.Top = top
	self.position.Width = width
	self.position.Height = height

	if changed then
		self:SetPosition(left, top)
		self:SetSize(width, height)
		self:LayoutList()
	end
end

-- texts holds one entry per track, in track order
function PlayerSyncInfoWindow:SetTracks(texts)
	self.listBox:ClearItems()
	for _, text in ipairs(texts) do
		local item = Turbine.UI.Label()
		item:SetMultiline(false)
		item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
		item:SetSize(2000, 20)
		item:SetMarkupEnabled(true)
		item:SetText(text)
		item:SetBackColor(ColorTheme.backColourDefault)
		self.listBox:AddItem(item)
	end
end

function PlayerSyncInfoWindow:UpdateTrack(trackIndex, text, foreColour, backColour)
	local item = self.listBox:GetItem(trackIndex)
	if not item then return end
	item:SetText(text)
	item:SetForeColor(foreColour)
	item:SetBackColor(backColour)
end
