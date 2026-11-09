-- lists the local songs matching another player's sync message
SongMatchesWindow = class(ListWindow)

function SongMatchesWindow:Constructor()
	ListWindow.Constructor(self, "Matched Songs", 600, 300)
	self:SetZOrder(100)
	self:SetPosition(Turbine.UI.Display:GetWidth() / 2 - 300, Turbine.UI.Display:GetHeight() / 2 - 200)

	self.onSongChosen = nil
end

-- colours follow the sync state at the time of each mouse event
local function ItemColour(normal, onlySynced)
	if SyncManager.otherPlayerSynced then return onlySynced end
	return normal
end

-- songs is a list of { index, text }
function SongMatchesWindow:ShowMatches(songs)
	self.listBox:ClearItems()
	for _, song in ipairs(songs) do
		self:AddMatch(song.index, song.text)
	end
end

function SongMatchesWindow:AddMatch(songIndex, text)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetSize(2000, 20)
	item:SetMarkupEnabled(true)
	item:SetForeColor(ItemColour(ColorTheme.colour_syncMessageTitle, ColorTheme.colour_syncMessageTitle_OnlySynced))
	item:SetBackColor(ColorTheme.backColourDefault)
	item:SetText(text)
	self.listBox:AddItem(item)

	item.MouseEnter = function(sender, args)
		if item:IsVisible() then
			item:SetForeColor(ItemColour(ColorTheme.colour_syncMessageTitle_Highlighted, ColorTheme.colour_syncMessageTitle_Highlighted_OnlySynced))
		end
	end
	item.MouseLeave = function(sender, args)
		if item:IsVisible() then
			item:SetForeColor(ItemColour(ColorTheme.colour_syncMessageTitle, ColorTheme.colour_syncMessageTitle_OnlySynced))
		end
	end
	item.MouseDown = function(sender, args)
		if item:IsVisible() then
			item:SetForeColor(ItemColour(ColorTheme.colour_syncMessageTitle_MouseDown, ColorTheme.colour_syncMessageTitle_MouseDown_OnlySynced))
		end
	end
	item.MouseUp = function(sender, args)
		if item:IsVisible() then
			item:SetForeColor(ItemColour(ColorTheme.colour_syncMessageTitle, ColorTheme.colour_syncMessageTitle_OnlySynced))
			if self.onSongChosen then self.onSongChosen(songIndex) end
		end
	end
end
