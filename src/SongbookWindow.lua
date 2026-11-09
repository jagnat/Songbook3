
-- Fanuilos, le linnathon

-- Songbook 3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SongbookWindow = class( Turbine.UI.Window );

-- list components stay below the footer, empty label, slots (90) and resize grip (200)
-- where their edges touch
local SEPARATOR_ZORDER = 10
local TIMER_ZORDER = 20
local LIST_OVERLAY_ZORDER = 30

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	self.TimerWindowVisible = true;
	self.HelpWindowDisable = false;
	
	
	
	self.bCheckInstrument = true
	
	self.bShowReadyChars = true
	self.bHighlightReadyCol = true
	self.chNone = " "
	self.chReady = "~"
	self.chWrongSong = "S"
	self.chWrongPart = "P"
	self.chMultiple = "M"

	self:CreatePopupWindows()

	-- Apply settings to instance state
	self:ToggleTimerWindow( Settings.TimerWindowVisible )
	self:SetHelpWindowDisabled( Settings.HelpWindowDisable )

	self:ValidateWindowPosition( Settings.WindowPosition )
	
	-- Fix to prevent window or toggle to travel outside of the screen
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	
	if Settings.WindowPosition.Width + 0 > displayWidth then
		Settings.WindowPosition.Width = displayWidth - 0;
	end
	if Settings.WindowPosition.Height + 0 > displayHeight then
		Settings.WindowPosition.Height = displayHeight - 0;
		Settings.TracksHeight = Settings.WindowPosition.Height / 7;
	end
	if Settings.WindowPosition.Left + Settings.WindowPosition.Width > displayWidth then
		Settings.WindowPosition.Left = displayWidth - Settings.WindowPosition.Width;
	end
	if Settings.WindowPosition.Top + Settings.WindowPosition.Height > displayHeight then
		Settings.WindowPosition.Top = displayHeight - Settings.WindowPosition.Height;
	end
	if Settings.WindowPosition.Left < 0 then
		Settings.WindowPosition.Left = 0;
	end
	if Settings.WindowPosition.Top < 0 then
		Settings.WindowPosition.Top = 0;
	end	
	if Settings.ToggleLeft + 0 > displayWidth then
		Settings.ToggleLeft = displayWidth - 0;
	end
	if Settings.ToggleTop + 0 > displayHeight then
		Settings.ToggleTop = displayHeight - 0;
	end
	if Settings.ToggleLeft < 0 then
		Settings.ToggleLeft = 0;
	end
	if Settings.ToggleTop < 0 then
		Settings.ToggleTop = 0;
	end

	self.timerWindow:AdjustTimerPosition(displayWidth, displayHeight)

	-- Hide UI when F12 is pressed
	local hideUI = false;
	local wasVisible;
	local settingsWindowWasVisible;
	local Timer_WindowWasVisible;
	local PlayersSyncInfoWindowWasVisible;
	self:SetWantsKeyEvents(true);

	self.KeyDown = function(sender, args)
		
		------------------------------------------------------
		
		if (args.Action == 268435635) then
			if not hideUI then
				hideUI = true;
				if self:IsVisible() then
					wasVisible = true;
					self:SetVisible(false);					
				else
					wasVisible = false;
				end
				toggleWindow:SetVisible(false);
				
				if settingsWindow:IsVisible() then
					settingsWindowWasVisible = true;
					settingsWindow:SetVisible(false);					
				else
					settingsWindowWasVisible = false;
				end
				
				if self.playerSyncInfoWindow:IsVisible() then
					PlayersSyncInfoWindowWasVisible = true;
					self.playerSyncInfoWindow:SetVisible(false);					
				else
					PlayersSyncInfoWindowWasVisible = false;
				end
				
				if self.timerWindow:IsVisible() then
					Timer_WindowWasVisible = true;
					self.timerWindow:SetVisible(false);					
				else
					Timer_WindowWasVisible = false;
				end
			else
				hideUI = false;
				if wasVisible then
					self:SetVisible(true);
					self:Activate();
				end
				if (Settings.ToggleVisible) then
					toggleWindow:SetVisible(true);
				end
				
				if settingsWindowWasVisible then
					settingsWindow:SetVisible(true);
					settingsWindow:Activate();					
				end
				if PlayersSyncInfoWindowWasVisible then
					self.playerSyncInfoWindow:SetVisible(true);	
					self.playerSyncInfoWindow:Activate();
				end
				if Timer_WindowWasVisible then
					self.timerWindow:SetVisible(true);	
					self.timerWindow:Activate();
				end
			end
		
		------------------------------------------------------
		
		--elseif (args.Action == 268435635) then
			
		end
	end
	
	self:SetPosition( Settings.WindowPosition.Left, Settings.WindowPosition.Top );
	self:SetSize( Settings.WindowPosition.Width, Settings.WindowPosition.Height );
	--self:SetZOrder(10);
	
	self.timerWindow:SetPosition( Settings.Timer_WindowPosition.Left, Settings.Timer_WindowPosition.Top );
	
	self:SetOpacity( Settings.WindowOpacity );
	--self:SetText("Songbook " .. Plugins[gPlugin]:GetVersion() .. Strings["title"] );
	self:SetText("Songbook " .. "3" );
	
	self.Version = Turbine.UI.Label();
	self.Version:SetParent( self );
	self.Version:SetFont(Turbine.UI.Lotro.Font.Verdana12);
	self.Version:SetForeColor( ColorTheme.colourMessageTitle );
	self.Version:SetText("V" .. Plugins[gPlugin]:GetVersion());

	-- Frame for the song list
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	-- created before the list components so they draw above it
	self.listBackground = Turbine.UI.Control()
	self.listBackground:SetParent(self)
	self.listBackground:SetBackColor(Turbine.UI.Color(1, 0, 0, 0))

	-- outer frame title
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_dirs"] );

	-- separator2 between song list and track list
	self.sepSongsTracks = self:CreateSeparator()
	-- separator2 title
	self.sepSongsTracks.heading = self:CreateSeparatorHeading( self.sepSongsTracks, Strings["ui_parts"] );
	-- separator2 hint arrows
	self.sArrows2 = self:CreateSeparatorArrows( self.sepSongsTracks )

	-- Tooltip
	self.tipLabel = Turbine.UI.Label();
	self.tipLabel:SetParent( self );
	self.tipLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.tipLabel:SetText("");
	
	self.controlBar = ControlBar()
	self.controlBar:SetParent(self)
	self.controlBar.onTooltipChanged = function(text) self.tipLabel:SetText(text) end
	self.controlBar.onSyncClicked = function()
		SyncManager.userChatBlocked = false
		SyncManager.syncedSongIndex = SongLibrary.selectedSongIndex
		SyncManager.syncedTrack = SongLibrary.selectedTrack
		SyncManager.localPlayerSynced = false
		self:PlayerSyncInfo()
	end
	self.controlBar.onSendSyncInfoClicked = function()
		SyncManager.userChatBlocked = false
		self:PlayerSyncInfo()
	end
	self.controlBar.onSyncStartClicked = function()
		if not SyncManager.syncStartReady then
			self.syncConfirmWindow:SetVisible(true)
			self.syncConfirmWindow:Activate()
		end
	end
	self.controlBar.onShareWheeled = function(direction)
		local nextCmd = tonumber(Settings.DefaultCommand) - direction
		local size = SettingsWindow:CountCmds()
		if nextCmd == 0 then
			Settings.DefaultCommand = tostring(size)
		elseif nextCmd > size then
			Settings.DefaultCommand = "1"
		else
			Settings.DefaultCommand = tostring(nextCmd)
		end
		self.controlBar:SetShareShortcut(self:ExpandCmd(Settings.DefaultCommand))
	end
	if Settings.Commands[Settings.DefaultCommand] then
		self.controlBar:SetShareShortcut(self:ExpandCmd(Settings.DefaultCommand))
	end

	self.trackListPanel = TrackListPanel()
	self.trackListPanel:SetParent(self)

	self.trackListPanel.onTrackSelected = function(trackIndex) self:SelectTrack(trackIndex) end
	self.trackListPanel.onToggleTracks = function() self:ToggleTracks() end
	
	self.descriptionPanel = DescriptionPanel()
	self.descriptionPanel:SetParent(self)
	
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	self.playerSyncPanel = PlayerSyncPanel()
	self.playerSyncPanel:SetParent(self)
	self.playerSyncPanel.onNavigateToSyncedSong = function(otherPlayerSong)
		SongLibrary.NavigateToPath(otherPlayerSong.filepath)
		self.songFileBrowser:Populate()
		self:SelectSongByIndex(otherPlayerSong.index)
	end
	self.playerSyncPanel.onShowMatchedSongs = function()
		self.songMatchesWindow:SetVisible(true)
	end

	self:UpdatePlayerTitle();
	self.playerEquipment = self.playerInstance:GetEquipment()

	self.playerEquipment.ItemEquipped = function(sender, args)
		local insIndex = self:PlayerSyncInfo()
		if insIndex == 0 then return end
		local trackListEmpty = self.trackDetailPanel == nil or self.trackDetailPanel:GetTrackCount() < 1
		if Settings.AutoPickOnInsChange and not trackListEmpty then
			local actualTrackIdx = SongLibrary.SelectedTrackIndex(SongLibrary.selectedTrack)
			if self:IsAvailableTrackWithMatchingInstrument(SongLibrary.selectedSongIndex, actualTrackIdx, insIndex) then
				return
			end

			local iTrack = self:GetTrackToSelect(SongLibrary.selectedSongIndex)
			if iTrack == 0 then return end
			self:SelectTrack(iTrack)
		end
	end
	
	
	if SyncManager.userChatNumber ~= 0 and SyncManager.userChatNumber ~= nil then
		SyncManager.chatChannel = "/" .. SyncManager.userChatNumber;
		self.playerSyncPanel:SetChannelMessage("SongBook is using User Chat channel " .. SyncManager.userChatNumber .. " - " .. SyncManager.userChatName)
	else
		self.playerSyncPanel:SetChannelMessage("SongBook is using Fellowship channel")
	end
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- search field
	self.searchInput = Turbine.UI.Lotro.TextBox();
	self.searchInput:SetParent(self);
	self.searchInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	self.searchInput:SetMultiline(false);	
	self.searchInput:SetVisible( false );
	
	self.searchInput:SetBackColor( Turbine.UI.Color( 0.2, 0.2, 0.2 ) );
		
	local searchFocus = false; 
	self.searchInput.KeyDown = function(sender, args)
		if (args.Action == 162) then
			if (searchFocus) then
				self:SearchSongs();
			end
		end
	end
	self.searchInput.FocusGained = function(sender, args)
		searchFocus = true;
	end
	self.searchInput.FocusLost = function(sender, args)
		searchFocus = false;
	end
	
	-- search button
	self.searchBtn = Turbine.UI.Lotro.Button();
	self.searchBtn:SetParent(self);
	self.searchBtn:SetText(Strings["ui_search"]);
	self.searchBtn:SetVisible( false );

	self.searchBtn.MouseClick = function(sender, args)
		self:SearchSongs();
	end
	
	-- clear search button
	self.clearBtn = Turbine.UI.Lotro.Button();
	self.clearBtn:SetParent(self);
	self.clearBtn:SetText(Strings["ui_clear"]);
	self.clearBtn:SetVisible( false );
	
	self.clearBtn.MouseClick = function(sender, args)
		self.searchInput:SetText("");
		self.songFileBrowser:ClearSearch()
	end
	
	
	self.instrumentSlotsPanel = InstrumentSlotsPanel(CharSettings)
	self.instrumentSlotsPanel:SetParent(self)
	self.instrumentSlotsPanel:SetZOrder(90)

	self.bShowReadyChars = ( Settings.ReadyColState )
	self.bHighlightReadyCol = ( Settings.ReadyColHighlight )

	-- initialize list items from song database
	self.libraryIsEmpty = (SongLibrary.librarySize == 0)
	self.emptyLabel = Turbine.UI.Label();
	self.emptyLabel:SetParent( self );
	self.emptyLabel:SetZOrder(LIST_OVERLAY_ZORDER)
	self.emptyLabel:SetText(Strings["err_nosongs"]);
	self.emptyLabel:SetVisible(false);
	local hasSongs = SongLibrary.librarySize ~= 0 and not SongDB.Songs[1].Realnames
	if not hasSongs then
		-- show message when library is empty or database format has changed
		self.sepSongsTracks:SetVisible( false );
		self.listFrame.heading:SetText( "" );
		self.emptyLabel:SetVisible(true);
	end
	
	-- window resize control
	self.resizeCtrl = Turbine.UI.Control();
	self.resizeCtrl:SetParent(self);
	self.resizeCtrl:SetZOrder(200);
                    
	self.resizeCtrl.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
		
	self.resizeCtrl.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.WindowPosition.Width = self:GetWidth();
	  Settings.WindowPosition.Height = self:GetHeight();
	end
	
	self.resizeCtrl.MouseMove = function(sender,args)
		if not sender.dragging then return end

		local width, height = self:GetSize()
		local screenWidth, screenHeight = Turbine.UI.Display.GetSize()
		width, height = MainWindowLayout.ClampWindowSize(
			width + args.X - sender.dragStartX,
			height + args.Y - sender.dragStartY,
			{
				left = self:GetLeft(),
				top = self:GetTop(),
				screenWidth = screenWidth,
				screenHeight = screenHeight,
				dirHeight = Settings.DirHeight,
				tracksVisible = Settings.TracksVisible,
				tracksHeight = Settings.TracksHeight,
			})
		self:SetSize(width, height)
		self:ReflowLayout()
	end -- resizeCtrl.MouseMove
	
	-- song list, track list ratio adjust
	self.sepSongsTracks.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
	
	self.sepSongsTracks.MouseUp = function(sender, args)
		sender.dragging = false
	end

	self.sepSongsTracks.MouseMove = function(sender, args)
		if sender.dragging then
			Settings.TracksHeight = MainWindowLayout.ClampTracksHeight(Settings.TracksHeight - args.Y + sender.dragStartY)
			self:ReflowLayout()
		end
	end
	
	self.footerBar = FooterBar()
	self.footerBar:SetParent(self)
	self.footerBar:SetZOrder(LIST_OVERLAY_ZORDER)
	self.footerBar.onRefreshClicked = function() self:ReloadSongDatabase() end
	self.footerBar.onSettingsClicked = function()
		settingsWindow:SetVisible(true)
		settingsWindow:Activate()
	end
	self.footerBar.onSyncInfoClicked = function()
		self.playerSyncInfoWindow:SetVisible(true)
		self.playerSyncInfoWindow:Activate()
	end

	-- action for closing window and saving position
	self.Closed = function( sender, args )
		self:SaveSettings();
		self:SetVisible( false );
	end
	
	if (Plugins[gPlugin] ~= nil ) then
		Plugins[gPlugin].Unload = function( sender, args )
			self:SaveSettings();
			SyncManager.Shutdown();
		end
	end

	self:CreateTimerUI( )

	self.filterPanel = FilterPanel( {
		none = self.chNone,
		ready = self.chReady,
		multiple = self.chMultiple,
		wrongPart = self.chWrongPart,
		wrongSong = self.chWrongSong,
	} )
	self.filterPanel:SetParent(self)
	self.filterPanel.onFiltersChanged = function() self:UpdateSongs() end
	self.filterPanel.onPlayersRefreshed = function() self:UpdateSetupColours() end
	self:CreateTreeViewPanels()

	if hasSongs then
		local songs = SongLibrary.GetSongsInDirectory(nil)
		if songs[1] then
			self:SelectSongByIndex(songs[1].index)
		else
			self:ClearSongState()
		end
	end

	SyncManager.onPlayerJoined = function(name) self.filterPanel:AddPlayer(name) end
	SyncManager.onPlayerLeft = function(name) self.filterPanel:RemovePlayer(name) end
	SyncManager.onChiefModeChanged = function(state)
		self.controlBar:SetSyncStartVisible(state)
	end
	SyncManager.onPlayerStateChanged = function()
		self:SetTrackColours(SongLibrary.selectedTrack)
		self.filterPanel:UpdatePlayerColours()
		self:UpdateSetupColours()
		self:PlayerSyncInfo()
	end
	SyncManager.onSyncMessage = function(songIndex, playerName, trackName)
		self:Update_syncMessage(songIndex, playerName, trackName)
	end
	SyncManager.onSongStarted = function(trackName)
		self:SongStarted()
	end
	SyncManager.onChatChannelChanged = function(channel, message)
		self.playerSyncPanel:SetChannelMessage(message)
	end
	SyncManager.onMaxPartCountChanged = function()
		self.filterPanel:UpdateMaxPartCount()
	end
	SyncManager.onSongStateCleared = function()
	end

	self.filterPanel:SetReadyColumnEnabled( self.bShowReadyChars )
	self.filterPanel:RefreshPlayers( ) -- lists the current party members; more will be added through chat messages

	self:ShowFilterUI( false );
	SyncManager.SetChiefMode( Settings.ChiefMode )
	self:HightlightReadyColumns( self.bHighlightReadyCol )
	
	-- adjust to search visibility
	if (not Settings.SearchVisible) then 
		self:ToggleSearch("off");
	end
	
	self:ReflowLayout()
