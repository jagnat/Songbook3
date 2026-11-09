
-- TrackDetailPanel
-- A wrapping row of setup labels above the track list.
-- Clicking a setup label shows only the tracks for that setup; the "all" label
-- restores the full list.
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
local SETUP_FONT = Turbine.UI.Lotro.Font.Verdana14
-- labels don't auto-size, so widths are estimated per character
local SETUP_CHAR_WIDTH = 8
local SETUP_NARROW_CHARS = { [" "] = 4, ["("] = 5, [")"] = 5, ["l"] = 3, ["i"] = 3, [":"] = 4, ["."] = 4 }
local SETUP_LABEL_PADDING = 16
local SETUP_LABEL_GAP = 2

function TrackDetailPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.setupRow = Turbine.UI.Control()
	self.setupRow:SetParent(self)
	self.setupRow:SetPosition(0, 0)
	self.setupRow:SetVisible(false)

	self.setupPrefix = self:CreateSetupLabel(Strings["ui_part_setups"])
	self.setupPrefix:SetMouseVisible(false)

	self.listbox = ListBoxScrolled:New(SCROLL_WIDTH)
	self.listbox:SetParent(self)
	self.listbox:SetPosition(0, 0)

	-- Callbacks set by the owner.
	self.onTrackSelected = nil   -- function(listIndex)  1-based track list index
	self.onSetupSelected = nil   -- function(setupIndex) nil = "All tracks"

	-- State
	self.songIndex = nil
	self.activeSetupIndex = nil  -- currently active setup; nil = "All"
	self.fullSetupIndex = nil    -- setup that already contains every track, shown as the "all" label
	self.allSetupIndex = nil     -- index of the "all" label in setupLabels
	self.setupLabels = {}        -- by setup index; an extra "all" label sits at #Setups + 1
	self.trackListToActual = {}  -- trackListToActual[listIdx] = actual track index
end

function TrackDetailPanel:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
	self.listbox:SetWidth(w - SCROLL_WIDTH)
	self:LayoutContents()
end

function TrackDetailPanel:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
	self:LayoutContents()
end

function TrackDetailPanel:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.listbox:SetVisible(bVisible)
	self:LayoutContents()
end

-- Places the prefix and setup labels left to right, wrapping when a line is full.
-- Returns the height the labels take.
function TrackDetailPanel:FlowSetupLabels(width)
	local x, y = 0, 0
	local function place(label)
		if x > 0 and x + label.flowWidth > width then
			x = 0
			y = y + ROW_HEIGHT
		end
		label:SetPosition(x, y)
		x = x + label.flowWidth + SETUP_LABEL_GAP
	end
	place(self.setupPrefix)
	for i = 1, #self.setupLabels do
		place(self.setupLabels[i])
	end
	return y + ROW_HEIGHT
end

function TrackDetailPanel:LayoutContents()
	local width, height = self:GetWidth(), self:GetHeight()
	local rowHeight = 0
	if #self.setupLabels > 0 then
		rowHeight = self:FlowSetupLabels(width)
	end
	self.setupRow:SetVisible(rowHeight > 0)
	self.setupRow:SetSize(width, rowHeight)
	self.listbox:SetTop(rowHeight)
	self.listbox:SetHeight(math.max(0, height - rowHeight))
end

function TrackDetailPanel:ClearSetupLabels()
	for i = 1, #self.setupLabels do
		self.setupLabels[i]:SetVisible(false)
		self.setupLabels[i]:SetParent(nil)
	end
	self.setupLabels = {}
	self.allSetupIndex = nil
end

function TrackDetailPanel:Clear()
	self.songIndex = nil
	self.activeSetupIndex = nil
	self.fullSetupIndex = nil
	self.trackListToActual = {}
	self:ClearSetupLabels()
	self.listbox:ClearItems()
	self:LayoutContents()
end

-- Populate the panel for a song: setup labels, then the track rows.
function TrackDetailPanel:ShowSong(songIndex)
	self.songIndex = songIndex
	self.activeSetupIndex = nil
	self.trackListToActual = {}

	SongLibrary.setupTrackIndices = {}
	SongLibrary.setupListIndices = {}
	SongLibrary.currentSetup = nil

	local song = SongDB.Songs[songIndex]
	self.fullSetupIndex = nil
	if song.Setups then
		for i = 1, #song.Setups do
			if #song.Setups[i] == #song.Tracks then
				self.fullSetupIndex = i
				break
			end
		end
	end
	self:BuildSetupLabels(song)
	self:LayoutContents()

	-- the remembered part count survives songs that lack a setup of that size
	local restoreSetup = SongLibrary.SetupIndexForCount(songIndex, SongLibrary.selectedSetupCount)
	if restoreSetup == self.fullSetupIndex then restoreSetup = nil end
	self:RebuildTrackRows(restoreSetup)
	self:HighlightSetup(restoreSetup)
