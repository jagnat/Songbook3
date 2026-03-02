
-- TrackDetailPanel
-- Track list with inline setup header rows.
-- Setup rows appear at the top and act as filters; clicking one shows only the
-- tracks for that setup. "All tracks" restores the full list.
--
-- Uses a Control wrapper around a ListBoxScrolled (same pattern as SongFileBrowser).
-- Selection is handled via per-item MouseClick handlers on the Labels.
--
-- Usage:
--   local panel = TrackDetailPanel()
--   panel:SetParent(someContainer)
--   panel:SetSize(width, height)
--   panel.onTrackSelected = function(listIndex) ... end
--   panel.onSetupSelected = function(setupIndex) ... end  -- setupIndex nil = All
--   panel:ShowSong(songIndex)

TrackDetailPanel = class(Turbine.UI.Control)

local SCROLL_WIDTH = 10
local ROW_HEIGHT = 20

function TrackDetailPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.listbox = ListBoxScrolled:New(SCROLL_WIDTH)
	self.listbox:SetParent(self)
	self.listbox:SetPosition(0, 0)

	-- Callbacks set by the owner.
	self.onTrackSelected = nil   -- function(listIndex)  1-based track-section index
	self.onSetupSelected = nil   -- function(setupIndex) nil = "All tracks"

	-- State
	self.songIndex = nil
	self.setupRowCount = 0       -- number of setup header rows at the top
	self.activeSetupIndex = nil  -- currently active setup; nil = "All"
	self.trackListToActual = {}  -- trackListToActual[listIdx] = actual track index
end

function TrackDetailPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
	self.listbox:SetWidth(w - SCROLL_WIDTH)
end

function TrackDetailPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
	self.listbox:SetHeight(h)
end

function TrackDetailPanel:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.listbox:SetVisible(bVisible)
end