end -- SongbookWindow:Constructor()

-- TODO: add complete set of checks
function SongbookWindow:ValidateWindowPosition( winPos )
	if winPos.Left < 0 or winPos.Top < 0 or winPos.Width < 0 or winPos.Height < 0 then
		winPos.Left = 700
		winPos.Top = 20
		winPos.Width = 342
		winPos.Height = 398
	end
end


function SongbookWindow:ActivateTimer( bActivate )
	self.songTimerPanel:SetTimerEnabled( bActivate )
end

function SongbookWindow:SetTimerCountdown( bCountdown )
	self.songTimerPanel:SetCountdown( bCountdown )
end

function SongbookWindow:CreateTimerUI( )
	self.songTimerPanel = SongTimerPanel()
	self.songTimerPanel:SetParent(self)
	self.songTimerPanel:SetZOrder(TIMER_ZORDER)
	self.songTimerPanel:SetTimerEnabled( Settings.TimerState )
	self.songTimerPanel:SetCountdown( Settings.TimerCountdown )
	self.songTimerPanel.onTimerText = function( text ) self.timerWindow:SetTimerText( text ) end
	self.songTimerPanel.onStopped = function() self.timerWindow:SetSongText( "" ) end
end

local function place(control, r)
	control:SetLeft(r.left)
	control:SetTop(r.top)
	control:SetWidth(r.width)
	control:SetHeight(r.height)
