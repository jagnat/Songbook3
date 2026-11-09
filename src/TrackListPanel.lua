
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

	self.onTrackSelected = nil
	self.onToggleTracks = nil

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
end

function TrackListPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
end

function TrackListPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
end

-- trackIndex is a list index into the trackCount visible tracks
function TrackListPanel:SetSelectedTrack(trackIndex, trackCount)
	local song = SongDB.Songs[SongLibrary.selectedSongIndex]
	local iTrack = SongLibrary.SelectedTrackIndex(trackIndex)
	if not song or trackIndex > trackCount or not song.Tracks[iTrack] then
		self:Clear()
		return
	end
	self:UpdateNavButtons(trackIndex, trackCount)
	self.trackNumber:SetText(song.Tracks[iTrack].Id)
end

function TrackListPanel:Clear()
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