-- Populate the panel for a song. Adds setup header rows then all track rows.
function TrackDetailPanel:ShowSong(songIndex)
	self.songIndex = songIndex
	self.activeSetupIndex = nil
	self.setupRowCount = 0
	self.trackListToActual = {}

	SongLibrary.setupTrackIndices = {}
	SongLibrary.setupListIndices = {}
	SongLibrary.currentSetup = nil

	self.listbox:ClearItems()

	local song = SongDB.Songs[songIndex]
	if song.Setups and #song.Setups > 0 then
		for i = 1, #song.Setups do
			self.listbox:AddItem(self:CreateSetupHeaderItem(i, #song.Setups[i]))
		end
		self.listbox:AddItem(self:CreateAllTracksItem(#song.Tracks))
		self.setupRowCount = #song.Setups + 1
	end

	-- Show all tracks by default, restoring previously selected setup if any.
	local restoreSetup = SongLibrary.SetupIndexForCount(songIndex, SongLibrary.selectedSetupCount)
	self:RebuildTrackRows(restoreSetup)
	self:HighlightSetupRow(restoreSetup)
end

-- Rebuild only the track rows below the setup header rows.
-- setupIndex nil = show all tracks; number = filter to that setup.
function TrackDetailPanel:RebuildTrackRows(setupIndex)
	self.listbox:ClearItems()
	self.trackListToActual = {}

	local song = SongDB.Songs[self.songIndex]

	-- Re-add setup header rows.
	if self.setupRowCount > 0 then
		for i = 1, self.setupRowCount - 1 do
			self.listbox:AddItem(self:CreateSetupHeaderItem(i, #song.Setups[i]))
		end
		self.listbox:AddItem(self:CreateAllTracksItem(#song.Tracks))
	end

	-- Reset SongLibrary setup state.
	SongLibrary.setupTrackIndices = {}
	SongLibrary.setupListIndices = {}
	SongLibrary.currentSetup = nil

	if setupIndex and setupIndex < self.setupRowCount then
		-- Filtered mode: show only the tracks in this setup.
		SongLibrary.currentSetup = setupIndex
		local setup = song.Setups[setupIndex]
		for i = 1, #setup do
			local iTrack = setup:byte(i) - 64
			SongLibrary.setupTrackIndices[i] = iTrack
			SongLibrary.setupListIndices[iTrack] = i
			self.trackListToActual[i] = iTrack
			self.listbox:AddItem(self:CreateTrackItem(self.songIndex, iTrack, i))
		end
		SongLibrary.selectedSetupCount = #setup
	else
		-- Unfiltered: show all tracks.
		SongLibrary.selectedSetupCount = nil
		for i = 1, #song.Tracks do
			self.trackListToActual[i] = i
			self.listbox:AddItem(self:CreateTrackItem(self.songIndex, i, i))
		end
	end

	self.activeSetupIndex = setupIndex
end

-- Called when the user clicks a setup header row.
function TrackDetailPanel:SelectSetup(setupIndex)
	self:RebuildTrackRows(setupIndex)
	self:HighlightSetupRow(setupIndex)
	if self.onSetupSelected then
		self.onSetupSelected(setupIndex)
	end
end

-- Highlight the selected setup row; clear others.
function TrackDetailPanel:HighlightSetupRow(setupIndex)
	if self.setupRowCount == 0 then return end
	for i = 1, self.setupRowCount do
		local item = self.listbox:GetItem(i)
		if item then
			local isSelected = (i == setupIndex) or (setupIndex == nil and i == self.setupRowCount)
			if isSelected then
				item:SetBackColor(ColorTheme.backColourHighlight)
			else
				item:SetBackColor(ColorTheme.backColourDefault)
			end
		end
	end
end

-- Creates a setup header label ("3 parts", "5 parts", etc.)
function TrackDetailPanel:CreateSetupHeaderItem(setupIndex, trackCount)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetSize(1000, ROW_HEIGHT)
	item:SetText(trackCount .. " " .. Strings["ui_parts"])
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetForeColor(ColorTheme.colourMessageTitle)
	item:SetBackColor(ColorTheme.backColourDefault)

	local self_ref = self
	local idx = setupIndex
	item.MouseClick = function(sender, args)
		self_ref:SelectSetup(idx)
	end

	return item
end

-- Creates the "All tracks" header label.
function TrackDetailPanel:CreateAllTracksItem(totalTracks)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetSize(1000, ROW_HEIGHT)
	item:SetText(totalTracks .. " " .. Strings["ui_parts"] .. " (all)")
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetForeColor(ColorTheme.colourMessageTitle)
	item:SetBackColor(ColorTheme.backColourDefault)

	local self_ref = self
	item.MouseClick = function(sender, args)
		self_ref:SelectSetup(nil)
	end

	return item
end

-- Creates a track row label.
function TrackDetailPanel:CreateTrackItem(songIndex, trackIndex, listIndex)
	local track = SongDB.Songs[songIndex].Tracks[trackIndex]
	local sTerseName = SongLibrary.TerseTrackname(track.Name)
	local sText = "[" .. track.Id .. "] " .. sTerseName

	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetSize(1000, ROW_HEIGHT)
	item:SetText(sText)
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetForeColor(ColorTheme.colourDefault)
	item.trackText = sText

	local self_ref = self
	local li = listIndex
	item.MouseClick = function(sender, args)
		if self_ref.onTrackSelected then
			self_ref.onTrackSelected(li)
		end
	end

	return item
end

-- Returns the track item label at the given 1-based track-section list index.
function TrackDetailPanel:GetTrackItem(listIndex)
	return self.listbox:GetItem(self.setupRowCount + listIndex)
end

-- Returns the setup header label at the given 1-based setup index.
function TrackDetailPanel:GetSetupItem(setupIndex)
	return self.listbox:GetItem(setupIndex)
end

-- Returns the number of visible track rows.
function TrackDetailPanel:GetTrackCount()
	return self.listbox:GetItemCount() - self.setupRowCount
end

-- Updates the ready-state char prefix in the track row label text.
function TrackDetailPanel:SetTrackReadyChar(listIndex, ch, bHighlight)
	local item = self:GetTrackItem(listIndex)
	if not item then return end
	local prefix = (ch and ch ~= "" and ch ~= " ") and (ch .. " ") or ""
	item:SetText(prefix .. (item.trackText or ""))
	if bHighlight then
		item:SetForeColor(Turbine.UI.Color(1, 0, 0, 0))
		item:SetBackColor(Turbine.UI.Color(1, 0.7, 0.7, 0.7))
	end
end

-- Applies foreground and background colours to a track row.
function TrackDetailPanel:SetTrackColour(listIndex, fgColour, bgColour)
	local item = self:GetTrackItem(listIndex)
	if not item then return end
	if fgColour then item:SetForeColor(fgColour) end
	if bgColour then item:SetBackColor(bgColour) end
end

-- Applies foreground colour to a setup header row (for readiness indication).
function TrackDetailPanel:SetSetupColour(setupIndex, colour)
	local item = self:GetSetupItem(setupIndex)
	if item then item:SetForeColor(colour) end
end