end

local function placeShown(control, r)
	control:SetVisible(r.visible)
	place(control, r)
end

function SongbookWindow:ReflowLayout()
	local width, height = self:GetSize()
	local layout = MainWindowLayout.Compute(width, height, {
		searchVisible = Settings.SearchVisible,
		tracksVisible = Settings.TracksVisible,
		tracksHeight = Settings.TracksHeight,
		filtersVisible = self.filterPanel:IsVisible(),
		filterWidth = FilterPanel.WIDTH,
		libraryEmpty = self.libraryIsEmpty,
		instrumentHeight = self.instrumentSlotsPanel:GetPreferredHeight(),
		instrumentPanelWidth = self.instrumentSlotsPanel:GetWidth(),
		instrumentPanelHeight = self.instrumentSlotsPanel:GetHeight(),
	})

	place(self.Version, layout.version)
	place(self.playerSyncPanel, layout.playerSync)
	place(self.tipLabel, layout.tooltip)
	place(self.controlBar, layout.controlBar)
	place(self.trackListPanel, layout.trackList)
	place(self.descriptionPanel, layout.description)

	placeShown(self.searchInput, layout.searchInput)
	placeShown(self.searchBtn, layout.searchButton)
	placeShown(self.clearBtn, layout.clearButton)

	place(self.listFrame, layout.listFrame)
	place(self.listFrame.heading, layout.listFrameHeading)
	place(self.listBackground, layout.listBackground)

	placeShown(self.songFileBrowser, layout.songBrowser)
	placeShown(self.sepSongsTracks, layout.separator)
	place(self.sepSongsTracks.heading, layout.separatorHeading)
	place(self.sArrows2, layout.separatorArrows)
	placeShown(self.trackDetailPanel, layout.trackDetail)

	-- filter panel keeps its own width
	local filter = layout.filterPanel
	self.filterPanel:SetPosition(filter.left, filter.top)
	self.filterPanel:SetHeight(filter.height)

	-- the timer shows itself while a song plays
	place(self.songTimerPanel, layout.timer)
	self.instrumentSlotsPanel:SetPosition(layout.instrumentSlots.left, layout.instrumentSlots.top)
	place(self.footerBar, layout.footer)
	placeShown(self.emptyLabel, layout.emptyLabel)
	place(self.resizeCtrl, layout.resizeCtrl)
