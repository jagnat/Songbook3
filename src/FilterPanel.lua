FilterPanel = class(Turbine.UI.Control)

FilterPanel.WIDTH = 170

local ROW_HEIGHT = 20
local EDIT_WIDTH = 80
local CHECK_LEFT = 82
local SEPARATOR_LEFT = 160
local PARTY_TOP = 105
local PARTY_MIN_HEIGHT = 145
local FILTER_MIN_HEIGHT = 40

-- readyChars: { none, ready, multiple, wrongPart, wrongSong } shown in the party ready column
function FilterPanel:Constructor(readyChars)
	Turbine.UI.Control.Constructor(self)

	self.readyChars = readyChars
	self.shown = false
	self.maxPartCount = nil -- nil when not limiting, else the player count

	self.onFiltersChanged = nil
	self.onPlayersRefreshed = nil

	self.rows = {}
	self.rows.partcount = self:CreateRow(0, Strings["filterParts"])
	self.rows.composer = self:CreateRow(1, Strings["filterArtist"])
	self.rows.genre = self:CreateRow(2, Strings["filterGenre"])
	self.rows.mood = self:CreateRow(3, Strings["filterMood"])
	self.rows.author = self:CreateRow(4, Strings["filterAuthor"])

	self.separator = Turbine.UI.Control()
	self.separator:SetParent(self)
	self.separator:SetZOrder(300)
	self.separator:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15))
	self.separator:SetPosition(SEPARATOR_LEFT, 0)
	self.separator:SetWidth(self.WIDTH - SEPARATOR_LEFT)

	local self_ref = self

	self.partyBtn = Turbine.UI.Lotro.Button()
	self.partyBtn:SetParent(self)
	self.partyBtn:SetPosition(0, PARTY_TOP)
	self.partyBtn:SetSize(92, ROW_HEIGHT)
	self.partyBtn:SetText(Strings["players"])
	self.partyBtn.MouseClick = function(sender, args)
		self_ref:RefreshPlayers()
	end

	self.playerList = ListBoxCharColumn:New(10, 20)
	self.playerList:SetParent(self)
	self.playerList:SetPosition(2, PARTY_TOP + ROW_HEIGHT)

	Turbine.UI.Control.SetVisible(self, false)
	Turbine.UI.Control.SetWidth(self, self.WIDTH)
	self:SetHeight(PARTY_MIN_HEIGHT)
end

function FilterPanel:CreateRow(row, labelText)
	local top = row * ROW_HEIGHT
	local self_ref = self

	local edit = Turbine.UI.Lotro.TextBox()
	edit:SetParent(self)
	edit:SetPosition(0, top)
	edit:SetSize(EDIT_WIDTH, ROW_HEIGHT)
	edit:SetFont(Turbine.UI.Lotro.Font.Verdana14)
	edit:SetMultiline(false)
	edit.KeyDown = function(sender, keyArgs)
		if keyArgs.Action == 162 then self_ref:NotifyFiltersChanged() end
	end

	local check = Turbine.UI.Lotro.CheckBox()
	check:SetParent(self)
	check:SetPosition(CHECK_LEFT, top)
	check:SetSize(80, ROW_HEIGHT)
	check:SetText(labelText)
	check.CheckedChanged = function(sender, args)
		self_ref:NotifyFiltersChanged()
	end

	return { edit = edit, check = check }
end

function FilterPanel:NotifyFiltersChanged()
	if self.onFiltersChanged then self.onFiltersChanged() end
end

function FilterPanel:SetVisible(bVisible)
	self.shown = bVisible
	Turbine.UI.Control.SetVisible(self, bVisible)
end

function FilterPanel:IsVisible()
	return self.shown
end

function FilterPanel:SetHeight(height)
	Turbine.UI.Control.SetHeight(self, height)

	-- rows that do not fit are hidden
	local filterHeight = math.max(height, FILTER_MIN_HEIGHT)
	self:SetRowVisible(self.rows.genre, filterHeight >= 60)
	self:SetRowVisible(self.rows.mood, filterHeight >= 80)
	self:SetRowVisible(self.rows.author, filterHeight >= 100)

	self.separator:SetHeight(filterHeight)

	local showParty = height >= PARTY_MIN_HEIGHT
	self.partyBtn:SetVisible(showParty)
	self.playerList:SetVisible(showParty)
	if showParty then
		self.playerList:SetHeight(height - PARTY_TOP - ROW_HEIGHT)
	end
end

function FilterPanel:SetRowVisible(row, bVisible)
	row.edit:SetVisible(bVisible)
	row.check:SetVisible(bVisible)
end

-- fields of checked rows only; maxPartCount is nil unless limiting to the party size
function FilterPanel:GetFilters()
	local filters = { maxPartCount = self.maxPartCount }
	for name, row in pairs(self.rows) do
		if row.check:IsChecked() then
			filters[name] = row.edit:GetText()
		end
	end
	return filters
end

function FilterPanel:AddPlayer(name)
	local item = Turbine.UI.Label()
	item:SetText(name)
	item:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
	item:SetSize(100, ROW_HEIGHT)
	self.playerList:AddItem(item)
end

function FilterPanel:RemovePlayer(name)
	for i = 1, self.playerList:GetItemCount() do
		if self.playerList:GetItem(i):GetText() == name then
			self.playerList:RemoveItemAt(i)
			return
		end
	end
end

-- TODO: Party object does not seem to report party members correctly?
function FilterPanel:RefreshPlayers()
	self.playerList:ClearItems()
	SyncManager.RefreshPlayers()
	self:UpdatePlayerColours()
	self:UpdateMaxPartCount()
	if self.maxPartCount then self:NotifyFiltersChanged() end
	if self.onPlayersRefreshed then self.onPlayersRefreshed() end
end

function FilterPanel:UpdatePlayerColours()
	if not SyncManager.players then return end

	local chars = self.readyChars
	local ready = SyncManager.currentSongReady
	for i = 1, self.playerList:GetItemCount() do
		local item = self.playerList:GetItem(i)
		local name = item:GetText()
		local colour, ch, highlight
		if SyncManager.players[name] == nil or SyncManager.players[name] == 0 then
			colour, ch, highlight = ColorTheme.colourDefault, chars.none, false
		elseif ready and ready[name] == 1 then
			colour, ch, highlight = ColorTheme.colourReady, chars.ready, false
		elseif ready and ready[name] == 2 then
			colour, ch, highlight = ColorTheme.colourReadyMultiple, chars.multiple, true
		elseif ready and ready[name] == 3 then
			colour, ch, highlight = ColorTheme.colourDifferentSetup, chars.wrongPart, true
		else
			colour, ch, highlight = ColorTheme.colourDifferentSong, chars.wrongSong, true
		end
		item:SetForeColor(colour)
		self.playerList:SetColumnChar(i, ch, highlight)
	end
end

function FilterPanel:SetReadyColumnEnabled(bOn)
	self.playerList:EnableCharColumn(bOn)
end

function FilterPanel:SetReadyHighlight(bOn)
	self.playerList.bHighlightReadyCol = bOn
end

-- limit part counts to the number of listed players
function FilterPanel:SetMaxPartCount(bActivate)
	if bActivate then self.maxPartCount = self.playerList:GetItemCount()
	else self.maxPartCount = nil
	end
end

-- party object is unreliable, so the limit only ever grows
function FilterPanel:UpdateMaxPartCount()
	local count = self.playerList:GetItemCount()
	if self.maxPartCount and self.maxPartCount < count then
		self.maxPartCount = count
	end
end
