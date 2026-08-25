
TrackListPanel = class(Turbine.UI.Control)

function TrackListPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	-- Track up arrow
	self.trackPrev = Turbine.UI.Control()
	self.trackPrev:SetParent(self)
	self.trackPrev:SetPosition(5, 0)
	self.trackPrev:SetSize(12, 8)
	self.trackPrev:SetBackground(gDir .. "arrowup.tga")
	self.trackPrev:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
	self.trackPrev:SetVisible(false)

	-- Track label ("X:")
	self.trackLabel = Turbine.UI.Label()
	self.trackLabel:SetParent(self)
	self.trackLabel:SetPosition(0, 12)
	self.trackLabel:SetSize(30, 12)
	self.trackLabel:SetZOrder(200)
	self.trackLabel:SetText("X:")

	-- Track ID display
	self.trackNumber = Turbine.UI.Label()
	self.trackNumber:SetParent(self)
	self.trackNumber:SetPosition(15, 12)
	self.trackNumber:SetWidth(20)

	-- Track down arrow
	self.trackNext = Turbine.UI.Control()
	self.trackNext:SetParent(self)
	self.trackNext:SetPosition(5, 27)
	self.trackNext:SetSize(12, 8)
	self.trackNext:SetBackground(gDir .. "arrowdown.tga")
	self.trackNext:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend)
	self.trackNext:SetVisible(false)

	-- Hidden listbox for sync machinery
	self.tracklistBox = ListBoxCharColumn:New(10, 20)
	self.tracklistBox:SetParent(self)
	self.tracklistBox:SetVisible(false)

	self.onTrackSelected = nil
	self.onToggleTracks = nil
	self.alignTracksRight = false
	self.settingTrack = false

	local self_ref = self

	self.trackPrev.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Left then
			if self_ref.onTrackSelected then
				self_ref.onTrackSelected(SongLibrary.selectedTrack - 1)
			end
		end
	end

	self.trackNext.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Left then
			if self_ref.onTrackSelected then
				self_ref.onTrackSelected(SongLibrary.selectedTrack + 1)
			end
		end
	end

	self.trackLabel.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Left then
			if self_ref.onToggleTracks then
				self_ref.onToggleTracks()
			end
		end
	end

	self.tracklistBox.SelectedIndexChanged = function(sender, args)
		if not self_ref.settingTrack and self_ref.onTrackSelected then
			self_ref.onTrackSelected(sender:GetSelectedIndex())
		end
	end

	self.tracklistBox.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Right then
			self_ref:RealignTracknames()
		end
	end
end

function TrackListPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
end

function TrackListPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
end

function TrackListPanel:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.tracklistBox:SetVisible(false)
end

-- Rebuild the hidden tracklistBox rows for the given song.
function TrackListPanel:Populate(songIndex)
	self.tracklistBox:ClearItems()
	if not songIndex or not SongDB.Songs[songIndex] then
		self:Clear()
		return
	end
	for i = 1, #SongDB.Songs[songIndex].Tracks do
		self:AddTrackItem(songIndex, i)
	end
end

-- Add a single track row (used by ListTracksForSetup).
function TrackListPanel:AddTrackItem(iSong, iTrack)
	local sTerseName = SongLibrary.TerseTrackname(SongDB.Songs[iSong].Tracks[iTrack].Name)
	local item = self:CreateTracklistItem("[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "] " .. sTerseName)
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetSize(1000, 20)
	self.tracklistBox:AddItem(item)
end

-- Set the listbox selection and update visuals without firing onTrackSelected.
function TrackListPanel:SetSelectedTrack(trackIndex)
	local song = SongDB.Songs[SongLibrary.selectedSongIndex]
	if not song or not song.Tracks[trackIndex] then
		self:Clear()
		return
	end
	self.settingTrack = true
	self.tracklistBox:SetSelectedIndex(trackIndex)
	self.settingTrack = false

	local trackCount = #song.Tracks
	self:UpdateNavButtons(trackIndex, trackCount)

	local iTrack = SongLibrary.SelectedTrackIndex(trackIndex)
	self.trackNumber:SetText(song.Tracks[iTrack].Id)
end

function TrackListPanel:Clear()
	self.tracklistBox:ClearItems()
	self.trackNumber:SetText("")
	self.trackPrev:SetVisible(false)
	self.trackNext:SetVisible(false)
end

function TrackListPanel:UpdateNavButtons(selectedTrack, trackCount)
	if selectedTrack > 1 then
		if selectedTrack == trackCount then
			self.trackPrev:SetVisible(true)
			self.trackNext:SetVisible(false)
		else
			self.trackPrev:SetVisible(true)
			self.trackNext:SetVisible(true)
		end
	end
	if selectedTrack == 1 then
		self.trackPrev:SetVisible(false)
		if trackCount == 1 then
			self.trackNext:SetVisible(false)
		else
			self.trackNext:SetVisible(true)
		end
	end
end

function TrackListPanel:ClearItems()
	self.tracklistBox:ClearItems()
end

function TrackListPanel:GetItemCount()
	return self.tracklistBox:GetItemCount()
end

function TrackListPanel:GetSelectedIndex()
	return self.tracklistBox:GetSelectedIndex()
end

function TrackListPanel:SetColumnChar(iList, ch, bHL)
	self.tracklistBox:SetColumnChar(iList, ch, bHL)
end

function TrackListPanel:EnableCharColumn(bOn)
	self.tracklistBox:EnableCharColumn(bOn)
end

function TrackListPanel:SetHighlightReadyCol(bOn)
	self.tracklistBox.bHighlightReadyCol = bOn
end

function TrackListPanel:RealignTracknames()
	local alignment, left
	if self.alignTracksRight == false then
		self.alignTracksRight = true
		alignment = Turbine.UI.ContentAlignment.MiddleRight
		left = self.tracklistBox:GetWidth() - 1010
	else
		self.alignTracksRight = false
		alignment = Turbine.UI.ContentAlignment.MiddleLeft
		if Settings.ReadyColState then left = 20
		else left = 0 end
	end
	for i = 1, self.tracklistBox:GetItemCount() do
		local item = self.tracklistBox:GetItem(i)
		item:SetLeft(left)
		item:SetTextAlignment(alignment)
	end
end

function TrackListPanel:CreateTracklistItem(sText)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetText(sText)
	item:SetForeColor(ColorTheme.colourDefault)
	local self_ref = self
	item.MouseClick = function(sender, args)
		if args.Button == Turbine.UI.MouseButton.Right then
			self_ref:RealignTracknames()
		end
	end
	return item
end