end

function SongbookWindow:RefreshSongDatabaseView()
	self.libraryIsEmpty = (SongLibrary.librarySize == 0)
	self.emptyLabel:SetText(Strings["err_nosongs"])
	local searchText = self.searchInput:GetText()
	if searchText and searchText ~= "" then
		self.songFileBrowser:Search(searchText, self.filterPanel:GetFilters())
	else
		self.songFileBrowser:Populate()
	end

	self.trackListPanel:Clear()
	self.trackDetailPanel:Clear()
	self.descriptionPanel:Clear()
	self.playerSyncPanel:HideSyncMessage()
	SyncManager.ClearSongState()

	if self.libraryIsEmpty then
		self.listFrame.heading:SetText("")
		self.sepSongsTracks.heading:SetText(Strings["ui_parts"] .. " (0)")
		self.controlBar:ClearSongShortcuts()
	else
		local selectedIndex = SongLibrary.selectedSongIndex
		if not selectedIndex or not SongDB.Songs[selectedIndex] then selectedIndex = 1 end
		self:SelectSongByIndex(selectedIndex)
	end

	self:ReflowLayout()
end

function SongbookWindow:ReloadSongDatabase()
	self.footerBar:SetRefreshing(true)

	local started = SettingsManager.ReloadSongDatabase(function(success, databaseOrReason)
		self.footerBar:SetRefreshing(false)
		if not success then
			local key = databaseOrReason == "busy" and "err_refresh_busy" or "err_refresh_load"
			Turbine.Shell.WriteLine("<rgb=#FF0000>" .. Strings[key] .. "</rgb>")
			return
		end

		local replaced, reason = SongLibrary.ReplaceDatabase(databaseOrReason)
		if not replaced then
			Turbine.Shell.WriteLine("<rgb=#FF0000>" .. Strings[reason == "invalid" and "err_refresh_invalid" or "err_refresh_load"] .. "</rgb>")
			return
		end

		self:RefreshSongDatabaseView()
		Turbine.Shell.WriteLine("<rgb=#00FF00>" .. Strings["sh_refresh_success"] .. "</rgb>")
	end)

	if not started then
		self.footerBar:SetRefreshing(false)
	end
end


function SongbookWindow:IsAvailableTrackWithMatchingInstrument(songIdx, trackIdx, equippedInstrumentIdx)
	local readyState = SyncManager.GetTrackReadyState(songIdx, trackIdx);
	local Track_Name = SongDB.Songs[songIdx].Tracks[trackIdx].Name
	local Track_Instrument = InstrumentManager.FindInstrumentInTrack( Track_Name );
	local Track_Instrument_Index = Track_Instrument[0];
	local isRightIns = InstrumentManager.CompareInstrument(equippedInstrumentIdx, Track_Instrument_Index);
	return (readyState[0] == nil and isRightIns == 1);
end