end

function TrackDetailPanel:BuildSetupLabels(song)
	self:ClearSetupLabels()
	if not song.Setups or #song.Setups == 0 then return end
	local allText = #song.Tracks .. " (all)"
	for i = 1, #song.Setups do
		if i == self.fullSetupIndex then
			self.setupLabels[i] = self:CreateSetupItem(nil, allText)
		else
			self.setupLabels[i] = self:CreateSetupItem(i, tostring(#song.Setups[i]))
		end
	end
	self.allSetupIndex = self.fullSetupIndex
	if not self.allSetupIndex then
		self.allSetupIndex = #song.Setups + 1
		self.setupLabels[self.allSetupIndex] = self:CreateSetupItem(nil, allText)
	end
end

-- Rebuild the track rows.
-- setupIndex nil = show all tracks; number = filter to that setup.
function TrackDetailPanel:RebuildTrackRows(setupIndex)
	self.listbox:ClearItems()
	self.trackListToActual = {}

	local song = SongDB.Songs[self.songIndex]

	SongLibrary.setupTrackIndices = {}
	SongLibrary.setupListIndices = {}
	SongLibrary.currentSetup = nil

	if setupIndex and song.Setups and song.Setups[setupIndex] then
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
	else
		for i = 1, #song.Tracks do
			self.trackListToActual[i] = i
			self.listbox:AddItem(self:CreateTrackItem(self.songIndex, i, i))
		end
	end

	self.activeSetupIndex = setupIndex
end

-- Called when the user clicks a setup label.
function TrackDetailPanel:SelectSetup(setupIndex)
	local song = SongDB.Songs[self.songIndex]
	if setupIndex == self.fullSetupIndex then setupIndex = nil end
	SongLibrary.selectedSetupCount = setupIndex and #song.Setups[setupIndex] or nil
	self:RebuildTrackRows(setupIndex)
	self:HighlightSetup(setupIndex)
	if self.onSetupSelected then
		self.onSetupSelected(setupIndex)
	end
end

-- Highlight the selected setup label; clear others.
function TrackDetailPanel:HighlightSetup(setupIndex)
	local selected = setupIndex or self.allSetupIndex
	for i = 1, #self.setupLabels do
		if i == selected then
			self.setupLabels[i]:SetBackColor(ColorTheme.backColourHighlight)
		else
			self.setupLabels[i]:SetBackColor(ColorTheme.backColourDefault)
		end
	end
end

function TrackDetailPanel:CreateSetupLabel(text)
	local label = Turbine.UI.Label()
	label:SetParent(self.setupRow)
	label:SetMultiline(false)
	label:SetFont(SETUP_FONT)
	label:SetText(text)
	local textWidth = 0
	for ch in string.gmatch(text, ".") do
		textWidth = textWidth + (SETUP_NARROW_CHARS[ch] or SETUP_CHAR_WIDTH)
	end
	label.flowWidth = textWidth + SETUP_LABEL_PADDING
	label:SetSize(label.flowWidth, ROW_HEIGHT)
	label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
	label:SetForeColor(ColorTheme.colourMessageTitle)
	label:SetBackColor(ColorTheme.backColourDefault)
	return label
end

-- Creates a clickable setup label; setupIndex nil selects all tracks.
function TrackDetailPanel:CreateSetupItem(setupIndex, text)
	local label = self:CreateSetupLabel(text)
	label.MouseClick = function(sender, args)
		self:SelectSetup(setupIndex)
	end
	return label
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

-- Returns the track item label at the given 1-based list index.
function TrackDetailPanel:GetTrackItem(listIndex)
	return self.listbox:GetItem(listIndex)
end

-- Returns the number of visible track rows.
function TrackDetailPanel:GetTrackCount()
	return self.listbox:GetItemCount()
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

-- Applies foreground colour to a setup label (for readiness indication).
function TrackDetailPanel:SetSetupColour(setupIndex, colour)
	local item = self.setupLabels[setupIndex]
	if item then item:SetForeColor(colour) end
end
