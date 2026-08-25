
DescriptionPanel = class(Turbine.UI.Control)

function DescriptionPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.titleLabel = Turbine.UI.Label()
	self.titleLabel:SetParent(self)
	self.titleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana16)
	self.titleLabel:SetForeColor(ColorTheme.colourDefaultHighlighted)
	self.titleLabel:SetPosition(0, 0)
end

function DescriptionPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
	self.titleLabel:SetWidth(w)
end

function DescriptionPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
	self.titleLabel:SetHeight(h)
end

function DescriptionPanel:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.titleLabel:SetVisible(bVisible)
end

function DescriptionPanel:SetSong(songIndex)
	local song = SongDB.Songs[songIndex]
	if not song then
		self:Clear()
		return
	end
	local trackIdx = SongLibrary.SelectedTrackIndex(SongLibrary.selectedTrack) or 1
	local track = song.Tracks[trackIdx]
	if track and track.Name ~= "" then
		self.titleLabel:SetText(track.Name)
	else
		self.titleLabel:SetText(song.Filename)
	end
end

function DescriptionPanel:Clear()
	self.titleLabel:SetText("")
end