function SongbookWindow:GetTrackToSelect(songIdx)
	local song = SongDB.Songs[songIdx]
	local equippedInstrumentIndex = self:UpdatePlayerTitle()

	-- Build the list of (listIndex, actualTrackIndex) pairs to search.
	local candidates = {}
	if SongLibrary.currentSetup and #SongLibrary.setupTrackIndices > 0 then
		for listIdx, actualIdx in ipairs(SongLibrary.setupTrackIndices) do
			candidates[#candidates + 1] = { listIdx = listIdx, trackIdx = actualIdx }
		end
	else
		for i = 1, #song.Tracks do
			candidates[#candidates + 1] = { listIdx = i, trackIdx = i }
		end
	end

	-- First pass: find an available track with a matching instrument.
	local firstFreeListIdx = 0
	for _, c in ipairs(candidates) do
		local readyState = SyncManager.GetTrackReadyState(songIdx, c.trackIdx)
		if readyState[0] == nil then
			if firstFreeListIdx == 0 then firstFreeListIdx = c.listIdx end
			local trackName = song.Tracks[c.trackIdx].Name
			local trackInstrument = InstrumentManager.FindInstrumentInTrack(trackName)
			if InstrumentManager.CompareInstrument(equippedInstrumentIndex, trackInstrument[0]) == 1 then
				return c.listIdx
			end
		end
	end

	-- No instrument match: fall back to the first free track.
	return firstFreeListIdx
end

-- SetTrackColours indexes rows by actual track index, so list every track
function SongbookWindow:PopulateSyncInfoList(songIndex)
	local texts = {}
	for i = 1, #SongDB.Songs[songIndex].Tracks do
		texts[i] = self:SyncInfoTrackText(songIndex, i)
	end
	self.playerSyncInfoWindow:SetTracks(texts)
end

function SongbookWindow:SyncInfoTrackText(songIndex, trackIndex)
	local track = SongDB.Songs[songIndex].Tracks[trackIndex]
	local instrument = InstrumentManager.FindInstrumentInTrack(SongLibrary.TerseTrackname(track.Name))
	return "[" .. track.Id .. "] " .. instrument[1]
end

-- ready players in green, wrong ones in red, synced-only in yellow
function SongbookWindow:SyncInfoPlayersText(readyState)
	local text = ""
	for i = 0, readyState[4] - 1 do
		local instrument = tonumber(readyState[3][i]) > 0 and InstrumentManager.GetName(tonumber(readyState[3][i])) or "No Instrument"
		text = text .. "  - <rgb=0x00FF00>" .. readyState[2][i] .. "</rgb> [<rgb=0x00FF80>" .. instrument .. "</rgb>]"
	end
	for i = 0, readyState[7] - 1 do
		local instrument = tonumber(readyState[6][i]) > 0 and InstrumentManager.GetName(tonumber(readyState[6][i])) or "No Instrument"
		text = text .. "  - <rgb=0xFF0000>" .. readyState[5][i] .. "</rgb> [<rgb=0xFF0080>" .. instrument .. "</rgb>]"
	end
	for i = 0, readyState[8] - 1 do
		text = text .. "  - <rgb=0xFFFF00>" .. readyState[9][i] .. "</rgb>"
	end
	return text
end

--%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:SearchSongs()
	self.songFileBrowser:Search(self.searchInput:GetText(), nil)
end

-- action for toggling search function on and off
function SongbookWindow:ToggleSearch(mode)
	if mode == "off" then
		Settings.SearchVisible = false
	elseif mode == "on" then
		Settings.SearchVisible = true
	else
		Settings.SearchVisible = not Settings.SearchVisible
	end
	if not Settings.SearchVisible and self.songFileBrowser then
		self.searchInput:SetText("")
		self.songFileBrowser:ClearSearch()
	end

	self:ReflowLayout()
end

function SongbookWindow:ToggleTracks()
	Settings.TracksVisible = not Settings.TracksVisible
	self:ReflowLayout()
end

-- action for toggling description on and off
function SongbookWindow:ToggleDescription()
	Settings.DescriptionVisible = not Settings.DescriptionVisible
	self.songFileBrowser:Populate()
end

function SongbookWindow:ToggleDescriptionFirst()
	Settings.DescriptionFirst = not Settings.DescriptionFirst
	if Settings.DescriptionVisible then
		self.songFileBrowser:Populate()
	end
end

function SongbookWindow:ToggleInstrSlots()
	self.instrumentSlotsPanel:SetSlotsVisible(not self.instrumentSlotsPanel:IsSlotsVisible())
	self:ReflowLayout()
end

function SongbookWindow:ClearSlots()
	self.instrumentSlotsPanel:ClearSlots()
end

function SongbookWindow:AddSlot()
	if self:GetWidth() > 10 + (CharSettings.InstrSlots[1]["number"] + 1) * 40 then
		self.instrumentSlotsPanel:AddSlot()
	end
end

function SongbookWindow:DelSlot()
	self.instrumentSlotsPanel:RemoveSlot()
end

function SongbookWindow:AddSlot_row()
	self.instrumentSlotsPanel:AddRow()
	self:ReflowLayout()
end

function SongbookWindow:DelSlot_row()
	self.instrumentSlotsPanel:RemoveRow()
	self:ReflowLayout()
end

function SongbookWindow:ExpandCmd(cmdId)
	local selTrack = SongLibrary.SelectedTrackIndex( );
	if SongLibrary.librarySize ~= 0 then
		local cmd = Settings.Commands[cmdId].Command;
		if SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[ selTrack ] then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[ selTrack ].Name);				
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[SongLibrary.selectedSongIndex].Filename);
			if (selTrack ~= 1) then
				cmd = string.gsub(cmd, "%%part", selTrack );
			else
				cmd = string.gsub(cmd, "%%part", "");
			end
		elseif SongDB.Songs[SongLibrary.selectedSongIndex].Filename then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[SongLibrary.selectedSongIndex].Filename);
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[SongLibrary.selectedSongIndex].Filename);	
			if (selTrack ~= 1) then
				cmd = string.gsub(cmd, "%%part", selTrack);
			else
				cmd = string.gsub(cmd, "%%part", "");
			end
		else 
			cmd = "";
		end
		return cmd;
	end
end

function SongbookWindow:SaveSettings()
	Settings.WindowPosition.Left = self:GetLeft()
	Settings.WindowPosition.Top = self:GetTop()
	Settings.WindowPosition.Width = self:GetWidth()
	Settings.WindowPosition.Height = self:GetHeight()
	Settings.FiltersState = self.filterPanel:IsVisible()
	Settings.ChiefMode = SyncManager.chiefMode
	Settings.TimerState = self.songTimerPanel:IsTimerEnabled()
	Settings.TimerCountdown = self.songTimerPanel:IsCountdown()
	Settings.ReadyColState = self.bShowReadyChars
	Settings.ReadyColHighlight = self.bHighlightReadyCol
	Settings.TimerWindowVisible = self.TimerWindowVisible
	Settings.HelpWindowDisable = self.HelpWindowDisable
	Settings.UseRaidChat = SyncManager.useRaidChat
	Settings.UseFellowshipChat = SyncManager.useFellowshipChat
	self.playerSyncInfoWindow:SavePosition()

	SettingsManager.Save()
end


function SongbookWindow:UpdateSongs()
	local sSearch = self.searchInput:GetText()
	if sSearch and sSearch ~= "" then
		self:SearchSongs()
	else
		self.songFileBrowser:Populate()
	end
end

function SongbookWindow:ClearSongState()
	SyncManager.ClearSongState()
	self:SetTrackColours(SongLibrary.selectedTrack)
	self.filterPanel:UpdatePlayerColours()
end

function SongbookWindow:SongStarted()
	self:ClearSongState()

	self.timerWindow:SetSongText( SyncManager.syncedTrackName )

	self.playerSyncPanel:HideSyncMessage()
	self.songMatchesWindow:SetVisible( false )

	self.syncConfirmWindow:SetPending( false )

	self.controlBar:SetSyncStartShortcut(nil)

	if self.songTimerPanel:HasInstrumentWarning() then
		self.songTimerPanel:ClearInstrumentWarning()
	end
	if self.songTimerPanel:IsTimerEnabled() then self.songTimerPanel:Start( SyncManager.syncedTrackName ) end
end

--%%%%%%%%%%%%%%%%

function SongbookWindow:CheckInstrument( sTrack )
	local player = Turbine.Gameplay.LocalPlayer:GetInstance( );
	if not player then return; end
	local equip = player:GetEquipment( )
	if not equip then return; end
	local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
	if not item then return; end
	sTrack = sTrack:lower()
	local instrumentOk = true -- only set to false if we can successfully determine track and equipped instrument
	local iName = InstrumentManager.GetInstrumentIndex( item:GetName( ):lower( ) )
	if not iName then return; end -- can't determine equipped instrument, disable message

	local iTrackInstrument, bOk = InstrumentManager.CheckTracksForInstrument( sTrack, iName, InstrumentManager.genericNames )
	if iTrackInstrument then
		instrumentOk = bOk
	else -- try localized names
		iTrackInstrument, bOk = InstrumentManager.CheckTracksForInstrument( sTrack, iName, aInstrumentsLoc )
		if iTrackInstrument then
			instrumentOk = bOk
		end
	end

	if not iTrackInstrument then return; end -- could not determine the track instrument
	if instrumentOk then
		self.songTimerPanel:ClearInstrumentWarning()
	else
		self.songTimerPanel:ShowInstrumentWarning( aInstrumentsLoc[ iTrackInstrument ] .. Strings["instr"] ) -- localized name
	end
