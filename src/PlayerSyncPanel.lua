
PlayerSyncPanel = class(Turbine.UI.Control)

function PlayerSyncPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	-- Player name and equipped instrument
	self.playerTitleLabel = Turbine.UI.Label()
	self.playerTitleLabel:SetParent(self)
	self.playerTitleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
	self.playerTitleLabel:SetForeColor(ColorTheme.colourDefaultHighlighted)
	self.playerTitleLabel:SetPosition(0, 0)
	self.playerTitleLabel:SetHeight(16)
	self.playerTitleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
	self.playerTitleLabel:SetText("")

	-- the owner parents and places the tag so it can sit in the title bar
	self.channelTagLabel = Turbine.UI.Label()
	self.channelTagLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12)
	self.channelTagLabel:SetForeColor(ColorTheme.colourMessageTitle)
	self.channelTagLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
	self.channelMessage = ""

	-- Synced song link (teal clickable label)
	self.syncMessageLabel = Turbine.UI.Label()
	self.syncMessageLabel:SetParent(self)
	self.syncMessageLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
	self.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle)
	self.syncMessageLabel:SetBackColor(ColorTheme.backColourHighlight)
	self.syncMessageLabel:SetPosition(8, 20)
	self.syncMessageLabel:SetSize(100, 16)
	self.syncMessageLabel:SetVisible(false)

	self.onNavigateToSyncedSong = nil
	self.onTooltipChanged = nil
	self.onShowMatchedSongs = nil

	local self_ref = self

	self.channelTagLabel.MouseEnter = function(sender, args)
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged(self_ref.channelMessage) end
	end

	self.channelTagLabel.MouseLeave = function(sender, args)
		if self_ref.onTooltipChanged then self_ref.onTooltipChanged("") end
	end

	self.syncMessageLabel.MouseEnter = function(sender, args)
		if self_ref.syncMessageLabel:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_Highlighted)
			else
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_Highlighted_OnlySynced)
			end
		end
	end

	self.syncMessageLabel.MouseLeave = function(sender, args)
		if self_ref.syncMessageLabel:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle)
			else
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_OnlySynced)
			end
		end
	end

	self.syncMessageLabel.MouseDown = function(sender, args)
		if self_ref.syncMessageLabel:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_MouseDown)
			else
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_MouseDown_OnlySynced)
			end
		end
	end

	self.syncMessageLabel.MouseUp = function(sender, args)
		if self_ref.syncMessageLabel:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle)
			else
				self_ref.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_OnlySynced)
			end
			if SyncManager.multipleSongsMatch then
				if self_ref.onShowMatchedSongs then self_ref.onShowMatchedSongs() end
			elseif not SyncManager.missingMatchedSong then
				if self_ref.onNavigateToSyncedSong then
					self_ref.onNavigateToSyncedSong(SyncManager.otherPlayerSong)
				end
			end
		end
	end
end

function PlayerSyncPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
	self.playerTitleLabel:SetWidth(w)
	self.syncMessageLabel:SetWidth(w - 8)
end

function PlayerSyncPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
end

function PlayerSyncPanel:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.playerTitleLabel:SetVisible(bVisible)
end

function PlayerSyncPanel:SetPlayerText(text)
	self.playerTitleLabel:SetText(text)
end

function PlayerSyncPanel:GetChannelTag()
	return self.channelTagLabel
end

function PlayerSyncPanel:SetChannel(tag, message)
	self.channelTagLabel:SetText(tag)
	self.channelMessage = message
end

function PlayerSyncPanel:ShowSyncMessage(text, otherPlayerSynced)
	self.syncMessageLabel:SetText(text)
	if not otherPlayerSynced then
		self.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle)
	else
		self.syncMessageLabel:SetForeColor(ColorTheme.colour_syncMessageTitle_OnlySynced)
	end
	self.syncMessageLabel:SetVisible(true)
end

function PlayerSyncPanel:HideSyncMessage()
	self.syncMessageLabel:SetText("")
	self.syncMessageLabel:SetVisible(false)
end

-- Show/hide the sync label based on whether the current song matches the synced song.
function PlayerSyncPanel:UpdateSyncVisibility()
	local song = SongDB.Songs[SongLibrary.selectedSongIndex]
	if not song then
		self:HideSyncMessage()
		return
	end
	local syncedPath = SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename
	local currentPath = song.Filepath .. SongLibrary.selectedSong
	if syncedPath == currentPath then
		self.syncMessageLabel:SetVisible(false)
	else
		if syncedPath ~= "" and self.syncMessageLabel:GetText() ~= "" then
			self.syncMessageLabel:SetVisible(true)
		end
	end
end
