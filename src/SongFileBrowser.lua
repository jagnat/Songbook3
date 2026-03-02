
-- SongFileBrowser
-- Flat file-browser for the song library using ListBoxScrolled.
-- Shows the current directory's subfolders and songs as a flat list.
-- A navigation bar at the top shows the current path and a back button.
-- In search mode, shows matching songs as a flat list (nav bar hidden).
--
-- The control wraps a ListBoxScrolled; size/position methods manage
-- both the nav bar and the listbox together.

SongFileBrowser = class(Turbine.UI.Control)

local SCROLL_WIDTH = 10
local NAV_HEIGHT = 20
local ROW_HEIGHT = 20
local LABEL_WIDTH = 600


function SongFileBrowser:Constructor()
	Turbine.UI.Control.Constructor(self)

	-- Navigation bar: back button + current path label
	self.backBtn = Turbine.UI.Label()
	self.backBtn:SetParent(self)
	self.backBtn:SetSize(40, NAV_HEIGHT)
	self.backBtn:SetPosition(0, 0)
	self.backBtn:SetText("< ..")
	self.backBtn:SetForeColor(Turbine.UI.Color(1, 0.5, 0.8, 1.0))
	self.backBtn:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	self.backBtn:SetVisible(false)

	local self_ref = self
	self.backBtn.MouseClick = function(sender, args)
		SongLibrary.NavigateUp()
		self_ref:Populate()
	end

	self.pathLabel = Turbine.UI.Label()
	self.pathLabel:SetParent(self)
	self.pathLabel:SetPosition(45, 0)
	self.pathLabel:SetSize(LABEL_WIDTH, NAV_HEIGHT)
	self.pathLabel:SetForeColor(Turbine.UI.Color(1, 0.6, 0.6, 0.6))
	self.pathLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

	-- Song/directory list
	self.listbox = ListBoxScrolled:New(SCROLL_WIDTH)
	self.listbox:SetParent(self)
	self.listbox:SetLeft(0)
	self.listbox:SetTop(NAV_HEIGHT)

	-- Callback set by the owner; called when a song row is clicked.
	self.onSongSelected = nil

	-- Maps songIndex -> Label, used for sync colour updates.
	self.songLabels = {}

	-- Selection state.
	self.selectedSongIndex = nil
	self.selectedLabel = nil

	-- Whether we are currently in search mode.
	self.searching = false
end

function SongFileBrowser:SetWidth(w)
	Turbine.UI.Control.SetWidth(self, w)
	self.pathLabel:SetWidth(w - 45)
	self.listbox:SetWidth(w - SCROLL_WIDTH)
end

function SongFileBrowser:SetHeight(h)
	Turbine.UI.Control.SetHeight(self, h)
	self.listbox:SetHeight(h - NAV_HEIGHT)
end

function SongFileBrowser:SetVisible(bVisible)
	Turbine.UI.Control.SetVisible(self, bVisible)
	self.listbox:SetVisible(bVisible)
end

-- Build the directory listing for the current SongLibrary.selectedDir.
function SongFileBrowser:Populate()
	self.songLabels = {}
	self.selectedLabel = nil
	self.listbox:ClearItems()
	self.searching = false

	-- Update nav bar
	local atRoot = (SongLibrary.selectedDir == "/")
	self.backBtn:SetVisible(not atRoot)
	self.pathLabel:SetText(SongLibrary.selectedDir)

	-- Add subdirectory rows
	local subdirs = SongLibrary.GetSubdirectories()
	for _, dirName in ipairs(subdirs) do
		self.listbox:AddItem(self:CreateDirItem(dirName))
	end

	-- Add song rows for songs in the current directory
	local songs = SongLibrary.GetSongsInDirectory(nil)
	for _, entry in ipairs(songs) do
		self.listbox:AddItem(self:CreateSongItem(entry.index, entry.text))
	end

	-- Re-apply selection highlight if the selected song is visible here.
	if self.selectedSongIndex and self.songLabels[self.selectedSongIndex] then
		self.selectedLabel = self.songLabels[self.selectedSongIndex]
		self.selectedLabel:SetForeColor(ColorTheme.colourSongSelected)
	end
end

-- Creates a directory row label.
function SongFileBrowser:CreateDirItem(dirName)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetSize(LABEL_WIDTH, ROW_HEIGHT)
	item:SetText(dirName)
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetForeColor(ColorTheme.colourDir)

	local self_ref = self
	item.MouseClick = function(sender, args)
		SongLibrary.NavigateToDirectory(dirName)
		self_ref:Populate()
	end

	return item
end

-- Creates a song row label.
function SongFileBrowser:CreateSongItem(songIndex, displayText)
	local item = Turbine.UI.Label()
	item:SetMultiline(false)
	item:SetSize(LABEL_WIDTH, ROW_HEIGHT)
	item:SetText(displayText or SongLibrary.GetDisplayText(songIndex))
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetForeColor(ColorTheme.colourDefault)

	local self_ref = self
	item.MouseClick = function(sender, args)
		self_ref:HighlightSong(songIndex, item)
		if self_ref.onSongSelected then
			self_ref.onSongSelected(songIndex)
		end
	end

	self.songLabels[songIndex] = item
	return item
end

-- Highlights the selected song item; clears the previous selection.
function SongFileBrowser:HighlightSong(songIndex, item)
	if self.selectedLabel then
		self.selectedLabel:SetForeColor(ColorTheme.colourDefault)
	end
	self.selectedSongIndex = songIndex
	self.selectedLabel = item
	if item then
		item:SetForeColor(ColorTheme.colourSongSelected)
	end
end

-- Called externally (e.g. on initial load) to pre-highlight a song without
-- triggering the click callback.
function SongFileBrowser:SetSelectedSong(songIndex)
	self:HighlightSong(songIndex, self.songLabels[songIndex])
end

-- Switches to search mode: hides nav bar, shows matching songs flat.
function SongFileBrowser:Search(searchText, filters)
	self.songLabels = {}
	self.selectedLabel = nil
	self.listbox:ClearItems()
	self.searching = true

	self.backBtn:SetVisible(false)
	self.pathLabel:SetText("")

	local results = SongLibrary.SearchSongs(searchText, filters)
	for _, result in ipairs(results) do
		self.listbox:AddItem(self:CreateSongItem(result.index, result.text))
	end
end

-- Restores the directory browser after a search.
function SongFileBrowser:ClearSearch()
	self:Populate()
end

-- Updates the foreground colour of a song's label (for sync state display).
function SongFileBrowser:SetSongColour(songIndex, colour)
	if self.songLabels[songIndex] then
		self.songLabels[songIndex]:SetForeColor(colour)
	end
end