end


function SongbookWindow:ShowFilterUI( bShow )
	self.filterPanel:SetVisible( bShow )
	self:ReflowLayout()
end

function SongbookWindow:ShowReadyColumns( bShow )
	if self.bShowReadyChars == bShow then return; end
	self.bShowReadyChars = bShow
	self.filterPanel:SetReadyColumnEnabled( bShow )
	if SongLibrary.selectedSongIndex then
		self:SetTrackColours( SongLibrary.selectedTrack );
		self.filterPanel:UpdatePlayerColours( );
	end
end

function SongbookWindow:HightlightReadyColumns( bOn )
	self.filterPanel:SetReadyHighlight( bOn )
end


function SongbookWindow:CreateTreeViewPanels()
	self.songFileBrowser = SongFileBrowser()
	self.songFileBrowser:SetParent(self)
	self.songFileBrowser.onSongSelected = function(songIndex)
		self:SelectSongByIndex(songIndex)
	end
	self.songFileBrowser.onNavigated = function()
		local dir = SongLibrary.selectedDir
		if string.len(dir) > 31 then
			dir = string.sub(dir, string.len(dir) - 30)
		end
		self.listFrame.heading:SetText(Strings["ui_dirs"] .. " (" .. dir .. ")")
	end
	self.songFileBrowser:SetVisible(true)
	self.songFileBrowser:Populate()

	self.trackDetailPanel = TrackDetailPanel()
	self.trackDetailPanel:SetParent(self)
	self.trackDetailPanel.onTrackSelected = function(listIndex)
		self:SelectTrack(listIndex)
	end
	self.trackDetailPanel.onSetupSelected = function(setupIndex)
		if Settings.AutoPickOnSongChange then
			local track = self:GetTrackToSelect(SongLibrary.selectedSongIndex)
			if track == 0 then track = 1 end
			self:SelectTrack(track)
		end
		self:SetTrackColours(SongLibrary.selectedTrack)
		self:UpdateSetupColours()
		local found = self.trackDetailPanel:GetTrackCount()
		self.sepSongsTracks.heading:SetText(Strings["ui_parts"] .. " (" .. found .. ")")
	end
	self.trackDetailPanel:SetVisible(Settings.TracksVisible)
end

function SongbookWindow:SelectSongByIndex(songIndex)
	SongLibrary.selectedSongIndex = songIndex
	SongLibrary.selectedSong = SongDB.Songs[songIndex].Filename

	self:PopulateSyncInfoList(songIndex)

	-- establishes the setup filter state that auto-pick reads
	self.trackDetailPanel:ShowSong(songIndex)

	self.songFileBrowser:SetSelectedSong(songIndex)

	-- Auto-pick after setup state is established by ShowSong.
	local track = 1
	if Settings.AutoPickOnSongChange then
		track = self:GetTrackToSelect(songIndex)
		if track == 0 then track = 1 end
	end

	self:ClearPlayerReadyStates()
	self:SelectTrack(track)
	self.filterPanel:UpdatePlayerColours()
	self:UpdateSetupColours()
	self:SetTrackColours(SongLibrary.selectedTrack)

	local found = self.trackDetailPanel:GetTrackCount()
	self.sepSongsTracks.heading:SetText(Strings["ui_parts"] .. " (" .. found .. ")")
end

function SongbookWindow:UpdateSetupColours(  )
	local song = SongDB.Songs[SongLibrary.selectedSongIndex]
	if not song or not song.Setups then return; end

	self:UpdateTrackReadyString( );

	local matchPattern;
	local antiMatchPattern;
	local matchLength = 0;
	local setupCount = #song.Setups

	for i = 1, setupCount do
		matchPattern = "[" .. song.Setups[ i ] .. "]";
		antiMatchPattern = "[^" .. song.Setups[ i ] .. "]";
		_, matchLength = string.gsub( SyncManager.readyTracks, matchPattern, " " )

		local colour
		if song.Setups[ i ] == SyncManager.readyTracks then
			colour = ColorTheme.colourReady;
		elseif string.match( SyncManager.readyTracks, antiMatchPattern ) then
			colour = Turbine.UI.Color( 0.7, 0, 0 );
		elseif matchLength and matchLength + 1 == #song.Setups[ i ] then
			colour = Turbine.UI.Color( 0, 0.7, 0 );
		else
			colour = ColorTheme.colourMessageTitle;
		end

		self.trackDetailPanel:SetSetupColour( i, colour )
	end
end

function SongbookWindow:UpdateTrackReadyString()
	SyncManager.UpdateReadyTracks(
		self.trackDetailPanel:GetTrackCount(),
		SongLibrary.SelectedTrackIndex
	)
end
		

function SongbookWindow:ClearPlayerReadyStates( )
	SyncManager.ClearPlayerReadyStates()
end

	
	
function SongbookWindow:CreateSeparator()
	local separator = Turbine.UI.Control()
	separator:SetParent(self)
	separator:SetZOrder(SEPARATOR_ZORDER)
	separator:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15))
	separator:SetVisible(false)
	return separator
end

function SongbookWindow:CreateSeparatorHeading(parent, sText)
	local heading = Turbine.UI.Label();
	heading:SetParent(parent);
	heading:SetLeft(0);
	heading:SetSize(100,13);
	heading:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
	heading:SetText(sText);
	heading:SetMouseVisible(false);
	return heading;
end

function SongbookWindow:CreateSeparatorArrows(parent)
	local arrows = Turbine.UI.Control();
	arrows:SetParent(parent);
	arrows:SetZOrder(310);
	arrows:SetBackground(gDir .. "arrows.tga");
	arrows:SetSize(20,10);
	arrows:SetPosition(parent:GetWidth( ) / 2 - 10, 1);
	arrows:SetMouseVisible( false );
	return arrows;
end

function SongbookWindow:AddScrollbar(parent,listbox,xPos,yPos)
	local scroll = Turbine.UI.Lotro.ScrollBar();
	scroll:SetParent( parent );
	scroll:SetOrientation( Turbine.UI.Orientation.Vertical );
	scroll:SetPosition( xPos, yPos )
	scroll:SetHeight( listbox:GetHeight() );
	scroll:SetZOrder(320);
	scroll:SetWidth(10);
	scroll:SetValue(0);
	listbox:SetVerticalScrollBar( scroll );
	scroll:SetVisible( false );
	return scroll;
end




--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- action for changing track selection (trackid is listbox index)
function SongbookWindow:SelectTrack( trackid )
	SongLibrary.selectedTrack = trackid;
	local iTrack = SongLibrary.SelectedTrackIndex( trackid );
	self.trackListPanel:SetSelectedTrack(trackid, self.trackDetailPanel:GetTrackCount())
	self.descriptionPanel:SetSong(SongLibrary.selectedSongIndex)

	self.controlBar:SetPlayShortcut(Strings["cmd_play"] .. " \"" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong .. "\" " .. SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id)
	self.controlBar:SetSyncSlotShortcut(Strings["cmd_play"] .. " \"" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong .. "\" " .. SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id .. " " .. Strings["cmd_sync"])
	self.controlBar:SetShareShortcut(self:ExpandCmd(Settings.DefaultCommand))
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self:PlayerSyncInfo();
	
	if not SyncManager.missingMatchedSong then
		self.playerSyncPanel:UpdateSyncVisibility()
	end
	
	self:SetTrackColours( SongLibrary.selectedTrack );
end

-- action for setting focus on the track list
function SongbookWindow:SetTrackColours( iSelectedTrack )
	if not self.trackDetailPanel or self.trackDetailPanel:GetTrackCount() < 1 then return; end
	self:ClearPlayerReadyStates( ); -- Clear ready states for currently displayed song
	local trackcount = #SongDB.Songs[SongLibrary.selectedSongIndex].Tracks;
	
	local numberOfCorrectStates = 0;
	for iTrack = 1,trackcount do
		if SongLibrary.currentSetup and not SongLibrary.setupListIndices[ iTrack ] then
			SyncManager.GetTrackReadyState( SongLibrary.selectedSongIndex, iTrack, 3 );
		else
			local iList = iTrack;
			if SongLibrary.setupListIndices[ iTrack ] then iList = SongLibrary.setupListIndices[ iTrack ]; end
			local readyState = SyncManager.GetTrackReadyState( SongLibrary.selectedSongIndex, iTrack );

			if readyState[0] == 10 then numberOfCorrectStates = numberOfCorrectStates + 1; end

			local fgCol = ColorTheme.GetColourForTrack( readyState[0], iList == iSelectedTrack )
			local bgCol = ColorTheme.GetBackColourForTrack( readyState[0], readyState[1], readyState[8] )
			self.trackDetailPanel:SetTrackColour( iList, fgCol, bgCol )
			local ch, bHL = self.chNone, false
			if readyState[0] == 0 then ch = self.chMultiple; bHL = true
			elseif readyState[0] then ch = self.chReady end
			self.trackDetailPanel:SetTrackReadyChar( iList, ch, bHL )

			local syncInfoText = self:SyncInfoTrackText(SongLibrary.selectedSongIndex, iTrack) .. self:SyncInfoPlayersText(readyState)
			self.playerSyncInfoWindow:UpdateTrack(iTrack, syncInfoText, fgCol, bgCol)
		end
	end
	
	if numberOfCorrectStates == trackcount then
		SyncManager.syncStartReady = true;
		self.controlBar:SetSyncStartShortcut(Strings["cmd_start"])
	else
		SyncManager.syncStartReady = false;
		self.syncConfirmWindow:SetPending(true)

		self.controlBar:SetSyncStartShortcut(nil)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- action for setting focus on the track list
function SongbookWindow:PlayerSyncInfo()
	if not self.controlBar then return 0; end

	local trackcount = #SongDB.Songs[SongLibrary.selectedSongIndex].Tracks;
	local Track_Name = SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[SongLibrary.selectedTrack].Name; 

	local equippedInstrument_Index = self:UpdatePlayerTitle();
	if equippedInstrument_Index == nil then return; end
	local Track_Instrument = InstrumentManager.FindInstrumentInTrack( Track_Name );
	local Track_Instrument_Index = Track_Instrument[0];
	local CorrectInstrument = InstrumentManager.CompareInstrument(equippedInstrument_Index, Track_Instrument_Index);
	if CorrectInstrument == 0 then
		SyncManager.correctInstrument = false;
		self.controlBar:SetSyncIconState(false)
	else
		SyncManager.correctInstrument = true;
		self.controlBar:SetSyncIconState(true)
	end

	-------------------------------------------------------

	local CorrectSongAndTrack = 1;
	if SongLibrary.selectedSongIndex ~= SyncManager.syncedSongIndex or SongLibrary.selectedTrack ~= SyncManager.syncedTrack then
		CorrectSongAndTrack = 0;
	end

	local Party = self.playerInstance:GetParty();
	local PartyMemberCount = 0;
	if Party ~= nil then PartyMemberCount = Party:GetMemberCount(); end


	if SyncManager.useFellowshipChat then
		SyncManager.chatChannel = "/f";
		self.playerSyncPanel:SetChannelMessage("SongBook is using Fellowship channel");
	else
	if SyncManager.useRaidChat then
		SyncManager.chatChannel = "/ra";
		self.playerSyncPanel:SetChannelMessage("SongBook is using Raid channel");
	else
		if SyncManager.userChatNumber ~= 0 and SyncManager.userChatNumber ~= nil then
			SyncManager.chatChannel = "/" .. SyncManager.userChatNumber;
			self.playerSyncPanel:SetChannelMessage("SongBook is using User Chat channel " .. SyncManager.userChatNumber .. " - " .. SyncManager.userChatName);
		else
			if PartyMemberCount > 6 or SyncManager.isRaid then
				SyncManager.chatChannel = "/ra";
				if not SyncManager.userChatBlocked then
					self.playerSyncPanel:SetChannelMessage("SongBook is using Raid channel");
				else
					self.playerSyncPanel:SetChannelMessage("Low level to use User chat. Now using Raid channel");
				end
			elseif PartyMemberCount > 1 then
				SyncManager.chatChannel = "/f";
				if not SyncManager.userChatBlocked then
					self.playerSyncPanel:SetChannelMessage("SongBook is using Fellowship channel");
				else
					self.playerSyncPanel:SetChannelMessage("Low level to use User chat. Now using Fellowship channel");
				end
			end
		end
	end
	end

	if CorrectSongAndTrack == 1 and SyncManager.localPlayerSynced then
		-- the 0 fills the retired list-index field so older clients still parse the message
		self.controlBar:SetSendSyncInfoShortcut(SyncManager.chatChannel .. " <rgb=#211f1d>@SBL|" .. self.Player_Name .. "|" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filename .. "|" .. Track_Name .. "|1|" .. CorrectSongAndTrack .. "|" .. trackcount .. "|0|" .. SongLibrary.selectedSongIndex .. "|" .. SongLibrary.selectedTrack .. "|" .. Track_Instrument_Index .. "|".. equippedInstrument_Index .. "|" .. CorrectInstrument .. "|</rgb>")
	else
		self.controlBar:SetSendSyncInfoShortcut("")
	end

	return equippedInstrument_Index;
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Activated(sender, args)

	self:UpdatePlayerTitle();
	
	local width, height = self:GetSize()
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize()
	local left, top, changed
	left, top, width, height, changed = Utils.ClampToDisplay(self:GetLeft(), self:GetTop(), width, height, displayWidth, displayHeight)

	Settings.WindowPosition.Left = left;
	Settings.WindowPosition.Top = top;
	Settings.WindowPosition.Width = width;
	Settings.WindowPosition.Height = height;

	if changed then
		self:SetPosition( left, top );
		self:SetSize( width, height );
		self:ReflowLayout();
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:UserChatNameChange( Text )
	SyncManager.SetUserChatName(Text)
	self.controlBar:SetJoinUserChatShortcut(SyncManager.userChatName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:UpdatePlayerTitle()
	local equippedIndex, instrumentName = InstrumentManager.GetEquippedInstrument()
	local player = Turbine.Gameplay.LocalPlayer:GetInstance()
	if not player then return end
	self.Player_Name = player:GetName()
	if not self.Player_Name then return end
	self.playerInstance = player

	if not equippedIndex then
		self.playerSyncPanel:SetPlayerText(self.Player_Name .. " - No Instrument Equipped")
		return
	end
	self.playerSyncPanel:SetPlayerText(self.Player_Name .. " - " .. instrumentName)
	return equippedIndex
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Update_syncMessage (SongIndex, PlayerName, TrackName)

	SyncManager.multipleSongsMatch = false;
	self.songMatchesWindow:SetVisible(false);

	if SongIndex[0] > 1 and not Settings.hideMatchedSongsPopup then
		SyncManager.missingMatchedSong = false;
		if PlayerName == SyncManager.localPlayerName then
		else
			--MatchedSongsIndex = SongIndex;
			SyncManager.multipleSongsMatch = true;
			self.playerSyncPanel:ShowSyncMessage(PlayerName .. "-> " .. TrackName .. " - Multiple songs match", SyncManager.otherPlayerSynced)

			local matches = {}
			for i = 1, SongIndex[0] do
				local song = SongDB.Songs[SongIndex[i]]
				matches[i] = { index = SongIndex[i], text = song.Filepath .. " " .. song.Filename }
			end
			self.songMatchesWindow:ShowMatches(matches)
		end
	elseif SongIndex[0] > 1 and Settings.hideMatchedSongsPopup then
		SyncManager.missingMatchedSong = false;
		local indexToSelect = 0;

		-- Check if any paths are exactly the current dir
		for i = 1, SongIndex[0] do
			if SongDB.Songs[SongIndex[i]].Filepath == SongLibrary.selectedDir then
				indexToSelect = i;
				break;
			end
		end

		-- Else check if any paths are a sub-path of the current dir
		if indexToSelect == 0 then
			for i = 1, SongIndex[0] do
				if SongLibrary.selectedDir == string.sub(SongDB.Songs[SongIndex[i]].Filepath, 1, #SongLibrary.selectedDir) then
					indexToSelect = i;
					break;
				end
			end
		end
		-- Else pick first path
		if indexToSelect == 0 then
			indexToSelect = 1;
		end

		SyncManager.otherPlayerSong.index = SongIndex[indexToSelect];

		SyncManager.otherPlayerSong.index = SongIndex[1];
		SyncManager.otherPlayerSong.filepath = SongDB.Songs[SyncManager.otherPlayerSong.index].Filepath;
		SyncManager.otherPlayerSong.filename = SongDB.Songs[SyncManager.otherPlayerSong.index].Filename;

		self.playerSyncPanel:ShowSyncMessage(PlayerName .. "-> " .. SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename, SyncManager.otherPlayerSynced)
		self.playerSyncPanel:UpdateSyncVisibility()
	elseif SongIndex[0] == 0 then
		self.playerSyncPanel:ShowSyncMessage("You don't have the same song. " .. PlayerName .. "-> " .. TrackName, SyncManager.otherPlayerSynced)
		SyncManager.missingMatchedSong = true;
	elseif SongIndex[0] == 1 then
		SyncManager.missingMatchedSong = false;

		SyncManager.otherPlayerSong.index = SongIndex[1];
		SyncManager.otherPlayerSong.filepath = SongDB.Songs[SyncManager.otherPlayerSong.index].Filepath;
		SyncManager.otherPlayerSong.filename = SongDB.Songs[SyncManager.otherPlayerSong.index].Filename;

		self.playerSyncPanel:ShowSyncMessage(PlayerName .. "-> " .. SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename, SyncManager.otherPlayerSynced)
		self.playerSyncPanel:UpdateSyncVisibility()
	end
end

function SongbookWindow:ToggleTimerWindow( State )
	self.TimerWindowVisible = State
	self.timerWindow:SetVisible( self.TimerWindowVisible )
end

function SongbookWindow:ToggleUseRaidChat( State )
	SyncManager.SetUseRaidChat(State)
	self:PlayerSyncInfo()
end

function SongbookWindow:ToggleUseFellowshipChat( State )
	SyncManager.SetUseFellowshipChat(State)
	self:PlayerSyncInfo()
end

function SongbookWindow:SetHelpWindowDisabled( State )
	self.HelpWindowDisable = State;
end

function SongbookWindow:ShowHelpWindow( )
	self.helpWindow:SetVisible(true)
end

function SongbookWindow:HelpWindow( )
	self.helpWindow:ShowOnFirstLoad(Settings.HelpWindowDisable)
end

function SongbookWindow:CreatePopupWindows()
	self.timerWindow = TimerWindow()
	self.timerWindow.onClicked = function() self:SetVisible(not self:IsVisible()) end

	self.helpWindow = HelpWindow(Settings.HelpWindowDisable)
	self.helpWindow.onDisabledChanged = function(disabled)
		self:SetHelpWindowDisabled(disabled)
		self:SaveSettings()
	end

	self.songMatchesWindow = SongMatchesWindow()
	self.songMatchesWindow.onSongChosen = function(songIndex)
		SongLibrary.NavigateToPath(SongDB.Songs[songIndex].Filepath)
		self.songFileBrowser:Populate()
		self:SelectSongByIndex(songIndex)
	end

	self.playerSyncInfoWindow = PlayerSyncInfoWindow(Settings.PlayersSyncInfoWindowPosition)
	self.syncConfirmWindow = SyncConfirmWindow()
end
