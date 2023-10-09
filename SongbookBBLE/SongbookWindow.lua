-- In The Name Of Allah --
-- Legendary Edition by Amin (Almiyan) - Crickhollow --

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SongbookWindow = class( Turbine.UI.Window );

selectedSong = ""; -- set the default song
selectedSongIndex = 1;
selectedTrack = 1;
selectedDir = "/"; -- set the default dir
dirPath = {}; -- table holding directory path
dirPath[1] = "/"; -- set first item as root dir
librarySize = 0;

ListBoxScrolled = class( Turbine.UI.ListBox ); -- Listbox with child scrollbar and separator
ListBoxCharColumn = class( ListBoxScrolled ) -- Listbox with single char column

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HelpWindow_Load_Flag = 1;
Synced_Song_TrackName = "";
SelectedMatchedSong_Index = 1;
--MatchedSongsIndex = {};
OtherPlayer_Synced = 1;
Multiple_songs_match_Synced = 0;
YouDontHaveTheSameSong_Flag = 0;
InstrumentSlots_Shift = 45;
OtherPlayer_SyncedSong_Filepath = "";
OtherPlayer_SyncedSong_Filename = "";
OtherPlayer_SyncedSong_Index = 1;
OtherPlayer_SyncedSong_IndexListBox = 1;
GroupIsRaid = 0;
PlayerCantUseUserChat_Message = 0;
UserChatName = "";
Chatchannel = "/f";
selectedSongIndexListBox = 0;
syncSlot_Correct_Instrument = 0;
ShiftTop = 50;
UserChatNumber = 0;
PlayerSynced = 0;
syncedSongIndex = -1;
syncedTrack = -1;

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- fix to prevent Vindar patch from messing up anything since it's not needed
SongbookLoad = Turbine.PluginData.Load;
SongbookSave = Turbine.PluginData.Save;

Settings = { WindowPosition = { Left = "300", Top = "20", Width = "700", Height = "700" + ShiftTop }, WindowVisible = "no", WindowOpacity="0.9", DirHeight = "100", TracksHeight = "150", TracksVisible = "yes", ToggleVisible = "yes", ToggleLeft = "10", ToggleTop = "10", ToggleOpacity = "1", SearchVisible = "yes", DescriptionVisible = "no", DescriptionFirst = "no", UserChatName = "" , PlayersSyncInfoWindowPosition = { Left = "350", Top = "100", Width = "400", Height = "300" } , 
Timer_WindowPosition = { Left = "50", Top = "1" } , TimerWindowVisible = "true" , UseRaidChat = "false", UseFellowshipChat = "false", 
HelpWindowDisable = "false" }; -- default values

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Help_Window = Turbine.UI.Lotro.Window();
Help_Window:SetZOrder(100);
Help_Window:SetSize( 410, 500 );
Help_Window:SetPosition( Turbine.UI.Display:GetWidth()/2-205, Turbine.UI.Display:GetHeight()/2-250 );
Help_Window:SetText( "Help" );
Help_Window:SetVisible( false );
Help_Window:SetOpacity(0.9);

Help_Frame = Turbine.UI.Control();
Help_Frame:SetParent(Help_Window);
Help_Frame:SetPosition(5,40);
Help_Frame:SetSize(400,420);
Help_Frame:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
Help_Frame:SetBackground(gDir .. "Help_window.tga");

--Help Window display checkbox
Help_Window_CB = Turbine.UI.Lotro.CheckBox();
Help_Window_CB:SetParent( Help_Window );
Help_Window_CB:SetPosition(50, 460 );
Help_Window_CB:SetSize(200,20);
Help_Window_CB:SetText(" Don't Show this again.");
Help_Window_CB:SetChecked(Settings.HelpWindowDisable == "true" );
Help_Window_CB.CheckedChanged = function(sender, args) songbookWindow:ToggleHelpWindow( sender:IsChecked( ) ); end;

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Timer_Window = Turbine.UI.Window();
--Timer_Window:SetBackColor(Turbine.UI.Color(0,0,0,0));
--Timer_Window:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
--Timer_Window:SetBackColorBlendMode(Turbine.UI.BlendMode.AlphaBlend);
Timer_Window:SetPosition(50,1);
--Timer_Window:SetBackground(gDir .. "BarBase2.tga");
Timer_Window_Width = 150;
Timer_Window_Height = 94;
Timer_Window:SetSize(Timer_Window_Width,Timer_Window_Height);
Timer_Window:SetOpacity(1);
Timer_Window:SetZOrder(100);
Timer_Window:SetVisible( true );

Timer_Frame = Turbine.UI.Control();
Timer_Frame:SetParent(Timer_Window);
Timer_Frame:SetPosition(0,0);
Timer_Frame:SetSize(150,94);
Timer_Frame:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
Timer_Frame:SetBackground(gDir .. "SongbookTimer.tga");

Timer_Label = Turbine.UI.Label( );
Timer_Label:SetParent(Timer_Window);
Timer_Label:SetMultiline( false );
Timer_Label:SetSize(150,40);
Timer_Label:SetPosition( 0, 9 );
Timer_Label:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold24 );
Timer_Label:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
Timer_Label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
Timer_Label:SetZOrder( 100 );
Timer_Label:SetVisible( true );
Timer_Label:SetText( "0:00" );

Song_Label = Turbine.UI.Label( );
Song_Label:SetParent(Timer_Window);
--Song_Label:SetMultiline( false );
Song_Label:SetSize(119,40);
Song_Label:SetPosition( 17, 37 );
Song_Label:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold18 );
Song_Label:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
Song_Label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
Song_Label:SetZOrder( 100 );
Song_Label:SetVisible( true );
--Song_Label:SetText( "Song" );

Click_Label = Turbine.UI.Label( );
Click_Label:SetParent(Timer_Window);
Click_Label:SetSize(150,94);
Click_Label:SetPosition( 0, 0 );
Click_Label:SetZOrder( 100 );
Click_Label:SetVisible( true );

Click_Label.MouseEnter = function(sender,args)
	--Timer_Frame:SetBackground("ChiranBBLE/SongbookBBLE/toggle_hover.tga");
	Timer_Window:SetOpacity(0.9);
end
Click_Label.MouseLeave = function(sender,args)
	--Timer_Frame:SetBackground("ChiranBBLE/SongbookBBLE/toggle.tga");
	Timer_Window:SetOpacity(1);
end		
Click_Label.MouseDown = function( sender, args )
	if(args.Button == Turbine.UI.MouseButton.Left) then
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
		sender.dragged = false;
		Timer_Window:SetBackColor( Turbine.UI.Color(0,0,1,0) );
	end
end
Click_Label.MouseUp = function( sender, args ) 
	if (args.Button == Turbine.UI.MouseButton.Left) then			
		if (sender.dragging) then
			sender.dragging = false;
		end
		if not sender.dragged then
			songbookWindow:SetVisible( not songbookWindow:IsVisible() );
		end
		Timer_Window:SetBackColor( Turbine.UI.Color(0,0,0,0) );
		Settings.ToggleLeft = Timer_Window:GetLeft();
		Settings.ToggleTop = Timer_Window:GetTop();			
	end
end
Click_Label.MouseMove = function(sender,args)
	if ( sender.dragging ) then
		local left, top = Timer_Window:GetPosition();
		Timer_Window:SetPosition( left + ( args.X - sender.dragStartX ), top + args.Y - sender.dragStartY );
		sender:SetPosition( 0, 0 );
		sender.dragged = true;
		-- checks to restrict moving outside the screen space
		if (Timer_Window:GetLeft() > Turbine.UI.Display.GetWidth() - 150) then
			Timer_Window:SetLeft(Turbine.UI.Display.GetWidth() - 150);				
		end
		if (Timer_Window:GetLeft() < 0) then
			Timer_Window:SetLeft(0);				
		end			
		if (Timer_Window:GetTop() > Turbine.UI.Display.GetHeight() - 94) then
			Timer_Window:SetTop(Turbine.UI.Display.GetHeight() - 94);				
		end
		if (Timer_Window:GetTop() < 0) then
			Timer_Window:SetTop(0);				
		end	
		
		Settings.Timer_WindowPosition.Left = Timer_Window:GetLeft();
		Settings.Timer_WindowPosition.Top  = Timer_Window:GetTop();
	end
end

-- Timer_Window = Turbine.UI.Lotro.Window();
-- Timer_Window:SetZOrder(100);
-- Timer_Window:SetSize( 100, 25 );
-- Timer_Window:SetPosition( 10, 10 );
-- Timer_Window:SetText( "Matched Songs" );
-- Timer_Window:SetVisible( true );
-- Timer_Window:SetOpacity(0.9);

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MatchedSongsWindow = Turbine.UI.Lotro.Window();
MatchedSongsWindow:SetZOrder(100);
MatchedSongsWindow:SetSize( 600, 300 );
MatchedSongsWindow:SetPosition( Turbine.UI.Display:GetWidth()/2-300, Turbine.UI.Display:GetHeight()/2-200 );
MatchedSongsWindow:SetText( "Matched Songs" );
MatchedSongsWindow:SetVisible( false );
MatchedSongsWindow:SetOpacity(0.9);
----------------------------------------------
MatchedSongsListbox = Turbine.UI.ListBox();
MatchedSongsListbox:SetParent( MatchedSongsWindow );
MatchedSongsListbox:SetPosition( 30, 50 );
MatchedSongsListbox:SetSize( MatchedSongsWindow:GetWidth() - 60 , MatchedSongsWindow:GetHeight() - 80  );
----------------------------------------------
MatchedSongsScrollBarV = Turbine.UI.Lotro.ScrollBar( );
MatchedSongsScrollBarV:SetParent( MatchedSongsWindow );
MatchedSongsScrollBarV:SetOrientation( Turbine.UI.Orientation.Vertical );
MatchedSongsScrollBarV:SetPosition(MatchedSongsListbox:GetLeft() + MatchedSongsListbox:GetWidth(), MatchedSongsListbox:GetTop());
MatchedSongsScrollBarV:SetSize(10,MatchedSongsListbox:GetHeight());
MatchedSongsScrollBarV:SetBackColor(Turbine.UI.Color(.1,.1,.1));
MatchedSongsScrollBarV:SetZOrder( 120 );
MatchedSongsScrollBarV:SetValue( 0 );
MatchedSongsListbox:SetVerticalScrollBar( MatchedSongsScrollBarV );
----------------------------------------------
MatchedSongsScrollBarH = Turbine.UI.Lotro.ScrollBar( );
MatchedSongsScrollBarH:SetParent( MatchedSongsWindow );
MatchedSongsScrollBarH:SetOrientation( Turbine.UI.Orientation.Horizontal );
MatchedSongsScrollBarH:SetPosition(MatchedSongsListbox:GetLeft(),MatchedSongsListbox:GetHeight() + MatchedSongsListbox:GetTop());
MatchedSongsScrollBarH:SetSize(MatchedSongsListbox:GetWidth(), 10);
MatchedSongsScrollBarH:SetBackColor(Turbine.UI.Color(.1,.1,.1));
MatchedSongsScrollBarH:SetZOrder( 120 );
MatchedSongsScrollBarH:SetValue( 0 );
MatchedSongsListbox:SetHorizontalScrollBar( MatchedSongsScrollBarH );


-- window resize control
MatchedSongsWindow.resizeCtrl = Turbine.UI.Control();
MatchedSongsWindow.resizeCtrl:SetParent(MatchedSongsWindow);
MatchedSongsWindow.resizeCtrl:SetSize(20,20);		
MatchedSongsWindow.resizeCtrl:SetZOrder(200);
MatchedSongsWindow.resizeCtrl:SetPosition(MatchedSongsWindow:GetWidth() - 20,MatchedSongsWindow:GetHeight() - 20); 
				
MatchedSongsWindow.resizeCtrl.MouseDown = function(sender,args)
  sender.dragStartX = args.X;
  sender.dragStartY = args.Y;
  sender.dragging = true;
end
	
MatchedSongsWindow.resizeCtrl.MouseUp = function(sender,args)
  sender.dragging = false;
  --Settings.PlayersSyncInfoWindowPosition.Width = MatchedSongsWindow:GetWidth();
  --Settings.PlayersSyncInfoWindowPosition.Height = MatchedSongsWindow:GetHeight();
end

MatchedSongsWindow.resizeCtrl.MouseMove = function(sender,args)
	local width, height = MatchedSongsWindow:GetSize();
	local gameDisplayWidth, gameDisplayHeight = Turbine.UI.Display.GetSize();
	
	if sender.dragging then
		
		width = width + args.X - sender.dragStartX;
		height = height + args.Y - sender.dragStartY;
		local WindowLeft = MatchedSongsWindow:GetLeft();
		local WindowTop  = MatchedSongsWindow:GetTop ();
		
		if width < 300 then width = 300; end
		if height < 200 then height = 200; end
		------------------------------------
		if WindowLeft + width  > gameDisplayWidth  then
		width  = gameDisplayWidth  - WindowLeft; end
		if WindowTop  + height > gameDisplayHeight then
		height = gameDisplayHeight - WindowTop ; end
		------------------------------------
		
		MatchedSongsWindow:SetSize( width, height );
		
		MatchedSongsListbox:SetSize( MatchedSongsWindow:GetWidth() - 60 , MatchedSongsWindow:GetHeight() - 80  );
		MatchedSongsScrollBarV:SetPosition(MatchedSongsListbox:GetLeft() + MatchedSongsListbox:GetWidth(), MatchedSongsListbox:GetTop());
		MatchedSongsScrollBarV:SetSize(10,MatchedSongsListbox:GetHeight());
		MatchedSongsScrollBarH:SetPosition(MatchedSongsListbox:GetLeft(),MatchedSongsListbox:GetHeight() + MatchedSongsListbox:GetTop());
		MatchedSongsScrollBarH:SetSize(MatchedSongsListbox:GetWidth(), 10);
	end
	
	sender:SetPosition( MatchedSongsWindow:GetWidth() - sender:GetWidth(), MatchedSongsWindow:GetHeight() - sender:GetHeight() );
end -- resizeCtrl.MouseMove


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PlayersSyncInfoWindow = Turbine.UI.Lotro.Window();
--PlayersSyncInfoWindow:SetZOrder(100);
PlayersSyncInfoWindow:SetSize( 400, 300 );
PlayersSyncInfoWindow:SetPosition( Turbine.UI.Display:GetWidth()/2-200, Turbine.UI.Display:GetHeight()/2-150 );
PlayersSyncInfoWindow:SetText( "Tracks Sync Info" );
PlayersSyncInfoWindow:SetVisible( false );
PlayersSyncInfoWindow:SetOpacity(0.9);

SyncInfolistbox = Turbine.UI.ListBox();
SyncInfolistbox:SetParent( PlayersSyncInfoWindow );
--SyncInfolistbox:SetBackColor( Turbine.UI.Color( 0.1, 0.1, 0.1 ) );
SyncInfolistbox:SetPosition( 30, 50 );
SyncInfolistbox:SetSize( PlayersSyncInfoWindow:GetWidth() - 60 , PlayersSyncInfoWindow:GetHeight() - 80  );

scrollBarV = Turbine.UI.Lotro.ScrollBar( );
scrollBarV:SetParent( PlayersSyncInfoWindow );
scrollBarV:SetOrientation( Turbine.UI.Orientation.Vertical );
scrollBarV:SetPosition(SyncInfolistbox:GetLeft() + SyncInfolistbox:GetWidth(), SyncInfolistbox:GetTop());
scrollBarV:SetSize(10,SyncInfolistbox:GetHeight());
scrollBarV:SetBackColor(Turbine.UI.Color(.1,.1,.1));
scrollBarV:SetZOrder( 120 );
scrollBarV:SetValue( 0 );
SyncInfolistbox:SetVerticalScrollBar( scrollBarV );
--scrollBarV:SetVisible( false );

scrollBarH = Turbine.UI.Lotro.ScrollBar( );
scrollBarH:SetParent( PlayersSyncInfoWindow );
scrollBarH:SetOrientation( Turbine.UI.Orientation.Horizontal );
scrollBarH:SetPosition(SyncInfolistbox:GetLeft(),SyncInfolistbox:GetHeight() + SyncInfolistbox:GetTop());
scrollBarH:SetSize(SyncInfolistbox:GetWidth(), 10);
scrollBarH:SetBackColor(Turbine.UI.Color(.1,.1,.1));
scrollBarH:SetZOrder( 120 );
scrollBarH:SetValue( 0 );
SyncInfolistbox:SetHorizontalScrollBar( scrollBarH );
--scrollBarH:SetVisible( false );

-- window resize control
PlayersSyncInfoWindow.resizeCtrl = Turbine.UI.Control();
PlayersSyncInfoWindow.resizeCtrl:SetParent(PlayersSyncInfoWindow);
PlayersSyncInfoWindow.resizeCtrl:SetSize(20,20);		
PlayersSyncInfoWindow.resizeCtrl:SetZOrder(200);
PlayersSyncInfoWindow.resizeCtrl:SetPosition(PlayersSyncInfoWindow:GetWidth() - 20,PlayersSyncInfoWindow:GetHeight() - 20); 
				
PlayersSyncInfoWindow.resizeCtrl.MouseDown = function(sender,args)
  sender.dragStartX = args.X;
  sender.dragStartY = args.Y;
  sender.dragging = true;
end
	
PlayersSyncInfoWindow.resizeCtrl.MouseUp = function(sender,args)
  sender.dragging = false;
  Settings.PlayersSyncInfoWindowPosition.Width = PlayersSyncInfoWindow:GetWidth();
  Settings.PlayersSyncInfoWindowPosition.Height = PlayersSyncInfoWindow:GetHeight();
end

PlayersSyncInfoWindow.resizeCtrl.MouseMove = function(sender,args)
	local width, height = PlayersSyncInfoWindow:GetSize();
	local gameDisplayWidth, gameDisplayHeight = Turbine.UI.Display.GetSize();
	
	if sender.dragging then
		
		width = width + args.X - sender.dragStartX;
		height = height + args.Y - sender.dragStartY;
		local WindowLeft = PlayersSyncInfoWindow:GetLeft();
		local WindowTop  = PlayersSyncInfoWindow:GetTop ();
		
		if width < 300 then width = 300; end
		if height < 200 then height = 200; end
		------------------------------------
		if WindowLeft + width  > gameDisplayWidth  then
		width  = gameDisplayWidth  - WindowLeft; end
		if WindowTop  + height > gameDisplayHeight then
		height = gameDisplayHeight - WindowTop ; end
		------------------------------------
		
		PlayersSyncInfoWindow:SetSize( width, height );
		
		SyncInfolistbox:SetSize( PlayersSyncInfoWindow:GetWidth() - 60 , PlayersSyncInfoWindow:GetHeight() - 80  );
		scrollBarV:SetPosition(SyncInfolistbox:GetLeft() + SyncInfolistbox:GetWidth(), SyncInfolistbox:GetTop());
		scrollBarV:SetSize(10,SyncInfolistbox:GetHeight());
		scrollBarH:SetPosition(SyncInfolistbox:GetLeft(),SyncInfolistbox:GetHeight() + SyncInfolistbox:GetTop());
		scrollBarH:SetSize(SyncInfolistbox:GetWidth(), 10);
	end
	
	sender:SetPosition( PlayersSyncInfoWindow:GetWidth() - sender:GetWidth(), PlayersSyncInfoWindow:GetHeight() - sender:GetHeight() );
end -- resizeCtrl.MouseMove

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SyncStartWindow = Turbine.UI.Lotro.Window();
SyncStartWindow:SetSize(300,185);
SyncStartWindow:SetPosition(Turbine.UI.Display:GetWidth()/2-100,Turbine.UI.Display:GetHeight()/2-100);
SyncStartWindow:SetText("Sync Start");
SyncStartWindow:SetZOrder(100);

SyncStartWindow.Message=Turbine.UI.Label();
SyncStartWindow.Message:SetParent(SyncStartWindow);
SyncStartWindow.Message:SetSize(280,50);
SyncStartWindow.Message:SetPosition(10,50);
SyncStartWindow.Message:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
SyncStartWindow.Message:SetText("Nothing to Start");


SyncStartWindow_ShowFlag = 1;

-- Yes button
--SyncStartWindow.YesSlot = SyncStartWindow:CreateMainShortcut(100);
SyncStartWindow.YesSlot = Turbine.UI.Lotro.Quickslot();
SyncStartWindow.YesSlot:SetParent(SyncStartWindow);
SyncStartWindow.YesSlot:SetPosition(80, 120);
SyncStartWindow.YesSlot:SetSize(35, 20);
SyncStartWindow.YesSlot:SetZOrder(100);
SyncStartWindow.YesSlot:SetAllowDrop(false);
SyncStartWindow.YesSlot:SetVisible( false );

SyncStartWindow.YesIcon = Turbine.UI.Control();
SyncStartWindow.YesIcon:SetParent( SyncStartWindow );
SyncStartWindow.YesIcon:SetPosition(80, 120);
SyncStartWindow.YesIcon:SetSize(35, 20);
SyncStartWindow.YesIcon:SetZOrder(110);
SyncStartWindow.YesIcon:SetMouseVisible(false);
SyncStartWindow.YesIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
SyncStartWindow.YesIcon:SetBackground(gDir .. "Yes.tga" );
SyncStartWindow.YesIcon:SetVisible( false );

SyncStartWindow.YesSlot.DragDrop =
function( sender, args )
	if( SyncStartWindow.YesSlotShortcut ) then
		SyncStartWindow.YesSlot:SetShortcut( SyncStartWindow.YesSlotShortcut ); -- restore shortcut
	end
end

SyncStartWindow.YesSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"] );
SyncStartWindow.YesSlot:SetShortcut( SyncStartWindow.YesSlotShortcut );
--SyncStartWindow.YesSlot:SetVisible( true );

-- SyncStartWindow.YesSlot.MouseClick = function(sender,args)	
	-- SyncStartWindow:SetVisible(false);
-- end

SyncStartWindow.YesSlot.MouseEnter = function(sender,args)
	SyncStartWindow.YesIcon:SetBackground(gDir .. "Yes_hover.tga");
end
SyncStartWindow.YesSlot.MouseLeave = function(sender,args)
	SyncStartWindow.YesIcon:SetBackground(gDir .. "Yes.tga");
end
SyncStartWindow.YesSlot.MouseDown = function(sender,args)
	SyncStartWindow.YesIcon:SetBackground(gDir .. "Yes_down.tga");
end
SyncStartWindow.YesSlot.MouseUp = function(sender,args)
	SyncStartWindow.YesIcon:SetBackground(gDir .. "Yes_hover.tga");
	SyncStartWindow:SetVisible(false);
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- No button
--SyncStartWindow.NoSlot = SyncStartWindow:CreateMainShortcut(100);
SyncStartWindow.NoSlot = Turbine.UI.Lotro.Quickslot();
SyncStartWindow.NoSlot:SetParent(SyncStartWindow);
SyncStartWindow.NoSlot:SetPosition(185, 120);
SyncStartWindow.NoSlot:SetSize(35, 20);
SyncStartWindow.NoSlot:SetZOrder(100);
SyncStartWindow.NoSlot:SetAllowDrop(false);
SyncStartWindow.NoSlot:SetVisible( false );

SyncStartWindow.NoIcon = Turbine.UI.Control();
SyncStartWindow.NoIcon:SetParent( SyncStartWindow );
SyncStartWindow.NoIcon:SetPosition(185, 120);
SyncStartWindow.NoIcon:SetSize(35, 20);
SyncStartWindow.NoIcon:SetZOrder(110);
SyncStartWindow.NoIcon:SetMouseVisible(false);
SyncStartWindow.NoIcon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
SyncStartWindow.NoIcon:SetBackground(gDir .. "No.tga" );
SyncStartWindow.NoIcon:SetVisible( false );

SyncStartWindow.NoSlot.DragDrop =
function( sender, args )
	if( SyncStartWindow.NoSlotShortcut ) then
		SyncStartWindow.NoSlot:SetShortcut( SyncStartWindow.NoSlotShortcut ); -- restore shortcut
	end
end

--SyncStartWindow.NoSlot.MouseClick = function(sender,args)	
	--SyncStartWindow:SetVisible(false);
--end

SyncStartWindow.NoSlot.MouseEnter = function(sender,args)
	SyncStartWindow.NoIcon:SetBackground(gDir .. "No_hover.tga");
end
SyncStartWindow.NoSlot.MouseLeave = function(sender,args)
	SyncStartWindow.NoIcon:SetBackground(gDir .. "No.tga");
end
SyncStartWindow.NoSlot.MouseDown = function(sender,args)
	SyncStartWindow.NoIcon:SetBackground(gDir .. "No_down.tga");
end
SyncStartWindow.NoSlot.MouseUp = function(sender,args)
	SyncStartWindow.NoIcon:SetBackground(gDir .. "No_hover.tga");
	SyncStartWindow:SetVisible(false);
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CharSettings = {
};

-- if (lang == "de" or lang == "fr") then	
	-- if (Turbine.Engine.GetLocale() == "de" or Turbine.Engine.GetLocale() == "fr") then
		-- Settings.WindowOpacity = "0,9";
	-- end
-- end
euroFormat=(tonumber("1,000")==1);
if euroFormat then
	Settings.WindowOpacity = "0,9";
	Settings.ToggleOpacity = "1";
end

SongDB = {
	Directories = {
	},
	Songs = {	
	}
};

function SongbookWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	SongDB = SongbookLoad( Turbine.DataScope.Account , "SongbookData") or SongDB;
	SettingsTemp = SongbookLoad( Turbine.DataScope.Account , gSettings) or Settings;
	if SettingsTemp.Timer_WindowPosition then
		Settings = SettingsTemp;
	end
	
	CharSettingsTemp = SongbookLoad( Turbine.DataScope.Character , gSettings) or CharSettings;
	if CharSettingsTemp.InstrSlots then 
		if CharSettingsTemp.InstrSlots[1] then
			CharSettings = CharSettingsTemp;
		end
	end
	
	-- Variables for filters and setups
	self.sFilterPartcount = nil -- A char for every acceptable part count, with 'A' being solo, 'B' two parts, etc.
	self.maxTrackCount = 25 -- Assumed maximum number of track setups (adjust if necessary):

	self.bFilter = false -- show/hide filter UI
	self.bChiefMode = true -- enables sync start shortcut, uses party object (seems to work for FS leader)
	self.bShowPlayers = true -- show/hide players listbox (used to auto-hide, but disabled for now)
	self.aFilteredIndices = { } -- Array for filtered indices, k = display index; v = SongDB index
	self.aPlayers = { } -- k = player name, v = ready track, 0 if no track ready
	self.aPlayers_sync_msg = { }
	self.nPlayers = 0 -- number of players (unfortunately not as simple as #self.aPlayers)
	self.aCurrentSongReady = { } -- k = player name; v = track ready state (see GetTrackReadyState())
	self.aReadyTracks = "" -- indicates which tracks are ready (A = 1st, B = 2nd, etc). Used for setup checks
	self.aSetupTracksIndices = { } -- when tracks are filtered for a setup, this array contains track indices
	self.aSetupListIndices = { } -- list index for tracks that are part of the currently selected setup
	self.iCurrentSetup = nil -- indicates which setup is currently selected
	self.selectedSetupCount = 'A' -- Stores the code of the current setup to select it on song change, if available
	self.maxPartCount = nil -- the number of parts to use as filter (nil if not filtering, else player count)
	self.alignTracksRight = false -- if true, track names are listed right-aligned (resize will reset to left aligned)
	self.listboxSetupsWidth = 20 -- width of the setups listbox (to the left of the tracks list)
	self.setupsWidth = self.listboxSetupsWidth + 10 -- total width of setup list including scrollbar
	self.bShowSetups = false -- show/hide setups (autohide for songs with no setups defined)
	
	
	self.Players_Data = { } ;
	self.TimerWindowVisible = true;
	self.UseRaidChat = false;
	self.UseFellowshipChat = false;
	self.HelpWindowDisable = false;
	
	-- colours for the different track/player ready states in the track and player listboxes
	self.colourDefaultHighlighted = Turbine.UI.Color( 1, 0.15, 0.95, 0.15 )
	self.colourReadyHighlighted = Turbine.UI.Color( 1, 0.40, 0.8, 0.15 )
	--self.colourReadyHighlighted = Turbine.UI.Color( 1, 0.15, 0.60, 0.15 )
	self.colourSyncedHighlighted = Turbine.UI.Color( 1, 1, 1, 0 )
	self.colourSyncedHighlighted_notSelected = Turbine.UI.Color( 1, 0.80, 0.80, 0.15 )
	self.colourReadyMultipleHighlighted = Turbine.UI.Color( 1, 0.7, 0.7, 1 )
	self.colourReadyMultipleHighlighted_synced = Turbine.UI.Color( 1, 0.7, 0.7, 0.80 )
	self.colourReadyMultipleHighlighted_synced_notSelected = Turbine.UI.Color( 1, 0.6, 0.6, 0.70 )
	self.colourDefault = Turbine.UI.Color( 1, 1, 1, 1 )
	--self.colourReady = Turbine.UI.Color( 1, 0.15, 0.70, 0 )
	--self.colourReady = Turbine.UI.Color( 1, 0.4, 0.8, 0.8 )
	self.colourReady = Turbine.UI.Color( 1, 0.4, 0.4, 0 )
	self.colourReadyMultiple = Turbine.UI.Color( 1, 0.6, 0.6, 0.95 )
	self.colourDifferentSong = Turbine.UI.Color( 1, 0, 0 )
	self.colourDifferentSetup = Turbine.UI.Color( 1, 0.6, 0 )
	self.colourWrongInstrument = Turbine.UI.Color( 1, 0.2, 0 )
	self.colourWrongInstrument_synced = Turbine.UI.Color( 1, 0.5, 0 )
	self.colourWrongInstrument_notSelected = Turbine.UI.Color( 1, 0.3, 0 )
	self.colourWrongInstrument_notSelected_synced = Turbine.UI.Color( 1, 0.6, 0 )
	self.colourWrongInstrumentMultiple = Turbine.UI.Color( 1, 0.4, 0.9 )
	self.colourReadyMultiple2 = Turbine.UI.Color( 1, 0.4, 0.9 )
	self.colourWrongInstrumentMultiple_notSelected = Turbine.UI.Color( 1, 0.1, 0.9 )
	self.colourWrongInstrumentMultiple_synced = Turbine.UI.Color( 1, 0.6, 1 )
	self.colourWrongInstrumentMultiple_synced_notSelected = Turbine.UI.Color( 1, 0.5, 1 )
	self.backColourDefault = Turbine.UI.Color( 1, 0, 0, 0 )
	self.backColourHighlight = Turbine.UI.Color( 1, 0.1, 0.1, 0.1 )
	self.backColourHighlight_self = Turbine.UI.Color( 1, 0.1, 0.15, 0.1 )
	self.backColourHighlight_wrong = Turbine.UI.Color( 1, 0.15, 0.15, 0.1 )
	self.backColourHighlight_Multiple = Turbine.UI.Color( 1, 0.15, 0.15, 0.2 )
	self.backColourHighlight_Multiple_synced = Turbine.UI.Color( 1, 0.15, 0.15, 0.15 )
	self.backColourWrongInstrument = Turbine.UI.Color( 1, 0.15	, 0.1, 0.1 )
	self.backColourWrongInstrument_ready = Turbine.UI.Color( 1, 0.2, 0.1, 0.1 )
	
	self.backColour_synced = Turbine.UI.Color( 1, 0.1, 0.1, 0 )
	self.backColour_synced_multiple = Turbine.UI.Color( 1, 0.1, 0.1, 0.15 )
	
	self.colourMessageTitle = Turbine.UI.Color( 1, 0.8, 0.8, 0 )
	self.colour_syncMessageTitle = Turbine.UI.Color( 1, 0, 1, 1 )
	self.colour_syncMessageTitle_OnlySynced = Turbine.UI.Color( 1, 1, 1, 0 )
	self.colour_syncMessageTitle_Back = Turbine.UI.Color( 1, 0.1, 0.2, 0.2 )
	self.colour_syncMessageTitle_Highlighted = Turbine.UI.Color( 1, 0, 0.8, 1 )
	self.colour_syncMessageTitle_Highlighted_OnlySynced = Turbine.UI.Color( 1, 1, 0.8, 0 )
	self.colour_syncMessageTitle_MouseDown = Turbine.UI.Color( 1, 0, 0.8, 0.8 )
	self.colour_syncMessageTitle_MouseDown_OnlySynced = Turbine.UI.Color( 1, 0.8, 0.8, 0 )
	
	
	self.bCheckInstrument = true
	self.bInstrumentOk = true
	self.aInstruments = { "bagpipe", "clarinet", "cowbell", "drum", "flute", "harp", "horn", "lute", "pibgorn", "theorbo"  }
	
	self.Instruments_List = { "Basic Harp", "Misty Mountain Harp", "Basic Lute", "Lute of Ages", "Basic Theorbo", "Traveller's Trusty Fiddle", "Bardic Fiddle", "Basic Fiddle", "Lonely Mountain Fiddle", "Sprightly Fiddle", "Student's Fiddle", "Basic Bagpipe", "Basic Bassoon", "Brusque Bassoon", "Lonely Mountain Bassoon", "Basic Clarinet", "Basic Flute", "Basic Horn", "Basic Pibgorn", "Basic Cowbell", "Moor Cowbell", "Basic Drum" }
	
	self.Instruments_Names_inTrack = {
	{"Basic Harp"}, -- 1
	{"Misty Mountain Harp", "Misty Harp", "MM Harp", "MMH", "Mountain Harp", "Mountains Harp"}, -- 2
	{"Basic Lute", "New Lute", "LuteB", "BLute", "B Lute"}, -- 3
	{"Lute of Ages", "Lute of Age", "Age Lute", "Ages Lute", "LuteA", "LOA", "Lute OA"}, -- 4
	{"Basic Theorbo", "Theorbo", " Theo "}, -- 5
	{"Traveller's Trusty Fiddle", "Traveller's Fiddle", "Travellers Fiddle", "Traveller Fiddle", "Traveler Fiddle", "Trusty Fiddle", "TT Fiddle", "TTF"}, -- 6
	{"Bardic Fiddle"}, -- 7
	{"Basic Fiddle", "B Fiddle", "BFiddle"}, -- 8
	{"Lonely Mountain Fiddle", "Lonely Fiddle", "LM Fiddle", "LMFiddle", "LMF", "Mountain Fiddle", "Mountains Fiddle"}, -- 9
	{"Sprightly Fiddle", "Spright Fiddle"}, -- 10
	{"Student's Fiddle", "Students Fiddle", "Student Fiddle"}, -- 11
	{"Basic Bagpipe", "Bagpipe", "Bag pipe"}, -- 12
	{"Basic Bassoon"}, -- 13
	{"Brusque Bassoon", "Brusk Bassoon"}, -- 14
	{"Lonely Mountain Bassoon", "Lonely Bassoon", "LM Bassoon", "Mountain Bassoon", "Mountains Bassoon"}, -- 15
	{"Basic Clarinet", "Clarinet"}, -- 16
	{"Basic Flute", "Flute"}, -- 17
	{"Basic Horn", "Horn"}, -- 18
	{"Basic Pibgorn", "Pibgorn"}, -- 19
	{"Basic Cowbell"}, -- 20
	{"Moor Cowbell", "More Cowbell"}, -- 21
	{"Basic Drum", "Drum"}  } -- 22
	
	self.aSpecialInstruments = { }
	self.aSpecialInstruments[ "satakieli" ] = 6 -- index in the insturments array
	self.bTimer = true
	self.bTimerCountdown = true
	
	self.bShowReadyChars = true
	self.bHighlightReadyCol = true
	self.chNone = " "
	self.chReady = "~"
	self.chWrongSong = "S"
	self.chWrongPart = "P"
	self.chMultiple = "M"
	
	-- Legacy fixes
	
	if not CharSettings.UserChatNumber then CharSettings.UserChatNumber = 0; end
	if not CharSettings.InstrumentSlots_Rows then CharSettings.InstrumentSlots_Rows = 1; end
	
	if not Settings.UserChatName then
		Settings.UserChatName = "";
	end
	-- if not Settings.PlayersSyncInfoWindowPosition.Left then Settings.PlayersSyncInfoWindowPosition.Left = 350 end
	-- if not Settings.PlayersSyncInfoWindowPosition.Top then Settings.PlayersSyncInfoWindowPosition.Top = 100 end
	-- if not Settings.PlayersSyncInfoWindowPosition.Width then Settings.PlayersSyncInfoWindowPosition.Width = 400 end
	-- if not Settings.PlayersSyncInfoWindowPosition.Height then Settings.PlayersSyncInfoWindowPosition.Height = 300 end
	
	
	if not Settings.DirHeight then
		Settings.DirHeight = "100";
	end
	if not Settings.TracksHeight then
		Settings.TracksHeight = "150";
	end
	if not Settings.TracksVisible then
		Settings.TracksVisible = "yes";
	end
	if not WindowVisible then
		WindowVisible = "no";
	end	
	if not Settings.SearchVisible then
		Settings.SearchVisible = "yes";	
	end
	if not Settings.DescriptionVisible then
		Settings.DescriptionVisible = "no";	
	end
	if not Settings.DescriptionFirst then
		Settings.DescriptionFirst = "no";	
	end
	
	if not Settings.ToggleOpacity then
		Settings.ToggleOpacity = 1;
	end		

	if not Settings.FiltersState then Settings.FiltersState = "false"; end		
	if not Settings.ChiefMode then Settings.ChiefMode = "true"; end		
	if not Settings.TimerState then Settings.TimerState = "true"; end
	if not Settings.TimerCountdown then Settings.TimerCountdown = "true"; end		
 	if not Settings.ReadyColState then Settings.ReadyColState = "true"; end
 	if not Settings.ReadyColHighlight then Settings.ReadyColHighlight = "true"; end
	
 	if not Settings.TimerWindowVisible then Settings.TimerWindowVisible = "true"; end
	self:ToggleTimerWindow( Settings.TimerWindowVisible == "true" )
	
	if not Settings.HelpWindowDisable then Settings.HelpWindowDisable = "false"; end
	self:ToggleHelpWindow( Settings.HelpWindowDisable == "true" )
	Help_Window_CB:SetChecked(Settings.HelpWindowDisable == "true" );
	
	if not Settings.UseRaidChat       then Settings.UseRaidChat 	  = "false"; end
	if not Settings.UseFellowshipChat then Settings.UseFellowshipChat = "false"; end
	self:ToggleUseRaidChat	    ( Settings.UseRaidChat 	     == "true" )
	self:ToggleUseFellowshipChat( Settings.UseFellowshipChat == "true" )
	
	if not SongDB.Songs then
		SongDB = {
			Directories = {
			},
			Songs = {	
			}
		};
	end		
	
	if not Settings.Commands then
		Settings.Commands = {};		
		Settings.Commands["1"] = { Title = Strings["cmd_demo1_title"], Command = Strings["cmd_demo1_cmd"] };
		Settings.Commands["2"] = { Title = Strings["cmd_demo2_title"], Command = Strings["cmd_demo2_cmd"] };
		Settings.Commands["3"] = { Title = Strings["cmd_demo3_title"], Command = Strings["cmd_demo3_cmd"] };
		Settings.DefaultCommand = "1";
	end

	CharSettings.InstrumentSlots_Rows = tonumber(CharSettings.InstrumentSlots_Rows);
	
	if not CharSettings.InstrSlots then
		CharSettings.InstrSlots = {};
		for j = 1, CharSettings.InstrumentSlots_Rows do
			table.insert(CharSettings.InstrSlots , {});
			CharSettings.InstrSlots[j]["visible"] = "yes";
			CharSettings.InstrSlots[j]["number"] = 11;
			for i = 1, CharSettings.InstrSlots[j]["number"] do
				CharSettings.InstrSlots[j][tostring(i)] = { qsType = "", qsData = "" };		
			end
		end
	end
	for j = 1, CharSettings.InstrumentSlots_Rows do
		if not CharSettings.InstrSlots[j]["number"] then
			CharSettings.InstrSlots[j]["number"] = 11;
		end
	end
	for j = 1, CharSettings.InstrumentSlots_Rows do
		for i = 1, CharSettings.InstrSlots[j]["number"] do
			CharSettings.InstrSlots[j][tostring(i)].qsType = tonumber(CharSettings.InstrSlots[j][tostring(i)].qsType);
		end	
	end
	
	UserChatName = string.lower ( Settings.UserChatName );
	
	-- unstringify settings
	Settings.WindowPosition.Left = tonumber(Settings.WindowPosition.Left);
	Settings.WindowPosition.Top = tonumber(Settings.WindowPosition.Top);
	Settings.WindowPosition.Width = tonumber(Settings.WindowPosition.Width);
	Settings.WindowPosition.Height = tonumber(Settings.WindowPosition.Height);
	self:ValidateWindowPosition( Settings.WindowPosition )
	Settings.ToggleTop = tonumber(Settings.ToggleTop);
	Settings.ToggleLeft = tonumber(Settings.ToggleLeft);
	Settings.DirHeight = tonumber(Settings.DirHeight);
	Settings.TracksHeight = tonumber(Settings.TracksHeight);
	Settings.WindowOpacity = tonumber(Settings.WindowOpacity);
	Settings.ToggleOpacity = tonumber(Settings.ToggleOpacity);
	for j = 1, CharSettings.InstrumentSlots_Rows do
		CharSettings.InstrSlots[j]["number"] = tonumber(CharSettings.InstrSlots[j]["number"]);
	end
	
	Settings.PlayersSyncInfoWindowPosition.Left = tonumber(Settings.PlayersSyncInfoWindowPosition.Left);
	Settings.PlayersSyncInfoWindowPosition.Top = tonumber(Settings.PlayersSyncInfoWindowPosition.Top);
	Settings.PlayersSyncInfoWindowPosition.Width = tonumber(Settings.PlayersSyncInfoWindowPosition.Width);
	Settings.PlayersSyncInfoWindowPosition.Height = tonumber(Settings.PlayersSyncInfoWindowPosition.Height);
	
	Settings.Timer_WindowPosition.Left = tonumber(Settings.Timer_WindowPosition.Left);
	Settings.Timer_WindowPosition.Top = tonumber(Settings.Timer_WindowPosition.Top);
	
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
	
--------------------------------------------------------------------------
	if Settings.PlayersSyncInfoWindowPosition.Width + 0 > displayWidth then
		Settings.PlayersSyncInfoWindowPosition.Width = displayWidth - 0;
	end
	if Settings.PlayersSyncInfoWindowPosition.Height + 0 > displayHeight then
		Settings.PlayersSyncInfoWindowPosition.Height = displayHeight - 0;
	end
	if Settings.PlayersSyncInfoWindowPosition.Left + Settings.PlayersSyncInfoWindowPosition.Width > displayWidth then
		Settings.PlayersSyncInfoWindowPosition.Left = displayWidth - Settings.PlayersSyncInfoWindowPosition.Width;
	end
	if Settings.PlayersSyncInfoWindowPosition.Top + Settings.PlayersSyncInfoWindowPosition.Height > displayHeight then
		Settings.PlayersSyncInfoWindowPosition.Top = displayHeight - Settings.PlayersSyncInfoWindowPosition.Height;
	end
	if Settings.PlayersSyncInfoWindowPosition.Left < 0 then
		Settings.PlayersSyncInfoWindowPosition.Left = 0;
	end
	if Settings.PlayersSyncInfoWindowPosition.Top < 0 then
		Settings.PlayersSyncInfoWindowPosition.Top = 0;
	end
--------------------------------------------------------------------------
	
--------------------------------------------------------------------------
	if Settings.Timer_WindowPosition.Left + Timer_Window_Width > displayWidth then
		Settings.Timer_WindowPosition.Left = displayWidth - Timer_Window_Width;
	end
	if Settings.Timer_WindowPosition.Top + Timer_Window_Height > displayHeight then
		Settings.Timer_WindowPosition.Top = displayHeight - Timer_Window_Height;
	end
	if Settings.Timer_WindowPosition.Left < 0 then
		Settings.Timer_WindowPosition.Left = 0;
	end
	if Settings.Timer_WindowPosition.Top < 0 then
		Settings.Timer_WindowPosition.Top = 0;
	end
--------------------------------------------------------------------------

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
				
				if PlayersSyncInfoWindow:IsVisible() then
					PlayersSyncInfoWindowWasVisible = true;
					PlayersSyncInfoWindow:SetVisible(false);					
				else
					PlayersSyncInfoWindowWasVisible = false;
				end
				
				if Timer_Window:IsVisible() then
					Timer_WindowWasVisible = true;
					Timer_Window:SetVisible(false);					
				else
					Timer_WindowWasVisible = false;
				end
			else
				hideUI = false;
				if wasVisible then
					self:SetVisible(true);
					self:Activate();
				end
				if (Settings.ToggleVisible == "yes") then
					toggleWindow:SetVisible(true);
				end
				
				if settingsWindowWasVisible then
					settingsWindow:SetVisible(true);
					settingsWindow:Activate();					
				end
				if PlayersSyncInfoWindowWasVisible then
					PlayersSyncInfoWindow:SetVisible(true);	
					PlayersSyncInfoWindow:Activate();
				end
				if Timer_WindowWasVisible then
					Timer_Window:SetVisible(true);	
					Timer_Window:Activate();
				end
			end
		
		------------------------------------------------------
		
		--elseif (args.Action == 268435635) then
			
		end
	end
	
	librarySize = #SongDB.Songs;
	
	self:SetPosition( Settings.WindowPosition.Left, Settings.WindowPosition.Top );
	self:SetSize( Settings.WindowPosition.Width, Settings.WindowPosition.Height );
	--self:SetZOrder(10);
	
	PlayersSyncInfoWindow:SetPosition( Settings.PlayersSyncInfoWindowPosition.Left, Settings.PlayersSyncInfoWindowPosition.Top );
	PlayersSyncInfoWindow:SetSize( Settings.PlayersSyncInfoWindowPosition.Width, Settings.PlayersSyncInfoWindowPosition.Height );
	SyncInfolistbox:SetSize( PlayersSyncInfoWindow:GetWidth() - 60 , PlayersSyncInfoWindow:GetHeight() - 80  );
	scrollBarV:SetPosition(SyncInfolistbox:GetLeft() + SyncInfolistbox:GetWidth(), SyncInfolistbox:GetTop());
	scrollBarV:SetSize(10,SyncInfolistbox:GetHeight());
	scrollBarH:SetPosition(SyncInfolistbox:GetLeft(),SyncInfolistbox:GetHeight() + SyncInfolistbox:GetTop());
	scrollBarH:SetSize(SyncInfolistbox:GetWidth(), 10);
	PlayersSyncInfoWindow.resizeCtrl:SetPosition(PlayersSyncInfoWindow:GetWidth() - 20,PlayersSyncInfoWindow:GetHeight() - 20);
	
	Timer_Window:SetPosition( Settings.Timer_WindowPosition.Left, Settings.Timer_WindowPosition.Top );
	
	self:SetOpacity( Settings.WindowOpacity );
	--self:SetText("Songbook " .. Plugins[gPlugin]:GetVersion() .. Strings["title"] );
	self:SetText("Songbook " .. "2" .. Strings["title"] );
	
	self.Version = Turbine.UI.Label();
	self.Version:SetParent( self );
	self.Version:SetFont(Turbine.UI.Lotro.Font.Verdana12);
	self.Version:SetForeColor( self.colourMessageTitle );
	self.Version:SetPosition( 40, 25 );
	self.Version:SetSize(50, 14);
	self.Version:SetText("V" .. Plugins[gPlugin]:GetVersion());
	
	self.minWidth = 461;
	self.minHeight = 308;
	self.lFXmod = 23; -- listFrame x coord modifier
	self.lCXmod = 28; -- listContainer x coord modifier (original value was 42)

	if (CharSettings.InstrSlots[1]["visible"] == "yes") then
		self.lFYmod = 214 + ShiftTop + InstrumentSlots_Shift * ( CharSettings.InstrumentSlots_Rows - 1 ); -- listFrame     y coord modifier = difference between bottom pixels and window bottom
		self.lCYmod = 233 + ShiftTop + InstrumentSlots_Shift * ( CharSettings.InstrumentSlots_Rows - 1 ); -- listContainer y coord modifier = difference between bottom pixels and window bottom
	else
		self.lFYmod = 169 + ShiftTop + 0 * ( CharSettings.InstrumentSlots_Rows - 1 ) ; -- listFrame     y coord modifier = difference between bottom pixels and window bottom
		self.lCYmod = 188 + ShiftTop + 0 * ( CharSettings.InstrumentSlots_Rows - 1 ) ; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	end
	
	-- Frame for the song list
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.listFrame:SetPosition(12, 134 + ShiftTop);
	--self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod);
	self.listContainer = Turbine.UI.Control();
	self.listContainer:SetParent( self );
	self.listContainer:SetBackColor( Turbine.UI.Color(1,0,0,0) );
	self.listContainer:SetPosition(18, 147 + ShiftTop);
	--self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod);

	-- outer frame title
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft(5);
	self.listFrame.heading:SetSize(self.listFrame:GetWidth(),13);
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_dirs"] );
	
	-- separator1 between dir list and song list
	self.separator1 = self:CreateMainSeparator( Settings.DirHeight );
	self.separator1:SetVisible(true);
	-- separator1 title
	self.separator1.heading = self:CreateSeparatorHeading( self.separator1, Strings["ui_songs"] );
	-- separator1 hint arrows
	self.sArrows1 = self:CreateSeparatorArrows( self.separator1 )
	
	-- separator2 between song list and track list
	self.sepSongsTracks = self:CreateMainSeparator( self.listContainer:GetHeight() - Settings.TracksHeight - 13 );
	-- separator2 title
	self.sepSongsTracks.heading = self:CreateSeparatorHeading( self.sepSongsTracks, Strings["ui_parts"] );
	-- separator2 hint arrows
	self.sArrows2 = self:CreateSeparatorArrows( self.sepSongsTracks )

	-- Tooltip
	self.tipLabel = Turbine.UI.Label();
	self.tipLabel:SetParent( self );
	self.tipLabel:SetPosition( self:GetWidth() - 270, 27 + ShiftTop);
	self.tipLabel:SetSize(245, 30);
	self.tipLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.tipLabel:SetText("");
	
	-- Music mode button
	self.musicSlot = self:CreateMainShortcut(20);
	-- Trying to fix the problem with unresponsive buttons. Haven't found out yet how to disable
	-- dragging from a quickslot altogether, so for now this just restores the shortcut.
	self.musicSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_music"]);
	self.musicSlot.DragDrop =
	function( sender, args )
		if( self.musicSlotShortcut ) then
			self.musicSlot:SetShortcut( self.musicSlotShortcut ); -- restore shortcut
		end
	end
	self.musicSlot:SetShortcut( self.musicSlotShortcut );
	self.musicSlot:SetVisible( true );
	
	-- Play button
	self.playSlot = self:CreateMainShortcut(60);
	self.playSlot.DragDrop =
	function( sender, args )
		if( self.playSlotShortcut ) then
			self.playSlot:SetShortcut( self.playSlotShortcut ); -- restore shortcut
		end
	end
	
	-- Ready check button
	self.readySlot = self:CreateMainShortcut(120);
	self.readySlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_ready"]));
	
	-- Sync play button
	self.syncSlot = self:CreateMainShortcut(161);
	self.syncSlot.DragDrop =
	function( sender, args )
		if( self.syncSlotShortcut ) then
			self.syncSlot:SetShortcut( self.syncSlotShortcut ); -- restore shortcut
		end
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	-- send sync info button
	self.sendSyncInfoSlot = self:CreateMainShortcut(202);
	self.sendSyncInfoSlot.DragDrop =
	function( sender, args )
		if( self.sendSyncInfoSlotShortcut ) then
			self.sendSyncInfoSlot:SetShortcut( self.sendSyncInfoSlotShortcut ); -- restore shortcut
		end
	end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- Start sync play button
	self.syncStartSlot = self:CreateMainShortcut(287);
	--self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"] );
	self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined , "" );
	self.syncStartSlot.DragDrop =
	function( sender, args )
		if( self.syncStartSlotShortcut ) then
			self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut ); -- restore shortcut
		end
	end
	self.syncStartSlot:SetShortcut(self.syncStartSlotShortcut);
	
	-- Share button
	self.shareSlot = self:CreateMainShortcut(328);
	if (Settings.Commands[Settings.DefaultCommand]) then
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- List Channels button
	self.listchannelsSlot = self:CreateMainShortcut(369);
	self.listchannelsSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/listchannels" );
	self.listchannelsSlot.DragDrop =
	function( sender, args )
		if( self.listchannelsSlotShortcut ) then
			self.listchannelsSlot:SetShortcut( self.listchannelsSlotShortcut ); -- restore shortcut
		end
	end
	self.listchannelsSlot:SetShortcut( self.listchannelsSlotShortcut );
	self.listchannelsSlot:SetVisible( true );
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	-- Join User Chat button
	self.joinUserChatSlot = self:CreateMainShortcut(410);
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. UserChatName );
	self.joinUserChatSlot.DragDrop =
	function( sender, args )
		if( self.joinUserChatSlotShortcut ) then
			self.joinUserChatSlot:SetShortcut( self.joinUserChatSlotShortcut ); -- restore shortcut
		end
	end
	self.joinUserChatSlot:SetShortcut( self.joinUserChatSlotShortcut );
	self.joinUserChatSlot:SetVisible( true );
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Track label
	self.trackLabel = Turbine.UI.Label();
	self.trackLabel:SetParent( self );
	self.trackLabel:SetPosition(247, 63 + ShiftTop);
	self.trackLabel:SetSize(30, 12);
	self.trackLabel:SetZOrder(200);
	self.trackLabel:SetText("X:");

	-- Track number
	self.trackNumber = Turbine.UI.Label();
	self.trackNumber:SetParent( self );
	self.trackNumber:SetPosition(262, 63 + ShiftTop);
	self.trackNumber:SetWidth(20);
	
	-- Track up arrow
	self.trackPrev = Turbine.UI.Control();
	self.trackPrev:SetParent( self );
	self.trackPrev:SetPosition(252, 51 + ShiftTop);
	self.trackPrev:SetSize(12, 8);
	self.trackPrev:SetBackground(gDir .. "arrowup.tga");
	self.trackPrev:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackPrev:SetVisible( false );
	
	-- Track down arrow
	self.trackNext = Turbine.UI.Control();
	self.trackNext:SetParent( self );
	self.trackNext:SetPosition(252, 78 + ShiftTop);
	self.trackNext:SetSize(12, 8);
	self.trackNext:SetBackground(gDir .. "arrowdown.tga");
	self.trackNext:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackNext:SetVisible( false );
	
	-- actions for track change
	self.trackPrev.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:SelectTrack(selectedTrack - 1);
		end
	end
	self.trackNext.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:SelectTrack(selectedTrack + 1);
		end
	end
		
	-- actions for button mouse hovers
	self.musicSlot.MouseEnter = function(sender,args)
		self.musicIcon:SetBackground(gDir .. "icn_m_hover.tga");
		self.tipLabel:SetText(Strings["tt_music"]);
	end
	self.musicSlot.MouseLeave = function(sender,args)
		self.musicIcon:SetBackground(gDir .. "icn_m.tga");
		self.tipLabel:SetText("");
	end
	self.musicSlot.MouseDown = function(sender,args)
		self.musicIcon:SetBackground(gDir .. "icn_m_down.tga");
	end
	self.musicSlot.MouseUp = function(sender,args)
		self.musicIcon:SetBackground(gDir .. "icn_m_hover.tga");
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	self.playSlot.MouseEnter = function(sender,args)
		self.playIcon:SetBackground(gDir .. "icn_p_hover.tga");
		self.tipLabel:SetText(Strings["tt_play"]);
	end
	self.playSlot.MouseLeave = function(sender,args)
		self.playIcon:SetBackground(gDir .. "icn_p.tga");
		self.tipLabel:SetText("");
	end
	self.playSlot.MouseDown = function(sender,args)
		self.playIcon:SetBackground(gDir .. "icn_p_down.tga");
	end
	self.playSlot.MouseUp = function(sender,args)
		self.playIcon:SetBackground(gDir .. "icn_p_hover.tga");
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	self.readySlot.MouseEnter = function(sender,args)
		self.readyIcon:SetBackground(gDir .. "icn_r_hover.tga");
		self.tipLabel:SetText(Strings["tt_ready"]);
	end
	self.readySlot.MouseLeave = function(sender,args)
		self.readyIcon:SetBackground(gDir .. "icn_r.tga");
		self.tipLabel:SetText("");
	end
	self.readySlot.MouseDown = function(sender,args)
		self.readyIcon:SetBackground(gDir .. "icn_r_down.tga");
	end
	self.readySlot.MouseUp = function(sender,args)
		self.readyIcon:SetBackground(gDir .. "icn_r_hover.tga");
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	self.syncSlot.MouseEnter = function(sender,args)
		self.syncIcon:SetBackground(gDir .. "icn_s_hover.tga");
		self.tipLabel:SetText(Strings["tt_sync"]);
	end
	self.syncSlot.MouseLeave = function(sender,args)
		if syncSlot_Correct_Instrument == 1 then
			self.syncIcon:SetBackground(gDir .. "icn_s.tga");
		elseif syncSlot_Correct_Instrument == 0 then
			self.syncIcon:SetBackground(gDir .. "icn_s_f.tga");
		end
		self.tipLabel:SetText("");
	end
	self.syncSlot.MouseDown = function(sender,args)
		self.syncIcon:SetBackground(gDir .. "icn_s_down.tga");
	end
	self.syncSlot.MouseUp = function(sender,args)
		self.syncIcon:SetBackground(gDir .. "icn_s_hover.tga");
	end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	self.syncSlot.MouseClick = function(sender,args)
		
		PlayerCantUseUserChat_Message = 0;
		syncedSongIndex = selectedSongIndex;
		syncedTrack = selectedTrack;
		PlayerSynced = 0;
		self:PlayerSyncInfo();
	end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	self.sendSyncInfoSlot.MouseEnter = function(sender,args)
		self.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_hover.tga");
		self.tipLabel:SetText("Send Sync Info");
	end
	self.sendSyncInfoSlot.MouseLeave = function(sender,args)
		self.sendSyncInfoIcon:SetBackground(gDir .. "icn_send.tga");
		self.tipLabel:SetText("");
	end
	self.sendSyncInfoSlot.MouseDown = function(sender,args)
		self.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_down.tga");
	end
	self.sendSyncInfoSlot.MouseUp = function(sender,args)
		self.sendSyncInfoIcon:SetBackground(gDir .. "icn_send_hover.tga");
	end
	
	self.sendSyncInfoSlot.MouseClick = function(sender,args)
		
		PlayerCantUseUserChat_Message = 0;
		self:PlayerSyncInfo();
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	self.listchannelsSlot.MouseEnter = function(sender,args)
		self.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_hover.tga");
		self.tipLabel:SetText("Recover User Channel");
	end
	self.listchannelsSlot.MouseLeave = function(sender,args)
		self.listchannelsIcon:SetBackground(gDir .. "icn_listchannel.tga");
		self.tipLabel:SetText("");
		
		--self:PlayerSyncInfo();
	end
	self.listchannelsSlot.MouseDown = function(sender,args)
		self.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_down.tga");
	end
	self.listchannelsSlot.MouseUp = function(sender,args)
		self.listchannelsIcon:SetBackground(gDir .. "icn_listchannel_hover.tga");
	end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	self.joinUserChatSlot.MouseEnter = function(sender,args)
		self.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_hover.tga");
		self.tipLabel:SetText("Join Songbook User Channel");
	end
	self.joinUserChatSlot.MouseLeave = function(sender,args)
		self.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel.tga");
		self.tipLabel:SetText("");
	end
	self.joinUserChatSlot.MouseDown = function(sender,args)
		self.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_down.tga");
	end
	self.joinUserChatSlot.MouseUp = function(sender,args)
		self.joinUserChatIcon:SetBackground(gDir .. "icn_joinchannel_hover.tga");
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	self.syncStartSlot.MouseEnter = function(sender,args)
		self.syncStartIcon:SetBackground(gDir .. "icn_ss_hover.tga");
		self.tipLabel:SetText(Strings["tt_start"]);
	end
	self.syncStartSlot.MouseLeave = function(sender,args)
		self.syncStartIcon:SetBackground(gDir .. "icn_ss.tga");
		self.tipLabel:SetText("");
	end
	self.syncStartSlot.MouseDown = function(sender,args)
		self.syncStartIcon:SetBackground(gDir .. "icn_ss_down.tga");
	end
	self.syncStartSlot.MouseUp = function(sender,args)
		self.syncStartIcon:SetBackground(gDir .. "icn_ss_hover.tga");
	end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	self.syncStartSlot.MouseClick = function(sender,args)
		
		if SyncStartWindow_ShowFlag == 1 then
			SyncStartWindow:SetVisible(true);
			SyncStartWindow:Activate();
		end
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self.shareSlot.MouseEnter = function(sender,args)
		self.shareIcon:SetBackground(gDir .. "icn_sh_hover.tga");
		if (Settings.Commands[Settings.DefaultCommand].Title) then
			self.tipLabel:SetText(Settings.Commands[Settings.DefaultCommand].Title);
		end
	end
	self.shareSlot.MouseLeave = function(sender,args)
		self.shareIcon:SetBackground(gDir .. "icn_sh.tga");
		self.tipLabel:SetText("");
	end
	self.shareSlot.MouseDown = function(sender,args)
		self.shareIcon:SetBackground(gDir .. "icn_sh_down.tga");
	end
	self.shareSlot.MouseUp = function(sender,args)
		self.shareIcon:SetBackground(gDir .. "icn_sh_hover.tga");
	end
------------------------------------------------------------------------------------------

	self.shareSlot.MouseWheel = function(sender,args)
		local nextCmd = tonumber(Settings.DefaultCommand) - args.Direction;
		local size = SettingsWindow:CountCmds();
		
		if (nextCmd == 0) then
			Settings.DefaultCommand = tostring(size);		
		elseif (nextCmd > size) then
			Settings.DefaultCommand = "1";		
		else
			Settings.DefaultCommand = tostring(nextCmd);		
		end
		
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
		self.shareSlot:SetVisible(true);
	end
	self.trackLabel.MouseClick = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ToggleTracks();
		end
	end
	
	-- icons that hide default quick slots
	self.musicIcon = self:CreateMainIcon(20,"icn_m");
	self.playIcon = self:CreateMainIcon(60,"icn_p");
	self.readyIcon = self:CreateMainIcon(120,"icn_r");
	self.syncIcon = self:CreateMainIcon(161,"icn_s");
	self.sendSyncInfoIcon = self:CreateMainIcon(202,"icn_send");
	self.syncStartIcon = self:CreateMainIcon(287,"icn_ss");
	self.shareIcon = self:CreateMainIcon(328,"icn_sh");
	self.listchannelsIcon = self:CreateMainIcon(369,"icn_listchannel");
	self.joinUserChatIcon = self:CreateMainIcon(410,"icn_joinchannel");
	
	-- selected song display
	self.songTitle = Turbine.UI.Label();
	self.songTitle:SetParent( self );
	self.songTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.songTitle:SetForeColor( self.colourDefaultHighlighted );	
	self.songTitle:SetPosition( 23, 90 + ShiftTop);
	self.songTitle:SetSize( self:GetWidth() - 52, 16);
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Player Name and Instrument display
	self.PlayerTitle = Turbine.UI.Label();
	self.PlayerTitle:SetParent( self );
	self.PlayerTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.PlayerTitle:SetForeColor( self.colourDefaultHighlighted );
	self.PlayerTitle:SetPosition( 15, 30 );
	self.PlayerTitle:SetSize(self:GetWidth() - 30, 16);
	self.PlayerTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	self.PlayerTitle:SetText("");
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self:UpdatePlayerTitle();
	
	self.playerEquipment.ItemEquipped = function(sender, args)
		self:PlayerSyncInfo();
	end
	
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Songbook Messages display
	self.MessageTitle = Turbine.UI.Label();
	self.MessageTitle:SetParent( self );
	self.MessageTitle:SetFont(Turbine.UI.Lotro.Font.Verdana12);
	self.MessageTitle:SetForeColor( self.colourMessageTitle );
	self.MessageTitle:SetPosition( 23, 50 );
	self.MessageTitle:SetSize(self:GetWidth() - 30, 14);
	--self.MessageTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	
	CharSettings.UserChatNumber = tonumber(CharSettings.UserChatNumber);
	UserChatNumber = CharSettings.UserChatNumber;
	if UserChatNumber ~= 0 and UserChatNumber ~= nil then
		Chatchannel = "/" .. UserChatNumber;
		self.MessageTitle:SetText("SongBook is using User Chat channel " .. UserChatNumber .. " - " .. UserChatName);
	else
		self.MessageTitle:SetText("SongBook is using Fellowship channel");
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Synced song Messages display
	self.syncMessageTitle = Turbine.UI.Label();
	self.syncMessageTitle:SetParent( self );
	self.syncMessageTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
	self.syncMessageTitle:SetBackColor( self.backColourHighlight );
	self.syncMessageTitle:SetPosition( 23, 70 );
	self.syncMessageTitle:SetSize(self:GetWidth() - 30, 16);
	--self.syncMessageTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	--self.syncMessageTitle:SetText("");
	self.syncMessageTitle:SetVisible(false);
	
	self.syncMessageTitle.MouseEnter = function(sender, args)
		if self.syncMessageTitle:IsVisible() then
			if OtherPlayer_Synced == 0 then
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_Highlighted );
			else
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_Highlighted_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseLeave = function(sender, args)
		if self.syncMessageTitle:IsVisible() then
			if OtherPlayer_Synced == 0 then
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseDown = function(sender,args)
		if self.syncMessageTitle:IsVisible() then
			if OtherPlayer_Synced == 0 then
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_MouseDown );
			else
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_MouseDown_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseUp = function(sender,args)
		if self.syncMessageTitle:IsVisible() then
			if OtherPlayer_Synced == 0 then
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
			end
			if Multiple_songs_match_Synced == 1 then
				MatchedSongsWindow:SetVisible( true );
			elseif YouDontHaveTheSameSong_Flag == 0 then
				self:SelectDir( nil, OtherPlayer_SyncedSong_Filepath );
				self:SelectSong(OtherPlayer_SyncedSong_IndexListBox);
				local selectedItem = self.songlistBox:GetItem( OtherPlayer_SyncedSong_IndexListBox )
				if selectedItem then selectedItem:SetForeColor( self.colourDefaultHighlighted ); end
			end
		end
	end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- search field
	self.searchInput = Turbine.UI.Lotro.TextBox();
	self.searchInput:SetParent(self);
	self.searchInput:SetPosition(17, 110 + ShiftTop);
	self.searchInput:SetSize(150, 20);
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
	self.searchBtn:SetPosition(172, 110 + ShiftTop);
	self.searchBtn:SetSize(80, 20);
	self.searchBtn:SetText(Strings["ui_search"]);
	self.searchBtn:SetVisible( false );

	self.searchBtn.MouseClick = function(sender, args)
		self:SearchSongs();
	end
	
	-- clear search button
	self.clearBtn = Turbine.UI.Lotro.Button();
	self.clearBtn:SetParent(self);
	self.clearBtn:SetPosition(255, 110 + ShiftTop);
	self.clearBtn:SetSize(70, 20);
	self.clearBtn:SetText(Strings["ui_clear"]);
	self.clearBtn:SetVisible( false );
	
	self.clearBtn.MouseClick = function(sender, args)
		self.searchInput:SetText("");
		self.songlistBox:ClearItems();
		self:LoadSongs();
		self:SelectSong(1);
	end
	
	-- hide search components if not toggled
	if (Settings.SearchVisible == "yes") then
		self.searchInput:SetVisible( true );
		self.searchBtn:SetVisible( true );
		self.clearBtn:SetVisible( true );				
	end

	-- directory list box
	self.dirlistBox = ListBoxScrolled:New( 10 );
	self.dirlistBox:SetParent( self.listContainer );
	self.dirlistBox:SetVisible( true );
	
	-- track list box
	self.tracklistBox = ListBoxCharColumn:New( 10, 20 );
	self.tracklistBox:SetParent( self.listContainer );
	
	self:AdjustTracklistLeft( );
	-- show track components if toggled
	self:ShowTrackListbox( Settings.TracksVisible == "yes" )
	
	
	-- main song list box
	self.songlistBox = ListBoxScrolled:New( 10 );
	self.songlistBox:SetParent( self.listContainer );
	self.songlistBox:SetVisible( true );
	self.songlistBox:SetVisible( true );
	
	
	-- instrument slot containers
	self.instrContainer = {};
	
	for j = 1, CharSettings.InstrumentSlots_Rows do
		self.instrContainer[j] = Turbine.UI.Control();
		self.instrContainer[j]:SetParent( self );
		local TopShift = 75 + InstrumentSlots_Shift * ( j - 1 );
		self.instrContainer[j]:SetPosition( 10, self:GetHeight() - TopShift );
		if (CharSettings.InstrSlots[1]["visible"] == "yes") then
			self.instrContainer[j]:SetVisible( true );
		else
			self.instrContainer[j]:SetVisible( false );
		end
		self.instrContainer[j]:SetSize( 40*CharSettings.InstrSlots[j]["number"], 38 );
		self.instrContainer[j]:SetZOrder(90);
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	-- self.instrContainer.MouseClick = function(sender,args)
		
		-- local player = Turbine.Gameplay.LocalPlayer:GetInstance( );
		-- if not player then return; end
		-- local equip = player:GetEquipment( )
		-- if not equip then return; end
		-- local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
		-- if not item then return; end
		-- local equippedInstrument = item:GetName( )
		-- if not equippedInstrument then return; end

		-- local Player_Name = player:GetName();
		-- if not Player_Name then return; end

		-- self.PlayerTitle:SetText(Player_Name .. " - " .. equippedInstrument);
	-- end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	-- instrument slots
	self.instrSlot = { };
	
	local instrdrag = false;
	
	for j = 1, CharSettings.InstrumentSlots_Rows do
		table.insert(self.instrSlot , {});
		for i = 1, CharSettings.InstrSlots[j]["number"] do
			self.instrSlot[j][i] = Turbine.UI.Lotro.Quickslot();
			self.instrSlot[j][i]:SetParent( self.instrContainer[j] );
			self.instrSlot[j][i]:SetPosition(40*(i-1), 0);
			self.instrSlot[j][i]:SetSize(37, 37);
			self.instrSlot[j][i]:SetZOrder(100);
			self.instrSlot[j][i]:SetAllowDrop(true);
			
			if (CharSettings.InstrSlots[j][tostring(i)].data ~= "") then
				pcall(function() 
					local sc = Turbine.UI.Lotro.Shortcut( CharSettings.InstrSlots[j][tostring(i)].qsType, CharSettings.InstrSlots[j][tostring(i)].qsData);
					self.instrSlot[j][i]:SetShortcut(sc);
				end);
			end
			
			self.instrSlot[j][i].ShortcutChanged = function( sender, args )
				pcall(function() 
					local sc = sender:GetShortcut();
					CharSettings.InstrSlots[j][tostring(i)].qsType = tostring(sc:GetType());
					CharSettings.InstrSlots[j][tostring(i)].qsData = sc:GetData();
				end);
			end
			
			self.instrSlot[j][i].DragLeave = function( sender, args )
				if (instrdrag) then 
					CharSettings.InstrSlots[j][tostring(i)].qsType ="";
					CharSettings.InstrSlots[j][tostring(i)].qsData = "";
					local sc = Turbine.UI.Lotro.Shortcut( "", "");
					self.instrSlot[j][i]:SetShortcut(sc);
					instrdrag = false;
				end
			end
			
			self.instrSlot[j][i].MouseDown = function( sender, args )
				
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
				-- local player = Turbine.Gameplay.LocalPlayer:GetInstance( );
				-- if not player then return; end
				-- local equip = player:GetEquipment( )
				-- if not equip then return; end
				-- local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
				-- if not item then return; end
				-- local equippedInstrument = item:GetName( )
				-- if not equippedInstrument then return; end

				-- local Player_Name = player:GetName();
				-- if not Player_Name then return; end

				-- self.PlayerTitle:SetText(Player_Name .. " - " .. equippedInstrument);
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				if(args.Button == Turbine.UI.MouseButton.Left) then	
					instrdrag = true;
				end
			end
		end
	end
	
	self.bTimer = ( Settings.TimerState == "true" )
	self.bTimerCountdown = ( Settings.TimerCountdown == "true" )
	self.bShowReadyChars = ( Settings.ReadyColState == "true" )
	self.bHighlightReadyCol = ( Settings.ReadyColHighlight == "true" )
	self.tracklistBox:EnableCharColumn( self.bShowReadyChars )

	-- initialize list items from song database
	if (librarySize ~= 0 and not SongDB.Songs[1].Realnames) then
		
		for i = 1, #SongDB.Directories do
			local dirItem = Turbine.UI.Label();
			local _, dirLevel = string.gsub(SongDB.Directories[i], "/", "/");
			if (dirLevel == 2) then				
				dirItem:SetText(string.sub(SongDB.Directories[i],2));			
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );				
				self.dirlistBox:AddItem( dirItem );
			end
		end
		
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" );
		
		if (self.dirlistBox:ContainsItem(1)) then
			local dirItem = self.dirlistBox:GetItem(1);
			dirItem:SetForeColor( self.colourDefaultHighlighted );
		end
		
		-- load content to song list box
		self:LoadSongs();
		
		-- set first item as initial selection
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then
			self.songlistBox:SetSelectedIndex( 1 )
			self:SelectSong( 1 );
		else
			self:ClearSongState( );
		end
		self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. found .. ")" );
		
		-- action for selecting a dir
		self.dirlistBox.SelectedIndexChanged = function( sender, args )
			self:SelectDir(sender:GetSelectedIndex());
		end
		-- action for selecting a song
		self.songlistBox.SelectedIndexChanged = function( sender, args )
			self:SelectSong(sender:GetSelectedIndex());
		end
		-- action for selecting a track
		self.tracklistBox.SelectedIndexChanged = function( sender, args )
			self:SelectTrack(sender:GetSelectedIndex());
		end
		
		self.tracklistBox.MouseClick = function( sender, args )
			if args.Button == Turbine.UI.MouseButton.Right then
				self:RealignTracknames( )
			end
		end
		self.sepSongsTracks.MouseClick = self.tracklistBox.MouseClick
		
	else
		-- show message when library is empty or database format has changed
		self.separator1:SetVisible( false );
		self.sepSongsTracks:SetVisible( false );
		self.listFrame.heading:SetText( "" );
		self.emptyLabel = Turbine.UI.Label();
		self.emptyLabel:SetParent( self );
		self.emptyLabel:SetPosition( 30, 210 );
		self.emptyLabel:SetSize(220, 240);
		self.emptyLabel:SetText(Strings["err_nosongs"]);
	end
	
	-- window resize control
	self.resizeCtrl = Turbine.UI.Control();
	self.resizeCtrl:SetParent(self);
	self.resizeCtrl:SetSize(20,20);		
	self.resizeCtrl:SetZOrder(200);
	self.resizeCtrl:SetPosition(self:GetWidth() - 20,self:GetHeight() - 20); 
                    
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
	  	local width, height = self:GetSize();
		local gameDisplayWidth, gameDisplayHeight = Turbine.UI.Display.GetSize();
		
		if sender.dragging then
			
			width = width + args.X - sender.dragStartX;
			height = height + args.Y - sender.dragStartY;
			local WindowLeft = self:GetLeft();
			local WindowTop  = self:GetTop ();
			
			if width < self.minWidth then width = self.minWidth; end
			if height < 45 then height = 45; end
		------------------------------------
			if WindowLeft + width  > gameDisplayWidth  then
			width  = gameDisplayWidth  - WindowLeft; end
			if WindowTop  + height > gameDisplayHeight then
			height = gameDisplayHeight - WindowTop ; end
		------------------------------------
			local listContainerHeight = height - self.lCYmod;
			local tracksHeight = 0;
			if Settings.TracksVisible == "yes" then tracksHeight = Settings.TracksHeight; end
			if listContainerHeight < Settings.DirHeight + 13 + tracksHeight + 13 + 40 then
				listContainerHeight = Settings.DirHeight + 13 + tracksHeight + 13 + 40;
				height = listContainerHeight + self.lCYmod;
			end
			
			self:SetSize( width, height );

			self:ResizeAll( );
		end
    	
		sender:SetPosition( self:GetWidth() - sender:GetWidth(), self:GetHeight() - sender:GetHeight() );
	end -- resizeCtrl.MouseMove
	
	-- dir list, song list ratio adjust
	self.separator1.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
	
	self.separator1.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.DirHeight = self.dirlistBox:GetHeight(); 
	end
	
	self.separator1.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local y = self.separator1:GetTop();
			local h = self.dirlistBox:GetHeight() + args.Y - sender.dragStartY;
			if h < 40 then h = 40; end
			self.dirlistBox:SetHeight( h );
			self:AdjustSonglistHeight( )
			if self.songlistBox:GetHeight() < 40 then
				self:SetSonglistHeight( 40 )
				if (Settings.TracksVisible == "yes") then
					self.dirlistBox:SetHeight(self.listContainer:GetHeight() - Settings.TracksHeight - self.songlistBox:GetHeight() - 26);
				else
					self.dirlistBox:SetHeight(self.listContainer:GetHeight() - self.songlistBox:GetHeight() - 13);
				end
			end
			--self.separator1:SetTop(self.dirlistBox:GetHeight());
			self:SetSonglistTop( self.dirlistBox:GetHeight() + 13 )

			self:AdjustFilterUI( );
		end	
	end
	
	-- song list, track list ratio adjust
	self.sepSongsTracks.MouseDown = function(sender,args)
	  sender.dragStartX = args.X;
	  sender.dragStartY = args.Y;
	  sender.dragging = true;
	end
	
	self.sepSongsTracks.MouseUp = function(sender,args)
	  sender.dragging = false;
	  Settings.TracksHeight = self.tracklistBox:GetHeight(); 
	end
	
	self.sepSongsTracks.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local y = self.sepSongsTracks:GetTop();
			local h = self.tracklistBox:GetHeight() - args.Y + sender.dragStartY;
			if h < 40 then h = 40; end
			self:SetTracklistHeight( h )
			self:UpdateTracklistTop( );
			self:AdjustSonglistHeight( )
		end
		if self.songlistBox:GetHeight() < 40 then
			self:SetSonglistHeight( 40 )
			self:SetTracklistHeight( self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.songlistBox:GetHeight() - 26 );
			self:UpdateTracklistTop( );
		end	
	end
	
	-- Settings button	
	self.settingsBtn = Turbine.UI.Lotro.Button();
	self.settingsBtn:SetParent( self );
	self.settingsBtn:SetPosition(self:GetWidth()/2 - 55, self:GetHeight() - 30 );	
	self.settingsBtn:SetSize(110,20);
	self.settingsBtn:SetText(Strings["ui_settings"]);
	
	-- actions for settings button
	self.settingsBtn.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			settingsWindow:SetVisible(true);
			settingsWindow:Activate();
		end
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- Sync Info button	
	self.SyncInfoBtn = Turbine.UI.Lotro.Button();
	self.SyncInfoBtn:SetParent( self );
	self.SyncInfoBtn:SetPosition(self:GetWidth() - 150, self:GetHeight() - 30 );	
	self.SyncInfoBtn:SetSize(110,20);
	self.SyncInfoBtn:SetText("Sync Info");
	
	-- actions for Sync Info button
	self.SyncInfoBtn.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			PlayersSyncInfoWindow:SetVisible(true);
			PlayersSyncInfoWindow:Activate();
		end
	end	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	-- action for closing window and saving position
	self.Closed = function( sender, args )
		self:SaveSettings();
		self:SetVisible( false );
	end
	
	if (Plugins ["Songbook"] ~= nil ) then
		Plugins["Songbook"].Unload = function( sender, args )
			self:SaveSettings();
			RemoveCallback( Turbine.Chat, "Received", ChatHandler );
		end
	end
	
	self:CreateTimerUI( )
	self:CreateFilterUI( ) -- Creates the UI elements for the filters
	AddCallback( Turbine.Chat, "Received", ChatHandler ); -- installs handler for chat messages (to catch ready messages)
	self.listboxPlayers:EnableCharColumn( self.bShowReadyChars )
	self:RefreshPlayerListbox( ) -- lists the current party members; more will be added through chat messages
	
	if Settings.FiltersState == "true" then self:ShowFilterUI( true ); end
	self:SetChiefMode( Settings.ChiefMode == "true" )
	self:HightlightReadyColumns( self.bHighlightReadyCol )
	
	-- adjust to search visibility
	if (Settings.SearchVisible == "no") then 
		self:ToggleSearch("off");
	end
	
	self:ResizeAll( ); -- Adjust variable sizes and positions to current main window size
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
	self.bTimer = bActivate
	if not bActivate then self:StopTimer( ); end
end

function SongbookWindow:CreateTimerUI( )
	self.tracksMsg = Turbine.UI.Label( )
	self.tracksMsg:SetParent( self.listContainer )
	self.tracksMsg:SetMultiline( false )
	self.tracksMsg:SetSize( 150, 22 )
	self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold22 );
	--self.tracksMsg:SetForeColor( self.colourMessageTitle );
	self.tracksMsg:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight )
	self.tracksMsg:SetZOrder( 350 )
	self.tracksMsg:SetVisible( false )

	self.Update =
		function( )
			local previous = self.currentTime
			self.currentTime = Turbine.Engine.GetLocalTime() - self.startTimer
			local bKeepRunning = ( self.songDuration == 0 or self.currentTime <= self.songDuration )
			if self.bTimerCountdown == true and self.songDuration > 0 then
				self.currentTime = self.songDuration - self.currentTime;
				bKeepRunning = self.currentTime >= 0
			end

			if bKeepRunning then
				if self.currentTime ~= previous then self:SetTimer( self.currentTime ); end
			else
				self:StopTimer( )
			end
		end
end

function SongbookWindow:SetTimer( value )
	local mins = math.floor( value / 60 )
	self.tracksMsg:SetText( string.format("%u:%02u", mins, value - mins * 60 ) )
	Timer_Label:SetText( string.format("%u:%02u", mins, value - mins * 60 ) )
end
	
function SongbookWindow:StartTimer( )
	self.startTimer = Turbine.Engine.GetLocalTime( )
	self.songDuration = 0
	--local item, songTime
	local songTime
	-- for i = 1, self.tracklistBox:GetItemCount( ) do
		-- item = self.tracklistBox:GetItem( i )
		sMinutes, sSeconds = string.match( Synced_Song_TrackName , ".*%((%d+):(%d+)%).*" ) -- try (mm:ss)
		-- if not sMinutes or not sSeconds then
			-- sMinutes, sSeconds = string.match( item:GetText( ), ".*(%d+):(%d+).*" ) -- no luck, try just mm:ss
		-- end
		if sMinutes and sSeconds and tonumber(sMinutes) < 60 and tonumber(sSeconds) < 60 then
			songTime = sMinutes * 60 + sSeconds
			if songTime > self.songDuration then self.songDuration = songTime; end -- need longest track
		end
	--end

	if self.bTimerCountdown == true and self.songDuration > 0 then self.currentTime = self.songDuration
	else self.currentTime = 0; end

	self:SetTimer( self.currentTime )
	self.tracksMsg:SetVisible( true )
	self:SetWantsUpdates( true )
end

function SongbookWindow:StopTimer( )
	self:SetWantsUpdates( false )
	self.tracksMsg:SetVisible( false )
	Timer_Label:SetText("0:00");
	Song_Label:SetText( "" );
end

function SongbookWindow:ResizeAll( )
	self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod);
	self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod);
	self.listFrame.heading:SetSize(self.listFrame:GetWidth(),13);
	
	for j = 1, CharSettings.InstrumentSlots_Rows do
		local TopShift = 75 + InstrumentSlots_Shift * ( j - 1 );
		self.instrContainer[j]:SetTop( self:GetHeight() - TopShift );
	end
	
	self.dirlistBox:SetHeight( Settings.DirHeight );
	self:AdjustDirlistPosition( );

	if Settings.TracksVisible == "yes" then
		self:AdjustTracklistSize( Settings.TracksHeight )
		self:UpdateTracklistTop( )
	else
		self.tracksMsg:SetPosition( self.dirlistBox:GetLeft()+self.dirlistBox:GetWidth()-160, self.dirlistBox:GetTop()+self.dirlistBox:GetHeight());	
	end

	self:AdjustSonglistHeight( );
	self:AdjustSonglistPosition( );
		
	self.songTitle:SetWidth(self:GetWidth() - 52);
	self.settingsBtn:SetPosition(self:GetWidth()/2 - 55, self:GetHeight() - 30 );
	self.SyncInfoBtn:SetPosition(self:GetWidth() - 150, self:GetHeight() - 30 );
	--self.cbFilters:SetPosition( self:GetWidth()/2 + 65, self:GetHeight() - 30 );
	self.tipLabel:SetLeft(self:GetWidth() - 270);
	self:AdjustFilterUI( );
	
	self.PlayerTitle:SetWidth(self:GetWidth() - 30);
	self.MessageTitle:SetWidth(self:GetWidth() - 30);
	self.syncMessageTitle:SetWidth(self:GetWidth() - 30);
end -- SongbookWindow:ResizeAll( )


-- action for selecting a directory
function SongbookWindow:SelectDir( iDir , Directory )
	if not Directory then 
		local selectedItem = self:SetListboxColours( self.dirlistBox ) --, iDir )
		if not selectedItem then return; end
		Directory = selectedItem:GetText();
		
		if Directory == ".." then
			selectedDir = "";
			table.remove(dirPath,#dirPath);
			for i = 1,#dirPath do 
				selectedDir = selectedDir .. dirPath[i];
			end
		else		
			selectedDir = selectedDir .. Directory;
			dirPath[#dirPath+1] = Directory;	
		end
	else
		selectedDir = Directory;
		dirPath[#dirPath+1] = Directory;
	end
		
	if (string.len(selectedDir)<31) then 
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" );
	else 
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. string.sub(selectedDir,string.len(selectedDir)-30) .. ")" );
	end
	
	-- refresh dir list
	self.dirlistBox:ClearItems();
	local dirItem = Turbine.UI.Label();
	if (selectedDir ~= "/") then
		dirItem:SetText(".."); -- first item as link to previous directory
		dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		dirItem:SetSize( 1000, 20 );				
		self.dirlistBox:AddItem( dirItem );
	end
	
	for i = 1, #SongDB.Directories do
		dirItem = Turbine.UI.Label();		
		local _, dirLevelIni = string.gsub(selectedDir, "/", "/");
		local _, dirLevel = string.gsub(SongDB.Directories[i], "/", "/");
		if (dirLevel == dirLevelIni + 1) then
			if (selectedDir ~= "/") then
				local matchPos,_ = string.find(SongDB.Directories[i], selectedDir, 0, true);
				if (matchPos == 1) then	
					local _,cutPoint = string.find(SongDB.Directories[i], dirPath[#dirPath], 0, true);
					dirItem:SetText(string.sub(SongDB.Directories[i],cutPoint+1));			
					dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
					dirItem:SetSize( 1000, 20 );				
					self.dirlistBox:AddItem( dirItem );
				end
			else 
				dirItem:SetText(string.sub(SongDB.Directories[i],2));			
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );				
				self.dirlistBox:AddItem( dirItem );
			end
		end
	end
	
	self.songlistBox:ClearItems();
	self:LoadSongs( );
	self:InitSonglist( );
end -- SelectDir


-- load content to song list box
function SongbookWindow:LoadSongs( )
	local nFiltered = 0;
	for i = 1, librarySize do
		local songItem = Turbine.UI.Label();
		-- Added function to filter song data
		if( SongDB.Songs[i].Filepath == selectedDir and self:ApplyFilters( SongDB.Songs[i] ) ) then
			if (Settings.DescriptionVisible == "yes") then
				if (Settings.DescriptionFirst == "yes") then
					songItem:SetText(SongDB.Songs[i].Tracks[1].Name .. " / " .. SongDB.Songs[i].Filename);					
				else
					songItem:SetText(SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name);
				end
			else
				songItem:SetText( SongDB.Songs[i].Filename );
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );
			
			self.songlistBox:AddItem( songItem );
			nFiltered = nFiltered + 1;
			self.aFilteredIndices[ nFiltered ] = i; -- Create filtered index		
			
			if SelectedMatchedSong_Index == i then
				SelectedMatchedSong_IndexListBox = nFiltered;
			end
			if OtherPlayer_SyncedSong_Index == i then
				OtherPlayer_SyncedSong_IndexListBox = nFiltered;
			end
		end
	end
end

function SongbookWindow:SelectedTrackIndex( iList )
	if not iList then iList = selectedTrack; end -- use global selected track index if none provided
	if self.iCurrentSetup and self.aSetupTracksIndices[ iList ] then
		return self.aSetupTracksIndices[ iList ];
	end
	return iList;
end

-- action for selecting a song
function SongbookWindow:SelectSong( iSong )
	if( iSong < 1 or iSong > self.songlistBox:GetItemCount( ) ) then
		return;
	end
	selectedTrack = 1;
	self.aSetupTracksIndices = { };
	self.aSetupListIndices = { };
	self.iCurrentSetup = nil

	-- clear focus
	self:SetListboxColours( self.songlistBox ) --, iSong )
	
	selectedSongIndexListBox = iSong;
	selectedSongIndex = self.aFilteredIndices[ iSong ];
	selectedSong = SongDB.Songs[selectedSongIndex].Filename;
			
	if ( SongDB.Songs[selectedSongIndex].Tracks[1].Name ~= "") then
		self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Name );	
	else
		self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Filename );	
	end
	self.trackNumber:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Id );
	self.trackPrev:SetVisible(false);
	
	if (#SongDB.Songs[selectedSongIndex].Tracks > 1) then
		self.trackNext:SetVisible(true);
	else
		self.trackNext:SetVisible(false);
	end

	self:ListTracks(selectedSongIndex);	
	
	self:ClearPlayerReadyStates( );
	self:SelectTrack( selectedTrack );
	self:SetPlayerColours( );
	self:ListSetups( selectedSongIndex )
	self.iCurrentSetup = self:SetupIndexForCount( selectedSongIndex, self.selectedSetupCount )
	self:SelectSetup( self.iCurrentSetup )
	self:UpdateSetupColours( );
	
	self:SetTrackColours( selectedTrack );
	
	local found = self.tracklistBox:GetItemCount();
	self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
end


-- action for repopulating the track list when song is changed
function SongbookWindow:ListTracks( songid )			
	self.tracklistBox:ClearItems();
	SyncInfolistbox:ClearItems( );
	for i = 1, #SongDB.Songs[songid].Tracks do
		self:AddTrackToList( songid, i )
	end
	--Turbine.Chat.Received = self.ChatHandler; -- Enable chat monitoring for ready messages to update track colours
end


function SongbookWindow:CreateTracklistItem( sText )
	local trackItem = Turbine.UI.Label();
	trackItem:SetMultiline( false )
	trackItem:SetText( sText );
	trackItem.MouseClick = self.sepSongsTracks.MouseClick
	trackItem:SetForeColor( self.colourDefault );
	return trackItem
end

function SongbookWindow:AddTrackToList( iSong, iTrack )
	local sTerseName = self:TerseTrackname( SongDB.Songs[iSong].Tracks[iTrack].Name );
	local trackItem = self:CreateTracklistItem( "[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "] " .. sTerseName )
	trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	trackItem:SetSize( 1000, 20 );
	self.tracklistBox:AddItem( trackItem );
	
	local Track_Instrument = self:FindInstrumentInTrack( sTerseName );
	
	trackItem = Turbine.UI.Label();
	trackItem:SetMultiline( false )
	trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	trackItem:SetSize( 2000, 20 );
	trackItem:SetMarkupEnabled(true);
	trackItem:SetText( "[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "] " .. Track_Instrument[1] );
	trackItem:SetBackColor( self.backColourDefault );
	
	SyncInfolistbox:AddItem( trackItem );
end

	
-- Right-align track names (so user can quickly check then end of the track name)
function SongbookWindow:RealignTracknames( )
	local alignment, left
	if self.alignTracksRight == false then
		self.alignTracksRight = true
		alignment = Turbine.UI.ContentAlignment.MiddleRight
		left = self.tracklistBox:GetWidth( ) - 1010
	else
		self.alignTracksRight = false
		alignment = Turbine.UI.ContentAlignment.MiddleLeft
		if self.bShowReadyChars then left = 20
		else left = 0; end
	end

	for i = 1, self.tracklistBox:GetItemCount( ) do
		local item = self.tracklistBox:GetItem( i )
		item:SetLeft( left ) 
		item:SetTextAlignment( alignment );
	end
end

--%%%%%%%%%%%%%%%%%%%%%

-- set track ready indicator
function SongbookWindow:SetTrackReadyChar( iList, readyState )
	if not readyState then -- track not ready
		self.tracklistBox:SetColumnChar( iList, self.chNone, false )
	elseif readyState == 0 then -- track is ready by more than one player
		self.tracklistBox:SetColumnChar( iList, self.chMultiple, true )
	else -- track ready by one player
		self.tracklistBox:SetColumnChar( iList, self.chReady, false )
	end
end


-- action to search songs
function SongbookWindow:SearchSongs()
	self.songlistBox:ClearItems()
	local matchFound
	local nFound = 0
	
	self.aFilteredIndices = { }
	for i = 1, librarySize do		
		matchFound = false

		if self:ApplyFilters( SongDB.Songs[i] ) == true then -- filters are matched, now look for search input
			if string.find( string.lower(SongDB.Songs[i].Filename ), string.lower( self.searchInput:GetText( ) ) ) ~= nil then
				matchFound = true;
			else
				for j = 1, #SongDB.Songs[i].Tracks do
					if string.find(string.lower(SongDB.Songs[i].Tracks[j].Name), string.lower(self.searchInput:GetText())) ~= nil then
						matchFound = true;
						break;
					end
				end
			end
		end
		
		if matchFound == true then
			local songItem = Turbine.UI.Label();
			if (Settings.DescriptionVisible == "yes") then			
				songItem:SetText(SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name);
			else
				songItem:SetText(SongDB.Songs[i].Filename);
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );				
			self.songlistBox:AddItem( songItem );
			nFound = nFound + 1;
			self.aFilteredIndices[ nFound ] = i; -- Create index redirect table
		end
	end
	
	--local found = self.songlistBox:GetItemCount();
	if (nFound > 0) then self:SelectSong(1);
	else --self:ClearSongState( );
	end
	self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. nFound .. ")" );
end

-- action for toggling search function on and off
function SongbookWindow:ToggleSearch(mode)
	if (Settings.SearchVisible == "yes" or mode == "off") then		
		Settings.SearchVisible = "no";
		self:SetSearch( -20, false )
	else
		Settings.SearchVisible = "yes";
		self:SetSearch( 20, true )
	end

	self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);	
	self.listContainer:SetHeight(self:GetHeight() - self.lCYmod);		
	if (Settings.TracksVisible == "no") then
		self:ShowTrackListbox( false ) -- ?
	end
end

function SongbookWindow:SetSearch( delta, bShow )
	self.searchInput:SetVisible(bShow);
	self.searchBtn:SetVisible(bShow);
	self.clearBtn:SetVisible(bShow);		
	self.lFYmod = self.lFYmod + delta;		
	self.lCYmod = self.lCYmod + delta;
	self.listFrame:SetTop( self.listFrame:GetTop( ) + delta);
	self.listContainer:SetTop( self.listContainer:GetTop( ) + delta );
	self:SetSonglistHeight(self.songlistBox:GetHeight() - delta);		
	self:MoveTracklistTop( -delta );
	
	if Settings.TracksVisible == "no" then
		self.tracksMsg:SetTop( self.dirlistBox:GetTop()+self.dirlistBox:GetHeight() );
	end
end

-- action for toggling description on and off
function SongbookWindow:ToggleDescription()
	if (Settings.DescriptionVisible == "yes") then
		Settings.DescriptionVisible = "no";
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then self:SelectSong(1);
		else self:ClearSongState( ); end
	else
		Settings.DescriptionVisible = "yes";
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then self:SelectSong(1);
		else self:ClearSongState( ); end
	end
end

-- action for toggling description on and off
function SongbookWindow:ToggleDescriptionFirst()
	if (Settings.DescriptionFirst == "yes") then
		Settings.DescriptionFirst = "no";		
		if (Settings.DescriptionVisible == "yes") then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then self:SelectSong(1);
			else self:ClearSongState( ); end
		end
	else
		Settings.DescriptionFirst = "yes";
		if (Settings.DescriptionVisible == "yes") then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then self:SelectSong(1);
			else self:ClearSongState( ); end
		end
	end
end

-- action for toggling tracks display on and off
function SongbookWindow:ToggleTracks()
	if (Settings.TracksVisible == "yes") then
		Settings.TracksVisible = "no";
		self:SetSonglistHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
		self:ShowTrackListbox( false )
		self.listboxSetups:SetVisible(false);
		self.tracksMsg:SetPosition( self.dirlistBox:GetLeft()+self.dirlistBox:GetWidth()-150, self.dirlistBox:GetTop()+self.dirlistBox:GetHeight());	
	else
		Settings.TracksVisible = "yes";
		self:ShowTrackListbox( true )
		self.listboxSetups:SetVisible(self.bShowSetups)
		
		-- check if there's room for the track list and adjust
		local h = self.dirlistBox:GetHeight() + Settings.TracksHeight + 26;
		if (self.listContainer:GetHeight() - h < 40) then
			self.listContainer:SetHeight(h + self.songlistBox:GetHeight())
			self:SetHeight(self.listContainer:GetHeight() + self.lCYmod);
			self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);
			self.resizeCtrl:SetTop(self:GetHeight() - 20); 
		end
					
		self:SetTracklistTop( self.listContainer:GetHeight() - Settings.TracksHeight )
		self:AdjustTracklistSize( Settings.TracksHeight )			
		self:SetSonglistHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
		self.settingsBtn:SetPosition(self:GetWidth()/2 - 55, self:GetHeight() - 30 );
		self.SyncInfoBtn:SetPosition(self:GetWidth() - 150, self:GetHeight() - 30 );	
		--self.cbFilters:SetPosition( self:GetWidth()/2 + 65, self:GetHeight() - 30 );
		
		if (CharSettings.InstrSlots[1]["visible"] == "yes") then
			for j = 1, CharSettings.InstrumentSlots_Rows do
				local TopShift = 75 + InstrumentSlots_Shift * ( j - 1 );
				self.instrContainer[j]:SetTop( self:GetHeight() - TopShift );
			end
		end
	end
end

-- action for toggling instrument slots on and off
function SongbookWindow:ToggleInstrSlots()
	local hMod = InstrumentSlots_Shift * CharSettings.InstrumentSlots_Rows;
	if (CharSettings.InstrSlots[1]["visible"] == "yes") then		
		CharSettings.InstrSlots[1]["visible"] = "no";
		
		self:SetInstrSlots( -hMod );
		for j = 1, CharSettings.InstrumentSlots_Rows do
			self.instrContainer[j]:SetVisible( false );
		end
	else
		CharSettings.InstrSlots[1]["visible"] = "yes";
		
		self:SetInstrSlots( hMod );
		for j = 1, CharSettings.InstrumentSlots_Rows do
			self.instrContainer[j]:SetVisible( true );
		end
	end
end

function SongbookWindow:SetInstrSlots( delta )
	self.lFYmod = self.lFYmod + delta;
	self.lCYmod = self.lCYmod + delta;
	self.listFrame:SetHeight(self.listFrame:GetHeight() - delta);
	self.listContainer:SetHeight(self.listContainer:GetHeight() - delta);
	self:SetSonglistHeight(self.songlistBox:GetHeight() - delta);
	if (Settings.TracksVisible == "yes") then
		self:MoveTracklistTop( -delta )
		--self.tracklistBox:SetTop(self.tracklistBox:GetTop() - hMod);
		--self.sepSongsTracks:SetTop(self.sepSongsTracks:GetTop() - hMod);		
	end
	
	local height = self:GetHeight();
	if height < 45 then height = 45; end
	
	local listContainerHeight = height - self.lCYmod;
	local tracksHeight = 0;
	if Settings.TracksVisible == "yes" then tracksHeight = Settings.TracksHeight; end
	if listContainerHeight < Settings.DirHeight + 13 + tracksHeight + 13 + 40 then
		listContainerHeight = Settings.DirHeight + 13 + tracksHeight + 13 + 40;
		height = listContainerHeight + self.lCYmod;
	end
	
	self:SetHeight( height );
	self:ResizeAll( );
	self.resizeCtrl:SetPosition( self:GetWidth() - self.resizeCtrl:GetWidth(), self:GetHeight() - self.resizeCtrl:GetHeight() );
end

function SongbookWindow:ClearSlots()
	for j = 1, CharSettings.InstrumentSlots_Rows do
		for i=1,CharSettings.InstrSlots[j]["number"] do
			CharSettings.InstrSlots[j][tostring(i)].qsType ="";
			CharSettings.InstrSlots[j][tostring(i)].qsData = "";
			local sc = Turbine.UI.Lotro.Shortcut( "", "");
			self.instrSlot[j][i]:SetShortcut(sc);
		end
	end
end

function SongbookWindow:AddSlot()
	if self:GetWidth() > 10+(CharSettings.InstrSlots[1]["number"]+1)*40 then
		local newslot = CharSettings.InstrSlots[1]["number"]+1;
		for j = 1, CharSettings.InstrumentSlots_Rows do
			CharSettings.InstrSlots[j]["number"] = newslot;
			self.instrSlot[j][newslot] = Turbine.UI.Lotro.Quickslot();
			self.instrSlot[j][newslot]:SetParent( self.instrContainer[j] );
			self.instrSlot[j][newslot]:SetPosition(40*(newslot-1), 0);
			self.instrSlot[j][newslot]:SetSize(37, 37);
			self.instrSlot[j][newslot]:SetZOrder(100);
			self.instrSlot[j][newslot]:SetAllowDrop(true);
			self.instrContainer[j]:SetWidth(self.instrContainer[j]:GetWidth()+40); 
			
			local sc = Turbine.UI.Lotro.Shortcut("","");
			self.instrSlot[j][newslot]:SetShortcut(sc);
			
			CharSettings.InstrSlots[j][tostring(newslot)] = { qsType = "", qsData = "" };		
			
			self.instrSlot[j][newslot].ShortcutChanged = function( sender, args )
				pcall(function() 
					local sc = sender:GetShortcut();
					CharSettings.InstrSlots[j][tostring(newslot)].qsType = tostring(sc:GetType());
					CharSettings.InstrSlots[j][tostring(newslot)].qsData = sc:GetData();
				end);
			end
			
			self.instrSlot[j][newslot].DragLeave = function( sender, args )
				if (instrdrag) then 
					CharSettings.InstrSlots[j][tostring(newslot)].qsType ="";
					CharSettings.InstrSlots[j][tostring(newslot)].qsData = "";
					local sc = Turbine.UI.Lotro.Shortcut( "", "");
					self.instrSlot[j][newslot]:SetShortcut(sc);
					instrdrag = false;
				end
			end
			
			self.instrSlot[j][newslot].MouseDown = function( sender, args )
				if(args.Button == Turbine.UI.MouseButton.Left) then	
					instrdrag = true;
				end
			end
		end
	end
end

function SongbookWindow:DelSlot()
	for j = 1, CharSettings.InstrumentSlots_Rows do
		if CharSettings.InstrSlots[j]["number"] > 1 then
			local delslot = CharSettings.InstrSlots[j]["number"];
			CharSettings.InstrSlots[j]["number"] = CharSettings.InstrSlots[j]["number"]-1;
			self.instrContainer[j]:SetWidth(self.instrContainer[j]:GetWidth()-40); 
			self.instrSlot[j][delslot] = nil;
			CharSettings.InstrSlots[j][tostring(delslot)] = nil;
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SongbookWindow:AddSlot_row()
	if (CharSettings.InstrSlots[1]["visible"] == "yes") then
		CharSettings.InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows + 1;
		local InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows;
		
		table.insert(self.instrContainer , Turbine.UI.Control);
		
		self.instrContainer[InstrumentSlots_Rows] = Turbine.UI.Control();
		self.instrContainer[InstrumentSlots_Rows]:SetParent( self );
		local TopShift = 75 + InstrumentSlots_Shift * ( InstrumentSlots_Rows - 1 );
		self.instrContainer[InstrumentSlots_Rows]:SetPosition( 10, self:GetHeight() - TopShift );
		if (CharSettings.InstrSlots[1]["visible"] == "yes") then
			self.instrContainer[InstrumentSlots_Rows]:SetVisible( true );
		else
			self.instrContainer[InstrumentSlots_Rows]:SetVisible( false );
		end
		self.instrContainer[InstrumentSlots_Rows]:SetSize( 40*CharSettings.InstrSlots[1]["number"], 38 );
		self.instrContainer[InstrumentSlots_Rows]:SetZOrder(90);
		
		
		table.insert(self.instrSlot , {});
		
		table.insert(CharSettings.InstrSlots , {});
		CharSettings.InstrSlots[InstrumentSlots_Rows]["visible"] = "yes";
		CharSettings.InstrSlots[InstrumentSlots_Rows]["number"] = CharSettings.InstrSlots[1]["number"];
		for i = 1, CharSettings.InstrSlots[InstrumentSlots_Rows]["number"] do
			CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)] = { qsType = "", qsData = "" };		
		end
		
		for i = 1, CharSettings.InstrSlots[1]["number"] do
			self.instrSlot[InstrumentSlots_Rows][i] = Turbine.UI.Lotro.Quickslot();
			self.instrSlot[InstrumentSlots_Rows][i]:SetParent( self.instrContainer[InstrumentSlots_Rows] );
			self.instrSlot[InstrumentSlots_Rows][i]:SetPosition(40*(i-1), 0);
			self.instrSlot[InstrumentSlots_Rows][i]:SetSize(37, 37);
			self.instrSlot[InstrumentSlots_Rows][i]:SetZOrder(100);
			self.instrSlot[InstrumentSlots_Rows][i]:SetAllowDrop(true);
			
			if (CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].data ~= "") then
				pcall(function() 
					local sc = Turbine.UI.Lotro.Shortcut( CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsType, CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsData);
					self.instrSlot[InstrumentSlots_Rows][i]:SetShortcut(sc);
				end);
			end
			
			self.instrSlot[InstrumentSlots_Rows][i].ShortcutChanged = function( sender, args )
				pcall(function() 
					local sc = sender:GetShortcut();
					CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsType = tostring(sc:GetType());
					CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsData = sc:GetData();
				end);
			end
			
			self.instrSlot[InstrumentSlots_Rows][i].DragLeave = function( sender, args )
				if (instrdrag) then 
					CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsType ="";
					CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)].qsData = "";
					local sc = Turbine.UI.Lotro.Shortcut( "", "");
					self.instrSlot[InstrumentSlots_Rows][i]:SetShortcut(sc);
					instrdrag = false;
				end
			end
			
			self.instrSlot[InstrumentSlots_Rows][i].MouseDown = function( sender, args )
				
				if(args.Button == Turbine.UI.MouseButton.Left) then	
					instrdrag = true;
				end
			end
		end
		
		self:SetInstrSlots( InstrumentSlots_Shift );
	end
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SongbookWindow:DelSlot_row()
	if (CharSettings.InstrSlots[1]["visible"] == "yes") then
		if CharSettings.InstrumentSlots_Rows > 1 then
			local InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows;
			
			for i = 1, CharSettings.InstrSlots[1]["number"] do
				self.instrSlot[InstrumentSlots_Rows][i] = nil;
				CharSettings.InstrSlots[InstrumentSlots_Rows][tostring(i)] = nil;
			end
			
			self.instrContainer[InstrumentSlots_Rows]:SetVisible( false );
			self.instrContainer[InstrumentSlots_Rows] = nil;
			CharSettings.InstrSlots[InstrumentSlots_Rows] = nil;
			--table.remove(self.instrContainer);
			--table.remove(CharSettings.InstrSlots);
			
			CharSettings.InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows - 1;
			
			
			self:SetInstrSlots( -InstrumentSlots_Shift );
		end
	end
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:ExpandCmd(cmdId)
	local selTrack = self:SelectedTrackIndex( );
	if librarySize ~= 0 then
		local cmd = Settings.Commands[cmdId].Command;
		if SongDB.Songs[selectedSongIndex].Tracks[ selTrack ] then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[selectedSongIndex].Tracks[ selTrack ].Name);				
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename);
			if (selTrack ~= 1) then
				cmd = string.gsub(cmd, "%%part", selTrack );
			else
				cmd = string.gsub(cmd, "%%part", "");
			end
		elseif SongDB.Songs[selectedSongIndex].Filename then
			cmd = string.gsub(cmd, "%%name", SongDB.Songs[selectedSongIndex].Filename);
			cmd = string.gsub(cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename);	
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
	Settings.WindowPosition.Left = tostring(self:GetLeft());
	Settings.WindowPosition.Top = tostring(self:GetTop());
	Settings.WindowPosition.Width = tostring(self:GetWidth());
	Settings.WindowPosition.Height = tostring(self:GetHeight());
	Settings.ToggleTop = tostring(Settings.ToggleTop);
	Settings.ToggleLeft = tostring(Settings.ToggleLeft);
	Settings.DirHeight = tostring(Settings.DirHeight);
	Settings.TracksHeight = tostring(Settings.TracksHeight);
	Settings.WindowOpacity = tostring(Settings.WindowOpacity);
	Settings.ToggleOpacity = tostring(Settings.ToggleOpacity);
	Settings.FiltersState = tostring( self.bFilter )
	Settings.ChiefMode = tostring( self.bChiefMode )
	Settings.TimerState = tostring( self.bTimer )
	Settings.TimerCountdown = tostring( self.bTimerCountdown )
	Settings.ReadyColState = tostring( self.bShowReadyChars )
	Settings.ReadyColHighlight = tostring( self.bHighlightReadyCol )
	
	Settings.TimerWindowVisible = tostring( self.TimerWindowVisible )
	Settings.HelpWindowDisable = tostring( self.HelpWindowDisable )
	
	Settings.UseRaidChat = tostring( self.UseRaidChat )
	Settings.UseFellowshipChat = tostring( self.UseFellowshipChat )
	
	Settings.PlayersSyncInfoWindowPosition.Left = tostring(PlayersSyncInfoWindow:GetLeft());
	Settings.PlayersSyncInfoWindowPosition.Top = tostring(PlayersSyncInfoWindow:GetTop());
	Settings.PlayersSyncInfoWindowPosition.Width = tostring(PlayersSyncInfoWindow:GetWidth());
	Settings.PlayersSyncInfoWindowPosition.Height = tostring(PlayersSyncInfoWindow:GetHeight());
	
	CharSettings.UserChatNumber = tostring(CharSettings.UserChatNumber);
	CharSettings.InstrumentSlots_Rows = tostring(CharSettings.InstrumentSlots_Rows);
	
	for j = 1, CharSettings.InstrumentSlots_Rows do
		for i = 1, CharSettings.InstrSlots[j]["number"] do
			CharSettings.InstrSlots[j][tostring(i)].qsType = tostring(CharSettings.InstrSlots[j][tostring(i)].qsType);
		end
		CharSettings.InstrSlots[j]["number"] = tostring(CharSettings.InstrSlots[j]["number"]);
	end
	
	SongbookSave( Turbine.DataScope.Account, gSettings, Settings,
		function( result, message )
			if ( result ) then
				Turbine.Shell.WriteLine( "<rgb=#00FF00>" .. Strings["sh_saved"] .. "</rgb>");
			else
				Turbine.Shell.WriteLine( "<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end);
	SongbookSave( Turbine.DataScope.Character, gSettings, CharSettings,
		function( result, message )
			if ( result ) then
				--Turbine.Shell.WriteLine( "<rgb=#00FF00>" .. Strings["sh_saved"] .. "</rgb>");
			else
				Turbine.Shell.WriteLine( "<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end);	
end


-- Parse filter string entered by the user.
function SongbookWindow:ParsePartsFilter( sText )
	local sPattern = "[";
	local iEnd = 0;
	local number, numberTo, iEndTo, temp, maxTracks;

	for maxTracks = 1,self.maxTrackCount do
		iEnd = iEnd + 1;
		temp, iEnd, number = string.find( sText, "%s*(%d+)%s*", iEnd );

		if( iEnd == nil ) then break; end

		iEnd = iEnd + 1;
		if( string.sub( sText, iEnd, iEnd ) == "-" ) then
			temp, iEndTo, numberTo = string.find( sText, "%s*(%d+)%s*", iEnd + 1 );
			if( iEndTo == nil ) then
				numberTo = self.maxTrackCount;
			else
				iEnd = iEndTo + 1;
			end
		else
			numberTo = number;
		end
	
		for temp = number, numberTo do
			sPattern = sPattern .. string.char( 0x40 + temp ); -- 0x40 is ASCII-code 'A' - 1
		end
	end
	
	if( sPattern == "[" ) then
		self.sFilterPartcount = "[a-z]";
	else
		self.sFilterPartcount = sPattern .. "]";
	end
end -- ParsePartsFilter


-- return true if at least one word is in both string lists 
function SongbookWindow:MatchStringList( list1, list2 )
	for word1 in string.gmatch( list1, "%a+" ) do
		for word2 in string.gmatch( list2, "%a+" ) do
			if word1 == word2 then return true; end
		end
	end
	return false;
end

function SongbookWindow:IsEmptyString( s )
  return not not tostring( s ):find( "^%s*$" )
end

-- Check whether the given song fits all the filters that are currently set 
function SongbookWindow:ApplyFilters( songData )
	if( songData == nil ) then return false; end
	
	if( self.cbComposer and self.cbComposer:IsChecked( ) ) then
		if( songData.Artist == nil ) then return false; end
		local sFilter = string.lower( self.editComposer:GetText( ) );
		if( sFilter ~= "" and string.find( string.lower( songData.Artist ), sFilter ) == nil ) then
			return false
		end
	end
	if( self.cbPartcount and self.cbPartcount:IsChecked( ) ) then
		local sFilter = self.editPartcount:GetText( )
		if( sFilter == "" ) then
			if not self.maxPartCount then return true
			else sFilter = "1-" .. tostring( self.maxPartCount ); end
		end
		if( songData.Partcounts == nil ) then return false; end
		self:ParsePartsFilter( sFilter );
		if( string.match( songData.Partcounts, self.sFilterPartcount ) == nil ) then
			return false -- Song does not have a setup with an acceptable number of players
		end
	end
	if( self.cbGenre and self.cbGenre:IsChecked( ) ) then
		if( songData.Genre == nil ) then return false; end
		local sFilter = string.lower( self.editGenre:GetText( ) );
		if sFilter ~= "" and not self:MatchStringList( sFilter, string.lower( songData.Genre ) ) then
		--if( sFiler ~= "" and string.find( string.lower( songData.Genre ), sFilter ) == nil ) then
			return false
		end
	end
	if( self.cbMood and self.cbMood:IsChecked( ) ) then
		if( songData.Mood == nil ) then return false; end;
		local sFilter = string.lower( self.editMood:GetText( ) );
		if sFilter ~= "" and not self:MatchStringList( sFilter, string.lower( songData.Mood ) ) then
		--if( sFilter ~= "" and string.find( sFilter, string.lower( songData.Mood ) ) == nil ) then
			return false;
		end
	end
	if( self.cbAuthor and self.cbAuthor:IsChecked( ) ) then
		if( songData.Transcriber == nil ) then return false; end;
		local sFilter = string.lower( self.editAuthor:GetText( ) );
		if( sFilter ~= "" and string.find( sFilter, string.lower( songData.Transcriber ) ) == nil ) then
			return false;
		end
	end

	return true;
end -- ApplyFilters


-- Update the song list
function SongbookWindow:UpdateSongs( )
	self.songlistBox:ClearItems( );
	
	local sSearch = self.searchInput:GetText( );
	if( sSearch and sSearch ~= "" ) then self:SearchSongs( );
	else self:LoadSongs( ); end
	
	self:InitSonglist( );
end -- UpdateSongs

-- Initialize song: List tracks, set/clear chat handler, set headings
function SongbookWindow:InitSonglist( )
	local nSongs = self.songlistBox:GetItemCount( );
	if nSongs > 0 then
		self:SelectSong( 1 );
	else
		self.tracklistBox:ClearItems( );
		SyncInfolistbox:ClearItems( );
		--self:ClearSongState( )
		--Turbine.Chat.Received = nil; -- No tracks listed, so deactivate player ready indicator
		self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (0)" );
	end
	self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. nSongs .. ")" );
end -- UpdateSongs

-- Create compact track name by removing the title.
-- Note: Many of our older songs have quite different naming schemes; not sure if it's even worth parsing.
function SongbookWindow:TerseTrackname( sTrack )
	return sTrack; -- disabled for now.
end


function SongbookWindow:ClearSongState(  )
	syncedSongIndex = -1;
	syncedTrack = -1;
	self.aReadyTracks = "";
	self:ClearPlayerStates( );
	self:ClearSetups(  );
	self:SetTrackColours( selectedTrack );
	self:SetPlayerColours( );
	self:SetListboxColours( self.songlistBox );
end

function SongbookWindow:SongStarted( )
	self:ClearSongState(  )
	
	--Song_Label:SetText( string.sub( selectedSong, 1, 15 ) );
	Song_Label:SetText( Synced_Song_TrackName );
	
	songbookWindow.syncMessageTitle:SetText("");
	songbookWindow.syncMessageTitle:SetVisible(false);
	MatchedSongsWindow:SetVisible( false );
	
	SyncStartWindow_ShowFlag = 1;
	SyncStartWindow.Message:SetText("Nothing to Start");
	SyncStartWindow.YesSlot:SetVisible( false );
	SyncStartWindow.NoSlot:SetVisible( false );
	SyncStartWindow.YesIcon:SetVisible( false );
	SyncStartWindow.NoIcon:SetVisible( false );
		
	self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined , "" );
	self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut );
	self.syncStartSlot:SetVisible( true );
		
	if self.bInstrumentOk == false then
		self.tracksMsg:SetForeColor( self.colourDefault )
		self.tracksMsg:SetVisible( false )
		self.bInstrumentOk = true
	end
	if self.bTimer then self:StartTimer( )
	else --self:StopTimer( ) -- in case it is still counting ...
	end
end

--%%%%%%%%%%%%%%%%

-- Create the filter UI elements: Edit boxes for player count, transcriber, mood, genre
function SongbookWindow:CreateFilterUI( args )
	self.editPartcount = self:CreateFilterEdit( 0  );
	self.cbPartcount = self:CreateFilterCheckbox( 0, Strings["filterParts"] );
	self.cbPartcount.CheckedChanged =
		function( sender, args )
			--self:SetMaxPartCount( sender:IsChecked( ) )
			self:UpdateSongs( )
		end

	self.editComposer = self:CreateFilterEdit( 20 );
	self.cbComposer = self:CreateFilterCheckbox( 20, Strings["filterArtist"] );

	self.editGenre = self:CreateFilterEdit( 40 ); --,
	self.cbGenre = self:CreateFilterCheckbox( 40, Strings["filterGenre"] );
	
	self.editMood = self:CreateFilterEdit( 60 ); --,
	self.cbMood = self:CreateFilterCheckbox( 60, Strings["filterMood"] );

	self.editAuthor = self:CreateFilterEdit( 80 );
	self.cbAuthor = self:CreateFilterCheckbox( 80, Strings["filterAuthor"] );
	
	-- Separator filters - dir listbox
	self.separatorFilters = Turbine.UI.Control();
	self.separatorFilters:SetParent( self.listContainer );
	self.separatorFilters:SetZOrder( 300 );
	self.separatorFilters:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.separatorFilters:SetPosition( 156, self.dirlistBox:GetTop( ) );
	self.separatorFilters:SetSize( 10, self.dirlistBox:GetHeight( ) );
	self.separatorFilters:SetVisible( false );

	self:CreatePartyListbox( );
	self:CreateSetupsListbox( );
end


-- create a filter edit
function SongbookWindow:CreateFilterEdit( par_yPos, par_fn )
	local edit = Turbine.UI.Lotro.TextBox( );
	edit:SetParent( self.listContainer );
	edit:SetPosition( 0, par_yPos );
	edit:SetSize( 80, 20 );
	edit:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
	edit:SetMultiline( false );	
	edit:SetVisible( false );
	--edit.FocusLost = par_fn;
	edit.KeyDown = function( sender, keyargs )
		if( keyargs.Action == 162 ) then
			--if( edit:HasFocus( ) ) then
				self:UpdateSongs( );
			--end
		end
	end
	return edit;
end


-- Create a filter checkbox
function SongbookWindow:CreateFilterCheckbox( par_yPos, par_sText )
	-- search button
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetParent( self.listContainer );
	cb:SetPosition( 82, par_yPos );
	cb:SetSize( 80, 20 );
	cb:SetText( par_sText );
	cb.CheckedChanged =
		function( sender, args )
			self:UpdateSongs( );
		end
	cb:SetVisible( false );
	return cb;
end


-- Switch between filter UI display (true) and track listbox (false)
function SongbookWindow:ShowFilterUI( bFilter )
	self.bFilter = bFilter;
	self.editPartcount:SetVisible( bFilter ); self.cbPartcount:SetVisible( bFilter );
	self.editComposer:SetVisible( bFilter ); self.cbComposer:SetVisible( bFilter );
	self.editGenre:SetVisible( bFilter ); self.cbGenre:SetVisible( bFilter );
	self.editMood:SetVisible( bFilter ); self.cbMood:SetVisible( bFilter );
	self.editAuthor:SetVisible( bFilter ); self.cbAuthor:SetVisible( bFilter );
	self.separatorFilters:SetVisible( bFilter );
	
	self.btnParty:SetVisible( bFilter );
	self.listboxPlayers:SetVisible( bFilter );
	
	self:ResizeAll( );
end


-- Reposition the filter UI for dir listbox size changes
function SongbookWindow:AdjustFilterUI( )
	if not self.bFilter then return; end
	--if( not self.cbFilters:IsChecked( ) ) then return; end
	
	local dirHeight = self.dirlistBox:GetHeight( );
	if( dirHeight < 40 ) then dirHeight = 40; end

	self.editAuthor:SetVisible( dirHeight >= 100 ); self.cbAuthor:SetVisible( dirHeight >= 100 );
	self.editMood:SetVisible( dirHeight >= 80 ); self.cbMood:SetVisible( dirHeight >= 80 );
	self.editGenre:SetVisible( dirHeight >= 60 ); self.cbGenre:SetVisible( dirHeight >= 60 );

	self.separatorFilters:SetHeight( dirHeight );
end


function SongbookWindow:CheckInstrument( sTrack )
	local player = Turbine.Gameplay.LocalPlayer:GetInstance( );
	if not player then return; end
	local equip = player:GetEquipment( )
	if not equip then return; end
	local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
	if not item then return; end
	sTrack = sTrack:lower()
	--local sName = string.match( item:GetName( ), "%a+$" )
	self.bInstrumentOk = true -- only set to false if we can successfully determine track and equipped instrument
	local iName = self:GetInstrumentName( item:GetName( ):lower( ) )
	if not iName then return; end -- can't determine equipped instrument, disable message

	local iTrackInstrument = self:CheckTracksForInstrument( sTrack, iName, self.aInstruments ) -- try english names first
	if not iTrackInstrument then -- try localized names
		iTrackInstrument = self:CheckTracksForInstrument( sTrack, iName, aInstrumentsLoc )
	end

	if not iTrackInstrument then return; end -- could not determine the track instrument
	self:SetInstrumentMessage( aInstrumentsLoc[ iTrackInstrument ] ) -- print the localized name
end

function SongbookWindow:GetInstrumentName( sItem )
	if self.aSpecialInstruments and self.aSpecialInstruments[ sItem ] then
		return self.aSpecialInstruments[ sItem ] -- already contains the index 
	end
	for k,v in pairs( aInstrumentsLoc ) do
		if sItem:find( v ) then return k; end
	end
	return nil
end

function SongbookWindow:CheckTracksForInstrument( sTrack, iInstrument, aInstruments )
	if not iInstrument or iInstrument > #aInstruments then return nil; end
	local sName = aInstruments[ iInstrument ]
	for k,v in pairs( aInstruments ) do
		if sTrack:find( v ) then -- track name seems to contain the instrument name
			self.bInstrumentOk = not not string.find( sTrack, "[^%a]" .. sName:lower() )
			return k
		end
	end
	return nil
end
	

function SongbookWindow:SetInstrumentMessage( sInstr )
	if self.bInstrumentOk then
		self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold22 );
		self.tracksMsg:SetForeColor( self.colourDefault )
		self.tracksMsg:SetVisible( false )
	else
		self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold18 );
		self.tracksMsg:SetForeColor( self.colourWrongInstrument )
		self.tracksMsg:SetText( sInstr .. Strings["instr"] )
		self.tracksMsg:SetVisible( true )
	end
end


-- Add player to the fellowship list
function SongbookWindow:AddPlayerToList( sPlayername )
	if( self.listboxPlayers == nil ) then return; end -- Listbox not created yet

	local memberItem = Turbine.UI.Label( );
	memberItem:SetText( sPlayername );
	memberItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	memberItem:SetSize( 100, 20 );				
	self.listboxPlayers:AddItem( memberItem );
end

-- Remove player from the fellowship list
function SongbookWindow:RemovePlayerFromList( sPlayername )
	if( self.listboxPlayers == nil ) then return; end -- Listbox not created yet

	local i, item = self:GetItemFromList( self.listboxPlayers, sPlayername )
	if i then self.listboxPlayers:RemoveItemAt( i ); end
end

-- Get index and item for player name from player listbox
function SongbookWindow:GetItemFromList( listbox, sText )
	local i, item
	for i = 1, listbox:GetItemCount( ) do
		item = listbox:GetItem( i )
		if item:GetText( ) == sText then return i, item; end
	end
	return nil, nil
end
		


function SongbookWindow:EnableReadyColumns( bOn )
	self.listboxPlayers:EnableCharColumn( bOn )
	self.tracklistBox:EnableCharColumn( bOn )
end

function SongbookWindow:ShowReadyColumns( bShow )
	if self.bShowReadyChars == bShow then return; end
	self.bShowReadyChars = bShow
	self:EnableReadyColumns( bShow )
	if selectedSongIndex then
		--self:ListTracks( selectedSongIndex )
		--self:RefreshPlayerListbox( )
		self:SetTrackColours( selectedTrack );
		self:SetPlayerColours( );
	end
end

function SongbookWindow:HightlightReadyColumns( bOn )
	self.listboxPlayers.bHighlightReadyCol = bOn
	self.tracklistBox.bHighlightReadyCol = bOn
end


-- Read party member names and add them to the party members listbox
-- TODO: Party object does not seem to report party members correctly?
function SongbookWindow:RefreshPlayerListbox( )
	if self.listboxPlayers == nil then return; end
	
	self.listboxPlayers:ClearItems( );

	local player = Turbine.Gameplay.LocalPlayer:GetInstance( );
	if player == nil then return; end
	
	if self.sPlayerName == nil then self.sPlayerName = player:GetName( ); end
	
	local party = player:GetParty( );
	if party == nil or party:GetMemberCount( ) <= 0 then
		if self.bChiefMode then	self.aPlayers = { }; self.aCurrentSongReady = { }; end
		self:AddPlayerToList( self.sPlayerName )
		self.aPlayers[ self.sPlayerName ] = 0;
		self.Players_Data[ self.sPlayerName ] = 0;
		return;
	end 

	-- If in chief mode, we rely on the party object; otherwise, we keep the known players.
	if self.bChiefMode then	self.aPlayers = { }; self.Players_Data = { }; self.aCurrentSongReady = { }
	else self:ListKnownPlayers( ); end
	
	local iPlayer;
	for iPlayer = 1, party:GetMemberCount( ) do
		local member = party:GetMember( iPlayer )
		local sName = member:GetName( )
		if self.aPlayers[ sName ] == nil then self:AddPlayer( sName ); end
	end
	
	self:SetPlayerColours( ); -- restore current states
	self:UpdateMaxPartCount( )
	if self.maxPartCount then self:UpdateSongs( ) end
	self:UpdateSetupColours( );
end

-- Add player to arrays
function SongbookWindow:AddPlayer( sName )
	if self.aPlayers[ sName ] then return; end
	self.aCurrentSongReady[ sName ] = false
	self:AddPlayerToList( sName )
	self.aPlayers[ sName ] = 0
	self.Players_Data[ sName ] = 0
end

-- Add player to arrays
function SongbookWindow:RemovePlayer( sName )
	if not self.aPlayers[ sName ] then return; end
	self.aCurrentSongReady[ sName ] = nil
	self:RemovePlayerFromList( sName )
	self.aPlayers[ sName ] = nil
	self.Players_Data[ sName ] = nil
end


-- Write known players to player listbox
function SongbookWindow:ListKnownPlayers( )
	if not self.aPlayers then return; end
	for k,v in pairs( self.aPlayers ) do
		self:AddPlayerToList( k )
	end
end


-- Parse player join message, add player
-- Party object occasionally seems to become stale in raid settings, so we try to use client messages for player list updates
function SongbookWindow:PlayerJoined( sMsg )
	local temp, sPlayerName, sTrackName;
	temp, temp, sPlayerName = string.find( sMsg, "(%a+)" .. Strings["chat_playerJoin"] );
	if sPlayerName then self:AddPlayer( sPlayerName ); end
	self:PlayerSyncInfo();
end

-- Parse player left message, remove player
function SongbookWindow:PlayerLeft( sMsg )
	local temp, sPlayerName, sTrackName;
	temp, temp, sPlayerName = string.find( sMsg, "(%a+)" .. Strings["chat_playerLeave"] );
	if sPlayerName then self:RemovePlayer( sPlayerName ); end
	self:PlayerSyncInfo();
end


-- Clear the ready states for players
function SongbookWindow:ClearPlayerStates( )
	if not self.aPlayers then return; end
	for k in pairs( self.aPlayers ) do
		self.aPlayers[ k ] = 0; -- present, no song ready
		self.Players_Data[ k ] = 0;
	end
end


-- Update item colours in party listbox to indicate ready states
function SongbookWindow:SetPlayerColours( )
	if not self.aPlayers or not self.listboxPlayers then return; end

	local iMember;
	for iMember=1,self.listboxPlayers:GetItemCount( ) do
		local item = self.listboxPlayers:GetItem( iMember );
		if( self.aPlayers[ item:GetText( ) ] == nil ) then	-- should not happen
			item:SetForeColor( self.colourDefault );
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chNone, false ); end
		elseif( self.aPlayers[ item:GetText( ) ] == 0 ) then -- present, but no song ready
			item:SetForeColor( self.colourDefault );
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chNone, false ); end
		elseif self.aCurrentSongReady and self.aCurrentSongReady[ item:GetText( ) ] == 1 then 
			item:SetForeColor( self.colourReady ); -- Track from the currently displayed song ready
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chReady, false ); end
		elseif self.aCurrentSongReady and self.aCurrentSongReady[ item:GetText( ) ] == 2 then 
			item:SetForeColor( self.colourReadyMultiple ); -- Correct song, but same track as another player
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chMultiple, true ); end
		elseif self.aCurrentSongReady and self.aCurrentSongReady[ item:GetText( ) ] == 3 then 
			item:SetForeColor( self.colourDifferentSetup ); -- Correct song, but track not in current setup
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chWrongPart, true ); end
		else
			item:SetForeColor( self.colourDifferentSong ); -- Track ready, but different song
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chWrongSong, true ); end
		end
	end
end

-- Create party member listbox
function SongbookWindow:CreatePartyListbox( )
	local songsHeight = self.songlistBox:GetHeight( );
	local songsTop = self.songlistBox:GetTop( );
	if( songsHeight < 40 ) then songsHeight = 40; end

	-- Button to update party member list
	self.btnParty = Turbine.UI.Lotro.Button();
	self.btnParty:SetParent(self.listContainer);
	self.btnParty:SetPosition( 0, songsTop );
	self.btnParty:SetSize( 92, 20 );
	self.btnParty:SetText( Strings["players"] );
	self.btnParty:SetVisible( false );

	self.btnParty.MouseClick =
		function( sender, args )
			self:RefreshPlayerListbox( );
		end

	local dirsHeight = self.dirlistBox:GetHeight( );
	self.listboxPlayers = ListBoxCharColumn:New( 10, 20 );
	self.listboxPlayers:SetParent( self.listContainer );
	self.listboxPlayers:SetSize( 80, songsHeight - 20 );
	self.listboxPlayers:SetPosition( 2 , songsTop + 20 );
	self.listboxPlayers:SetVisible( false );
end

-- Use the number of currently listed players as limit for part counts
function SongbookWindow:SetMaxPartCount( bActivate )
	--self:RefreshPlayerListbox( )
	if bActivate and self.listboxPlayers then self.maxPartCount = self.listboxPlayers:GetItemCount( )
	else self.maxPartCount = nil;
	end
end

-- Due to party object issues, we only increase partcount here
function SongbookWindow:UpdateMaxPartCount( )
	if self.maxPartCount and self.listboxPlayers and self.maxPartCount < self.listboxPlayers:GetItemCount( ) then
		self.maxPartCount = self.listboxPlayers:GetItemCount( )
	end
end

-- Create listbox to show the possible setup counts
function SongbookWindow:CreateSetupsListbox( )
	self.listboxSetups = ListBoxScrolled:New( 10 );
	self.listboxSetups:SetParent( self.listContainer );
	self.listboxSetups:SetSize( self.listboxSetupsWidth - 0, self.tracklistBox:GetHeight( ) );
	self.listboxSetups:SetPosition( 0, self.tracklistBox:GetTop() );
	self.listboxSetups:SetVisible( self.bShowSetups );
	self.listboxSetups.SelectedIndexChanged =
		function( sender, args )
			self:ListTracksForSetup( sender:GetSelectedIndex( ) );
		end
end

function SongbookWindow:SelectSetup( iSetup )
	if not self.listboxSetups then return; end
	if not iSetup or iSetup > self.listboxSetups:GetItemCount( ) then iSetup = self.listboxSetups:GetItemCount( ); end
	self.listboxSetups:SetSelectedIndex( iSetup )
	self:ListTracksForSetup( iSetup )
end

function SongbookWindow:ListTracksForSetup( iSetup )
	if not SongDB.Songs[selectedSongIndex] or not SongDB.Songs[selectedSongIndex].Setups then return; end
	
	for iItem = 1, self.listboxSetups:GetItemCount( ) do
		self.listboxSetups:GetItem( iItem ):SetBackColor( self.backColourDefault );
	end

	local selTrack = self.tracklistBox:GetSelectedIndex( );
	
	self.aSetupTracksIndices = { };
	self.aSetupListIndices = { };
	self.iCurrentSetup = nil;

	if not iSetup or iSetup >= self.listboxSetups:GetItemCount( ) then
		self:ListTracks( selectedSongIndex );
		self.selectedSetupCount = nil
	else
		self.iCurrentSetup = iSetup;
		self.tracklistBox:ClearItems( );
		SyncInfolistbox:ClearItems( );
		for i = 1, #SongDB.Songs[selectedSongIndex].Setups[ iSetup ] do
			local iTrack = SongDB.Songs[selectedSongIndex].Setups[ iSetup ]:byte( i ) - 64;
			self.aSetupTracksIndices[ i ] = iTrack;
			self.aSetupListIndices[ iTrack ] = i;
			self:AddTrackToList( selectedSongIndex, iTrack )
		end
		self.selectedSetupCount = #SongDB.Songs[selectedSongIndex].Setups[ iSetup ]
	end

	local selItem = self.listboxSetups:GetSelectedItem( );
	if selItem then selItem:SetBackColor( self.backColourHighlight ); end
	
	self:SelectTrack( 1 ); --selTrack );
	self:SetPlayerColours( );
	local found = self.tracklistBox:GetItemCount( );
	self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
end

function SongbookWindow:SetupIndexForCount( iSong, setupCount )
	if not setupCount or not SongDB.Songs[iSong] or not SongDB.Songs[iSong].Setups then return nil; end
	for i = 1, #SongDB.Songs[iSong].Setups do
		if setupCount == #SongDB.Songs[iSong].Setups[ i ] then return i; end
	end
	return i
end

function SongbookWindow:UpdateSetupColours(  )
	if not self.listboxSetups or not SongDB.Songs[selectedSongIndex] or not SongDB.Songs[selectedSongIndex].Setups then return; end
	
	self:UpdateTrackReadyString( );

	local item;
	local matchPattern;
	local antiMatchPattern;
	local matchLength = 0;
	for i = 1, self.listboxSetups:GetItemCount( ) - 1 do
		item = self.listboxSetups:GetItem( i );

		matchPattern = "[" .. SongDB.Songs[selectedSongIndex].Setups[ i ] .. "]";
		antiMatchPattern = "[^" .. SongDB.Songs[selectedSongIndex].Setups[ i ] .. "]";
		_, matchLength = string.gsub( self.aReadyTracks, matchPattern, " " )

		if SongDB.Songs[selectedSongIndex].Setups[ i ] == self.aReadyTracks then
			item:SetForeColor( self.colourReady );
		elseif string.match( self.aReadyTracks, antiMatchPattern ) then
			item:SetForeColor( Turbine.UI.Color( 0.7, 0, 0 ) );
		elseif matchLength and matchLength + 1 == #SongDB.Songs[selectedSongIndex].Setups[ i ] then
			item:SetForeColor( Turbine.UI.Color( 0, 0.7, 0 ) );
		else
			item:SetForeColor( self.colourDefault );
		end
	end
end

function SongbookWindow:ClearSetups(  )
	if not self.listboxSetups then return; end	
	local selItem = self:SetListboxColours( self.listboxSetups, true );
	if selItem then selItem:SetBackColor( self.backColourHighlight ); end
end

function SongbookWindow:UpdateTrackReadyString( )
	self.aReadyTracks = "";
	for iList = 1,self.tracklistBox:GetItemCount( ) do
		local i = self:SelectedTrackIndex( iList );
		local ReadyState = self:GetTrackReadyState(  selectedSongIndex, i );
		
		if ReadyState[4] > 0 then
			self.aReadyTracks = self.aReadyTracks .. string.char( 0x40 + i );
		end
	end
end
		

-- Add an item with the given text to the given listbox
function SongbookWindow:AddItemToList( sText, listbox, width )
	if( listbox == nil ) then return; end -- Listbox not created yet

	local item = Turbine.UI.Label( );
	item:SetText( sText );
	item:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	item:SetSize( width, 20 );				
	listbox:AddItem(item);
end


function SongbookWindow:ListSetups( songID )
	if not self.listboxSetups or not self.listboxPlayers then return; end
	self.listboxSetups:ClearItems( )
	if not SongDB or not SongDB.Songs[songID] or not SongDB.Songs[songID].Setups then
		self:ShowSetups( false )
		return;
	end

	self:ShowSetups( true )
	local playerCount;
	if not self.maxPartCount then playerCount = 1000;
	else playerCount = self.maxPartCount; end
--playerCount = 6;	
	local countInSetup;
	for i = 1, #SongDB.Songs[songID].Setups do
		countInSetup = #SongDB.Songs[songID].Setups[ i ];
		if countInSetup <= playerCount then
			self:AddItemToList( countInSetup, self.listboxSetups, self.listboxSetupsWidth );
		end
	end
	self:AddItemToList( "A", self.listboxSetups, self.listboxSetupsWidth );
end


function SongbookWindow:ClearPlayerReadyStates( )
	if( self.aPlayers ~= nil ) then
		for k,v in pairs( self.aPlayers ) do
			self.aCurrentSongReady[ k ] = false;
		end
	end
end


function SongbookWindow:SetChiefMode( bState )
	self.bChiefMode = (bState==true)
	self.syncStartSlot:SetVisible( self.bChiefMode )
	self.syncStartIcon:SetVisible( self.bChiefMode )
end

-- ListBoxScrolled ----------------------------------------
-- a Listbox with child scrollbar and separator

function ListBoxScrolled:New( scrollWidth, listbox )
	listbox = listbox or ListBoxScrolled( scrollWidth );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

function ListBoxScrolled:Constructor( scrollWidth )
	Turbine.UI.ListBox.Constructor( self );
	self:SetMouseVisible( true );	
	self.scrollWidth = scrollWidth;
	self:CreateChildScrollbar( scrollWidth );
	self:CreateChildSeparator( scrollWidth );
end

function ListBoxScrolled:CreateChildScrollbar( width )
	self.scrollBar = Turbine.UI.Lotro.ScrollBar( );
	self.scrollBar:SetParent( self:GetParent( ) );
	self.scrollBar:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.scrollBar:SetZOrder( 320 );
	self.scrollBar:SetWidth( width );
	self.scrollBar:SetTop( 0 );
	self.scrollBar:SetValue( 0 );
	self:SetVerticalScrollBar( self.scrollBar );
	self.scrollBar:SetVisible( false );
end

function ListBoxScrolled:CreateChildSeparator( width )
	self.separator = Turbine.UI.Control( );
	self.separator:SetParent( self:GetParent( ) );
	self.separator:SetZOrder( 300 );
	self.separator:SetWidth( width );
	self.separator:SetTop( 0 );
	self.separator:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15));
	self.separator:SetVisible( false );
end
	
function ListBoxScrolled:SetLeft( xPos )
	Turbine.UI.ListBox.SetLeft( self, xPos );
	self.scrollBar:SetLeft( xPos + self:GetWidth( ) );
	self.separator:SetLeft( xPos + self:GetWidth( ) );
end
	
function ListBoxScrolled:SetTop( yPos )
	Turbine.UI.ListBox.SetTop( self, yPos );
	self.scrollBar:SetTop( yPos );
	self.separator:SetTop( yPos );
end
	
function ListBoxScrolled:SetPosition( xPos, yPos )
	self:SetLeft( xPos );
	self:SetTop( yPos );
end
	
function ListBoxScrolled:SetWidth( width )
	Turbine.UI.ListBox.SetWidth( self, width );
	self.scrollBar:SetLeft( self:GetLeft( ) + width );
	self.separator:SetLeft( self:GetLeft( ) + width );
end

function ListBoxScrolled:SetHeight( height )
	Turbine.UI.ListBox.SetHeight( self, height );
	self.scrollBar:SetHeight( height );
	self.separator:SetHeight( height );
end

function ListBoxScrolled:SetSize( width, height )
	self:SetWidth( width );
	self:SetHeight( height );
end

function ListBoxScrolled:SetVisible( bVisible )
	Turbine.UI.ListBox.SetVisible( self, bVisible );
	self.separator:SetVisible( bVisible );
	self.scrollBar:SetVisible( bVisible );
	if bVisible then self.scrollBar:SetParent( self:GetParent( ) )
	else self.scrollBar:SetParent( self ); end
end

function ListBoxScrolled:SetParent( parent )
	Turbine.UI.ListBox.SetParent( self, parent );
	self.separator:SetParent( parent );
	self.scrollBar:SetParent( parent );
end

-- /ListBoxScrolled ----------------------------------------


-- ListBoxReadyIndicator ----------------------------------------
-- A scroll listbox with an optional single-char column before the main column

function ListBoxCharColumn:New( scrollWidth, readyColWidth, listbox )
	listbox = listbox or ListBoxCharColumn( scrollWidth, readyColWidth );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

function ListBoxCharColumn:Constructor( scrollWidth, readyColWidth )
	ListBoxScrolled.Constructor( self, scrollWidth );
	self.readyColWidth = readyColWidth
	self.bShowReadyChars = true
	self.bHighlightReadyCol = true
end

function ListBoxCharColumn:EnableCharColumn( bColumn )
	if self.bShowReadyChars == bColumn then return; end

	self.bShowReadyChars = bColumn
	if ListBoxScrolled.GetItemCount( self ) == 0 then return; end

	local iList
	local itemCount = ListBoxScrolled.GetItemCount( self )
	if bColumn then -- Add a char item before every item in the list
		for iList = 1, itemCount * 2, 2 do
			local chItem = self:CreateCharItem( )
			ListBoxScrolled.InsertItem( self, iList, chItem )
		end
		self:SetMaxItemsPerLine( 2 )
	else -- remove every item with odd index (the char items)
		for iList = 1, itemCount / 2 do
			ListBoxScrolled.RemoveItemAt( self, iList )
		end
		self:SetMaxItemsPerLine( 1 )
	end
end

function ListBoxCharColumn:GetItem( iLine )
	if self.bShowReadyChars then iLine = iLine * 2; end
	return ListBoxScrolled.GetItem( self, iLine )
end

function ListBoxCharColumn:GetCharColumnItem( iLine )
	if not self.bShowReadyChars then return nil; end
	return ListBoxScrolled.GetItem( self, iLine * 2 - 1 )
end

function ListBoxCharColumn:SetColumnChar( iLine, ch, bHighlight )
	local charItem = self:GetCharColumnItem( iLine )
	if charItem then
		self:ApplyHighlight( charItem, bHighlight )
		charItem:SetText( ch )
	end
end

function ListBoxCharColumn:ApplyHighlight( charItem, bHighlight )
	if bHighlight and self.bHighlightReadyCol then
		charItem:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) )
		charItem:SetBackColor( Turbine.UI.Color( 1, 0.7, 0.7, 0.7 ) )
	else
		charItem:SetForeColor( Turbine.UI.Color( 1, 1, 1, 1 ) )
		charItem:SetBackColor( Turbine.UI.Color( 1, 0, 0, 0 ) )
	end
end

function ListBoxCharColumn:GetItemCount( )
	if self.bShowReadyChars then return math.floor( ListBoxScrolled.GetItemCount( self ) / 2 ); end
	return ListBoxScrolled.GetItemCount( self )
end

function ListBoxCharColumn:ClearItems( )
	ListBoxScrolled.ClearItems( self )
	if self.bShowReadyChars then self:SetMaxItemsPerLine( 2 )
	else self:SetMaxItemsPerLine( 1 ); end
	self:SetOrientation( Turbine.UI.Orientation.Horizontal )
end

function ListBoxCharColumn:CreateCharItem( )
	local charItem = Turbine.UI.Label( )
	charItem:SetMultiline( false )
	charItem:SetSize( self.readyColWidth, 20 )
	charItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter )
	self:ApplyHighlight( charItem, false )
	return charItem
end

function ListBoxCharColumn:AddItem( item )
	if self.bShowReadyChars then -- add ready indicator (single char in first column)
		local charItem = self:CreateCharItem( )
		ListBoxScrolled.AddItem( self, charItem )			
	end
	ListBoxScrolled.AddItem( self, item )
end

function ListBoxCharColumn:RemoveItemAt( i )
	if self.bShowReadyChars then
		ListBoxScrolled.RemoveItemAt( self, i * 2 )
		ListBoxScrolled.RemoveItemAt( self, i * 2 - 1 )
	else
		ListBoxScrolled.AddItem( self, i )
	end
end

-- /ListBoxReadyIndicator ----------------------------------------
	
	
function SongbookWindow:SetListboxColours( listbox, bNoSelectionHighlight )
	for i = 1,listbox:GetItemCount() do
		local item = listbox:GetItem( i );
		local SongIndex = self.aFilteredIndices[ i ];
		
		local ReadyState = self:GetSongReadyState( SongIndex );
		
		if ReadyState[0] == nil then
			item:SetForeColor( self.colourDefault );
			item:SetBackColor( self.backColourDefault );
		elseif ReadyState[0] == 10 then
			item:SetForeColor( self.colourSyncedHighlighted );
			if ReadyState[1] == "LocalPlayer" then
				item:SetBackColor( self.backColourHighlight );
			else
				item:SetBackColor( self.backColourDefault );
			end
		elseif ReadyState[0] == 0 then
			item:SetForeColor( self.colourReadyMultiple2 );
			if ReadyState[1] == "LocalPlayer" then
				item:SetBackColor( self.backColourHighlight );
			else
				item:SetBackColor( self.backColourDefault );
			end
		end
	end
	if bNoSelectionHighlight then return nil; end 
	local selectedItem = listbox:GetSelectedItem( )
	if selectedItem then selectedItem:SetForeColor( self.colourDefaultHighlighted ); end
	return selectedItem;
end

function SongbookWindow:CreateSeparator(left, top, width, height)
	local separator = Turbine.UI.Control();
	separator:SetParent(self.listContainer);
	separator:SetZOrder(300);
	separator:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15));
	separator:SetPosition( left, top );
	separator:SetSize(width,height);
	separator:SetVisible( false );
	return separator;
end

function SongbookWindow:CreateMainSeparator(top)
	return self:CreateSeparator(0, top, self.listContainer:GetWidth(), 13);
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

function SongbookWindow:CreateMainShortcut(left)
	local slot = Turbine.UI.Lotro.Quickslot();
	slot:SetParent(self);
	slot:SetPosition(left, 50 + ShiftTop);
	slot:SetSize(32, 30);
	slot:SetZOrder(100);
	slot:SetAllowDrop(false);
	slot:SetVisible( true );
	return slot;
end

function SongbookWindow:CreateMainIcon(left,sImageName)
	local icon = Turbine.UI.Control();
	icon:SetParent( self );
	icon:SetPosition(left, 50 + ShiftTop);
	icon:SetSize(35, 35);
	icon:SetZOrder(110);
	icon:SetMouseVisible(false);
	icon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	icon:SetBackground(gDir .. sImageName .. ".tga" );
	return icon;
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


function SongbookWindow:SetSonglistHeight( height )
	self.songlistBox:SetHeight( height );
	self.sepSongsTracks:SetTop(self.listContainer:GetHeight() - self.tracklistBox:GetHeight() - 13);
	self.listboxPlayers:SetHeight( height - 20 );
end

function SongbookWindow:AdjustSonglistHeight( )
	local height = self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13;
	if Settings.TracksVisible == "yes" then height = height - self.tracklistBox:GetHeight() - 13; end
	self:SetSonglistHeight( height )
end

function SongbookWindow:SetSonglistTop( top )
	self.songlistBox:SetTop( top );
	self.separator1:SetTop( top - 13 );
	self.btnParty:SetTop( top );
	self.listboxPlayers:SetTop( top + 20 );
end

function SongbookWindow:AdjustSonglistLeft( )
	local xPos = 0;
	if self.bFilter and self.bShowPlayers then xPos = xPos + 95; end
	self.songlistBox:SetLeft( xPos );
	self.songlistBox:SetWidth( self.listContainer:GetWidth( ) - xPos - 10 );
end

function SongbookWindow:AdjustSonglistPosition( )
	self:AdjustSonglistLeft( )
	self:SetSonglistTop( self.dirlistBox:GetHeight() + 13 )
	self.separator1:SetWidth( self.listContainer:GetWidth() );
	self.sArrows1:SetLeft( self.separator1:GetWidth() / 2 - 10 );
end

function SongbookWindow:AdjustDirlistSize( )
	local width = self.listContainer:GetWidth( ) - 10;
	local height = self.listContainer:GetHeight() - self.songlistBox:GetHeight() - 13;

	if self.bFilter then width = width - 170; end
	if Settings.TracksVisible == "yes" then height = height - Settings.TracksHeight - 13; end

	self.dirlistBox:SetSize( width, height );
end

function SongbookWindow:AdjustDirlistPosition( )
	local xPos = 0;
	if self.bFilter then xPos = xPos + 170; end
	self.dirlistBox:SetPosition( xPos , 0 );
	self.dirlistBox:SetWidth( self.listContainer:GetWidth( ) - xPos - 10 );
end

function SongbookWindow:ShowTrackListbox( bShow )
	self.tracklistBox:SetVisible( bShow );
	self.sepSongsTracks:SetVisible( bShow );
	self.sArrows2:SetVisible( bShow );		
end

function SongbookWindow:SetTracklistTop( top )

	if top < self.songlistBox:GetTop() + 13 + 40 then
		top = self.songlistBox:GetTop() + 13 + 40;
	end	
		
	self.tracklistBox:SetTop( top )
	self.sepSongsTracks:SetTop( top - 13 )
	self.listboxSetups:SetTop( top );
	self.tracksMsg:SetTop( top - 15 - 3 );
end

function SongbookWindow:MoveTracklistTop( delta )
	self:SetTracklistTop( self.tracklistBox:GetTop( ) + delta )
end

function SongbookWindow:AdjustTracklistLeft( )
	if self.bShowSetups then self.tracklistBox:SetLeft( self.setupsWidth )
	else self.tracklistBox:SetLeft( 0 ) end
end

function SongbookWindow:AdjustTracklistWidth( )
	local width = self.listContainer:GetWidth( ) - 10
	if self.bShowSetups then width = width - self.setupsWidth end
	self.tracklistBox:SetWidth( width )
	--if self.alignTracksRight == true then self:AdjustTracklistItemsPosition( width ) end
	if self.alignTracksRight == true then self:RealignTracknames( ) end
	self.sepSongsTracks:SetWidth( self.listContainer:GetWidth( ) )
	self.sArrows2:SetLeft( self.sepSongsTracks:GetWidth() / 2 - 10 )
	self.tracksMsg:SetLeft( self.tracklistBox:GetLeft( ) + width - self.tracksMsg:GetWidth( ) )
end

function SongbookWindow:AdjustTracklistItemsPosition( width )
	for i = 1, self.tracklistBox:GetItemCount( ) do
		local item = self.tracklistBox:GetItem( i )
		item:SetLeft( width - 1000 )
	end
end

function SongbookWindow:SetTracklistHeight( height )
	self.tracklistBox:SetHeight( height )			
	self.listboxSetups:SetHeight( height );
end

function SongbookWindow:AdjustTracklistSize( height )
	self:AdjustTracklistWidth( )
	self:SetTracklistHeight( height )
end

function SongbookWindow:UpdateTracklistTop( )
	self:SetTracklistTop( self.listContainer:GetHeight() - self.tracklistBox:GetHeight() )
end

function SongbookWindow:ShowSetups( bShow )
	if bShow and not self.bShowSetups then 
		self.bShowSetups = true
		self.listboxSetups:SetVisible( true )
		self:AdjustTracklistLeft( )
		self:AdjustTracklistWidth( )
	elseif not bShow and self.bShowSetups then 
		self.bShowSetups = false
		self.listboxSetups:ClearItems( )
		self.listboxSetups:SetVisible( false )
		self:AdjustTracklistLeft( )
		self:AdjustTracklistWidth( )
	end
end


function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

function RemoveCallback(object, event, callback)
    if (object[event] == callback) then
        object[event] = nil;
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event]);
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i);
                    break;
                end
            end
        end
    end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- action for changing track selection (trackid is listbox index)
function SongbookWindow:SelectTrack( trackid )
	if self.bShowReadyChars then trackid = math.floor( (trackid+1) / 2 ); end
	selectedTrack = trackid;
	local iTrack = self:SelectedTrackIndex( trackid );
	local trackcount = #SongDB.Songs[selectedSongIndex].Tracks;

	if selectedTrack > 1 then
		if selectedTrack == trackcount then
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( false );
		else
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( true );
		end
	end
	if ( selectedTrack == 1) then
		self.trackPrev:SetVisible( false );
		if (trackcount == 1) then		
			self.trackNext:SetVisible( false );
		else
			self.trackNext:SetVisible( true );
		end
	end

	self.trackNumber:SetText(SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id);
	self.songTitle:SetText(SongDB.Songs[selectedSongIndex].Tracks[iTrack].Name);

	self.playSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id);
	self.playSlot:SetShortcut( self.playSlotShortcut );
	self.playSlot:SetVisible( true );

	self.syncSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id .. " " .. Strings["cmd_sync"]);
	self.syncSlot:SetShortcut( self.syncSlotShortcut );
	self.syncSlot:SetVisible( true );
	
	self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
	self.shareSlot:SetVisible( true );
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self:PlayerSyncInfo();
	
	if YouDontHaveTheSameSong_Flag == 0 then
		
		if OtherPlayer_SyncedSong_Filepath .. OtherPlayer_SyncedSong_Filename == SongDB.Songs[selectedSongIndex].Filepath .. selectedSong then
			self.syncMessageTitle:SetVisible(false);
		else
			if OtherPlayer_SyncedSong_Filepath .. OtherPlayer_SyncedSong_Filename ~= "" then
				if self.syncMessageTitle:GetText() ~= "" then
					self.syncMessageTitle:SetVisible(true);
				end
			end
		end
	end
	
	self:SetTrackColours( selectedTrack );
end


-- action for setting focus on the track list
function SongbookWindow:SetTrackColours( iSelectedTrack )
	if not self.tracklistBox or self.tracklistBox:GetItemCount( ) < 1 then return; end
	self:ClearPlayerReadyStates( ); -- Clear ready states for currently displayed song
	local trackcount = #SongDB.Songs[selectedSongIndex].Tracks;
	
	local numberOfCorrectStates = 0;
	for iTrack = 1,trackcount do
		if self.iCurrentSetup and not self.aSetupListIndices[ iTrack ] then
			self:GetTrackReadyState( selectedSongIndex, iTrack, 3 );
		else
			local iList = iTrack;
			if self.aSetupListIndices[ iTrack ] then iList = self.aSetupListIndices[ iTrack ]; end
			local item = self.tracklistBox:GetItem(iList);
			local readyState = self:GetTrackReadyState( selectedSongIndex, iTrack );
			
			
			if readyState[0] == 10 then numberOfCorrectStates = numberOfCorrectStates + 1; end
			
			item:SetForeColor( self:GetColourForTrack( readyState[0], iList == iSelectedTrack ) );
			item:SetBackColor( self:GetBackColourForTrack( readyState[0] , readyState[1] , readyState[8] ) );
			
			
			self:SetTrackReadyChar( iList, readyState[0] );
			
			local sTerseName = self:TerseTrackname( SongDB.Songs[selectedSongIndex].Tracks[iTrack].Name );
			local Track_Instrument = self:FindInstrumentInTrack( sTerseName );
			local Track_item = SyncInfolistbox:GetItem(iTrack);
			Track_item:SetText( "[" .. SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id .. "] " .. Track_Instrument[1] );
			
			Track_item:SetForeColor( self:GetColourForTrack( readyState[0], iList == iSelectedTrack ) );
			Track_item:SetBackColor( self:GetBackColourForTrack( readyState[0] , readyState[1] , readyState[8] ) );
						
			for i = 0, readyState[4]-1 do
				if tonumber( readyState[3][i] ) > 0 then
					Track_item:AppendText("  - <rgb=0x00FF00>" .. readyState[2][i] .. "</rgb> [<rgb=0x00FF80>" .. 
						self.Instruments_List[tonumber( readyState[3][i] )] .. "</rgb>]" );
				else
					Track_item:AppendText("  - <rgb=0x00FF00>" .. readyState[2][i] .. "</rgb> [<rgb=0x00FF80>No Instrument</rgb>]" );
				end
			end
			
			for i = 0, readyState[7]-1 do
				if tonumber( readyState[6][i] ) > 0 then
					Track_item:AppendText("  - <rgb=0xFF0000>" .. readyState[5][i] .. "</rgb> [<rgb=0xFF0080>" .. 
						self.Instruments_List[tonumber( readyState[6][i] )] .. "</rgb>]" );
				else
					Track_item:AppendText("  - <rgb=0xFF0000>" .. readyState[5][i] .. "</rgb> [<rgb=0xFF0080>No Instrument</rgb>]" );
				end
			end
			
			for i = 0, readyState[8]-1 do
				Track_item:AppendText("  - <rgb=0xFFFF00>" .. readyState[9][i] .. "</rgb>" );
			end
		end
	end
	
	if numberOfCorrectStates == trackcount then
		SyncStartWindow_ShowFlag = 0;
		self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"] );
		self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut );
		self.syncStartSlot:SetVisible( true );
	else
		SyncStartWindow_ShowFlag = 1;
		SyncStartWindow.Message:SetText("Some parts don't have correct state. Do you want to start?");
		SyncStartWindow.YesSlot:SetVisible( true );
		SyncStartWindow.NoSlot:SetVisible( true );
		SyncStartWindow.YesIcon:SetVisible( true );
		SyncStartWindow.NoIcon:SetVisible( true );
		
		self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined , "" );
		self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut );
		self.syncStartSlot:SetVisible( true );
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- action for setting focus on the track list
function SongbookWindow:PlayerSyncInfo()
	if not self.sendSyncInfoSlot then return; end
	
	local trackcount = #SongDB.Songs[selectedSongIndex].Tracks;
	local Track_Name = SongDB.Songs[selectedSongIndex].Tracks[selectedTrack].Name; 

	local equippedInstrument_Index = self:UpdatePlayerTitle();
	if equippedInstrument_Index == nil then return; end
	local Track_Instrument = self:FindInstrumentInTrack( Track_Name );
	local Track_Instrument_Index = Track_Instrument[0];
	local CorrectInstrument = self:CompareInstrument (equippedInstrument_Index, Track_Instrument_Index);
	
	-------------------------------------------------------
	
	local CorrectSongAndTrack = 1;
	if selectedSongIndex ~= syncedSongIndex or selectedTrack ~= syncedTrack then
		CorrectSongAndTrack = 0;
	end
	
	local Party = self.playerInstance:GetParty();
	local PartyMemberCount = 0;
	if Party ~= nil then PartyMemberCount = Party:GetMemberCount(); end
	

	if self.UseFellowshipChat then
		Chatchannel = "/f";
		self.MessageTitle:SetText("SongBook is using Fellowship channel");
	else
	if self.UseRaidChat then
		Chatchannel = "/ra";
		self.MessageTitle:SetText("SongBook is using Raid channel");
	else
		if UserChatNumber ~= 0 and UserChatNumber ~= nil then
			Chatchannel = "/" .. UserChatNumber;
			self.MessageTitle:SetText("SongBook is using User Chat channel " .. UserChatNumber .. " - " .. UserChatName);
		else
			if PartyMemberCount > 6 or GroupIsRaid == 1 then
				Chatchannel = "/ra";
				if PlayerCantUseUserChat_Message == 0 then
					self.MessageTitle:SetText("SongBook is using Raid channel");
				elseif PlayerCantUseUserChat_Message == 1 then
					songbookWindow.MessageTitle:SetText("Low level to use User chat. Now using Raid channel");
				end
			elseif PartyMemberCount > 1 then
				Chatchannel = "/f";
				if PlayerCantUseUserChat_Message == 0 then 
					self.MessageTitle:SetText("SongBook is using Fellowship channel");
				elseif PlayerCantUseUserChat_Message == 1 then
					songbookWindow.MessageTitle:SetText("Low level to use User chat. Now using Fellowship channel");
				end
			end
		end
	end
	end
	
	if CorrectSongAndTrack == 1 and PlayerSynced == 1 then
	
		self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Chatchannel .. " <rgb=#211f1d>@SBL|" .. self.Player_Name .. "|" .. SongDB.Songs[selectedSongIndex].Filename .. "|" .. Track_Name .. "|" .. PlayerSynced .. "|" .. CorrectSongAndTrack .. "|" .. trackcount .. "|" .. selectedSongIndexListBox .. "|" .. selectedSongIndex .. "|" .. selectedTrack .. "|" .. Track_Instrument_Index .. "|".. equippedInstrument_Index .. "|" .. CorrectInstrument .. "|</rgb>");
		self.sendSyncInfoSlot:SetShortcut( self.sendSyncInfoSlotShortcut );
		self.sendSyncInfoSlot:SetVisible( true );
	else
		self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "");
		self.sendSyncInfoSlot:SetShortcut( self.sendSyncInfoSlotShortcut );
		self.sendSyncInfoSlot:SetVisible( true );
	end
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- return track colour based on readyState retrieved from GetTrackReadyState(...)
function SongbookWindow:GetColourForTrack( readyState, bSelectedTrack )
	if bSelectedTrack then
		if not readyState then -- track not ready
			return self.colourDefaultHighlighted;
		else
			if readyState == 0 then -- track is ready by more than one player
				return self.colourReadyMultipleHighlighted;
			elseif readyState == 1 then -- track is synced but wrong or not ready yet
				return self.colourSyncedHighlighted;
			elseif readyState == 2 then -- track is ready by more than one player and is synced
				return self.colourReadyMultipleHighlighted_synced;
			elseif readyState == 3 then -- track is synced with wrong instrument
				return self.colourWrongInstrument_synced;
			elseif readyState == 4 then -- track is ready by more than one player and is synced with wrong instrument
				return self.colourWrongInstrumentMultiple;
			elseif readyState == 5 then -- track is ready with wrong instrument
				return self.colourWrongInstrument;
			elseif readyState == 6 then -- track is ready by more than one player wrong instrument
				return self.colourWrongInstrumentMultiple_synced;
			else -- track ready by one player
				return self.colourReadyHighlighted;
			end
		end
	else
		if not readyState then
			return self.colourDefault;
		else
			if readyState == 0 then
				return self.colourReadyMultiple;
			elseif readyState == 1 then
				return self.colourSyncedHighlighted_notSelected;
			elseif readyState == 2 then
				return self.colourReadyMultipleHighlighted_synced_notSelected;
			elseif readyState == 3 then
				return self.colourWrongInstrument_notSelected_synced;
			elseif readyState == 4 then
				return self.colourWrongInstrumentMultiple_notSelected;
			elseif readyState == 5 then
				return self.colourWrongInstrument_notSelected;
			elseif readyState == 6 then
				return self.colourWrongInstrumentMultiple_synced_notSelected;
			else
				return self.colourReady;
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- background colour indicates the track one has ready
function SongbookWindow:GetBackColourForTrack( readyState, playerName , readyState8)
	if readyState8 >= 1 then
		if playerName == "LocalPlayer" then
			return self.backColour_synced_multiple;
		elseif readyState == 10 and playerName == self.sPlayerName then
			return self.backColour_synced_multiple;
		elseif readyState8 > 1 then
			return self.backColour_synced_multiple;
		else
			return self.backColour_synced;
		end
	end
	
	if not readyState then
		return self.backColourDefault;
	elseif playerName == "LocalPlayer" then
		return self.backColourHighlight;
	elseif readyState == 0 then
		--return self.backColourHighlight_Multiple;
		return self.backColourDefault;
	elseif readyState == 1 then
		--return self.backColourHighlight_wrong;
		return self.backColourDefault;
	elseif readyState == 2 then
		--return self.backColourHighlight_Multiple_synced;
		return self.backColourDefault;
	elseif readyState == 3 then
		--return self.backColourWrongInstrument;
		return self.backColourDefault;
	elseif readyState == 4 then
		--return self.backColourWrongInstrument;
		return self.backColourDefault;
	elseif readyState == 5 then
		--return self.backColourWrongInstrument_ready;
		return self.backColourDefault;
	elseif readyState == 6 then
		--return self.backColourWrongInstrument_ready;
		return self.backColourDefault;
	elseif readyState == 10 and playerName == self.sPlayerName then
		--return self.backColourHighlight_self;
		return self.backColourHighlight;
	else
		return self.backColourDefault;
	end
	--if self.bInstrumentOk then return self.backColourHighlight; end
	--return self.backColourWrongInstrument
end	

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- Handler for chat messages to indicate players readying tracks
function ChatHandler( sender, args )
	local sMessage = args.Message;
	if sMessage == nil or songbookWindow == nil then return; end
	
	if args.ChatType == Turbine.ChatType.Error then
		if string.find( sMessage, "You are not in a Raid." ) ~= nil then
			songbookWindow.MessageTitle:SetText("You are not in a Raid.");
			GroupIsRaid = 0;
		end
		
		return;
	end
	
	if( args.ChatType == Turbine.ChatType.UserChat1 or args.ChatType == Turbine.ChatType.UserChat2  or
		args.ChatType == Turbine.ChatType.UserChat3 or args.ChatType == Turbine.ChatType.UserChat4  or
		args.ChatType == Turbine.ChatType.UserChat5 or args.ChatType == Turbine.ChatType.UserChat6  or
		args.ChatType == Turbine.ChatType.UserChat7 or args.ChatType == Turbine.ChatType.UserChat8  or
		args.ChatType == Turbine.ChatType.Raid		or args.ChatType == Turbine.ChatType.Fellowship	
	) then
		
		if string.find( sMessage, "raid chat is now available." ) ~= nil then
			GroupIsRaid = 1;
			Chatchannel = "/ra";
			songbookWindow:PlayerSyncInfo();
			return;
		end
		
		if string.find( sMessage, "You left room '" .. UserChatName .. "'" ) ~= nil then
			UserChatNumber = 0;
			CharSettings.UserChatNumber = 0;
			songbookWindow:PlayerSyncInfo();
			return;
		end
		
		if  string.match( sMessage, "uc(%d+): '" .. UserChatName .. "'" ) ~= nil then 
			UserChatNumber =  string.match( sMessage, "uc(%d+): '" .. UserChatName .. "'" );
			CharSettings.UserChatNumber = UserChatNumber;
			songbookWindow:PlayerSyncInfo();
			return;
		end
		
		if string.find( sMessage, "@SBL" ) then
			
			local sPlayerName, Filename, TrackName, SyncStatus, CorrectSongAndTrack, NumberOfParts, SongIndexListBox, SongIndex_OtherPlayer, TrackIndex, neededInstrument, equippedInstrument_Index, CorrectInstrument = string.match( sMessage, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|' );
			
			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			local PlayerIsInParty_Flag = 0;
			
			if( songbookWindow.aPlayers ~= nil ) then
				for k,v in pairs( songbookWindow.aPlayers ) do
					if k == sPlayerName then
						PlayerIsInParty_Flag = 1;
						break;
					end
				end
			end
			
			if PlayerIsInParty_Flag == 0 then return; end
			
			--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
			local SongIndex = songbookWindow:Find_OtherPlayer_SyncedSong_Index (Filename, TrackName, NumberOfParts) ;
			
			if sPlayerName ~= nil then
				
				OtherPlayer_Synced = 0;
				if sPlayerName ~= songbookWindow.sPlayerName then
					songbookWindow:Update_syncMessage(SongIndex, sPlayerName, TrackName);
				end
				
				if not songbookWindow.aPlayers[ sPlayerName ] then --- Player not yet registered 
					songbookWindow.nPlayers = songbookWindow.nPlayers + 1;
					songbookWindow:AddPlayerToList( sPlayerName ); -- add to player listbox
					songbookWindow:UpdateMaxPartCount( );
				end
				
				songbookWindow.aPlayers[ sPlayerName ] = "|" .. sPlayerName .. "|" .. SyncStatus .. "|" .. CorrectSongAndTrack .. "|" .. SongIndex[0] .. "|" .. TrackIndex .. "|" .. equippedInstrument_Index .. "|" .. CorrectInstrument .. "|"; -- and to player array with the track info
				
				songbookWindow.Players_Data[ sPlayerName ] = SongIndex;
				
				songbookWindow:SetListboxColours( songbookWindow.songlistBox );
				songbookWindow:SetTrackColours( selectedTrack );
				songbookWindow:SetPlayerColours( );
				songbookWindow:UpdateSetupColours( );
			end
		end
		
		return;
	end
	
-----------------------------------------------------------------------------------

	if( args.ChatType ~= Turbine.ChatType.Standard ) then
		return; -- Player ready messages appear in the standard chat
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if string.find( sMessage, "You have joined a Fellowship." ) ~= nil then
		songbookWindow.playerInstance = Turbine.Gameplay.LocalPlayer:GetInstance( );
		local Party = songbookWindow.playerInstance:GetParty();
		local PartyMemberCount = 0;
		if Party ~= nil then PartyMemberCount = Party:GetMemberCount(); end
		
		if PartyMemberCount > 1 then
			for i = 1, PartyMemberCount do
				local PartyMember = Party:GetMember(i);
				local MemberName  = PartyMember:GetName();
				if songbookWindow.aPlayers[ MemberName ] == nil then songbookWindow:AddPlayer( MemberName ); end
			end
		end
		
		--songbookWindow.MessageTitle:SetText("You have joined a Fellowship.");
		Chatchannel = "/f";
		GroupIsRaid = 0;
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
	if string.find( sMessage, "You have joined a Raid." ) ~= nil then
		songbookWindow.playerInstance = Turbine.Gameplay.LocalPlayer:GetInstance( );
		local Party = songbookWindow.playerInstance:GetParty();
		local PartyMemberCount = 0;
		if Party ~= nil then PartyMemberCount = Party:GetMemberCount(); end
		
		if PartyMemberCount > 1 then
			for i = 1, PartyMemberCount do
				local PartyMember = Party:GetMember(i);
				local MemberName  = PartyMember:GetName();
				if songbookWindow.aPlayers[ MemberName ] == nil then songbookWindow:AddPlayer( MemberName ); end
			end
		end
		
		--songbookWindow.MessageTitle:SetText("You have joined a Raid.");
		GroupIsRaid = 1;
		Chatchannel = "/ra";
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
	if string.find( sMessage, "You joined room '" .. UserChatName .. "'" ) ~= nil then
		UserChatNumber = string.match( sMessage, 'UserChat(%d+)' );
		CharSettings.UserChatNumber = UserChatNumber;
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
	if string.find( sMessage, "You are already in room '" .. UserChatName .. "'" ) ~= nil then
		songbookWindow.MessageTitle:SetText("You are already in room '" .. UserChatName .. "'. Use recover button to find it.");
		return;
	end
	
	if string.find( sMessage, "You are not in room '" .. UserChatName .. "'" ) ~= nil then
		UserChatNumber = 0;
		CharSettings.UserChatNumber = 0;
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
	if string.find( sMessage, "You are already in 8 rooms, which is the maximum allowed" ) ~= nil then
		songbookWindow.MessageTitle:SetText("You are already in 8 rooms, which is the maximum allowed");
		return;
	end
	
	if string.find( sMessage, "You haven't played this character for long enough to use this chat channel." ) ~= nil then
		UserChatNumber = 0;
		CharSettings.UserChatNumber = 0;
		PlayerCantUseUserChat_Message = 1;
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
	if string.find( sMessage, "Your Raid has been disbanded." ) ~= nil then
		songbookWindow.MessageTitle:SetText("Your Raid has been disbanded.");
		Chatchannel = "/f";
		GroupIsRaid = 0;
		return;
	end
	
	if string.find( sMessage, "dismiss" ) ~= nil then
		if string.find( sMessage, "You have been dismissed from your" ) ~= nil then
			songbookWindow.MessageTitle:SetText("You have been dismissed.");
			Chatchannel = "/f";
			GroupIsRaid = 0;
			return;
		end
		
		if string.find( sMessage, "You dismiss" ) ~= nil then
			local temp, sPlayerName;
			temp, temp, sPlayerName = string.find( sMessage, "You dismiss (%a+)" );
			if sPlayerName then songbookWindow:RemovePlayer( sPlayerName ); end
			
			songbookWindow:PlayerSyncInfo();
		
			local PartyMemberCount = 0;
			if( songbookWindow.aPlayers ~= nil ) then
				for k,v in pairs( songbookWindow.aPlayers ) do
					PartyMemberCount = PartyMemberCount + 1;
				end
			end
			
			if PartyMemberCount == 1 then
				songbookWindow.MessageTitle:SetText("You dismiss party.");
				Chatchannel = "/f";
				GroupIsRaid = 0;
				return;
			end
			
			return;
		end
		
		local temp, sPlayerName;
		temp, temp, sPlayerName = string.find( sMessage, "(%a+) has been dismissed from your" );
		if sPlayerName then songbookWindow:RemovePlayer( sPlayerName ); end
		songbookWindow:PlayerSyncInfo();
		return;
	end
	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if string.find( sMessage, Strings["chat_playBegin"] ) ~= nil or string.find( sMessage, Strings["chat_playBeginSelf"] ) ~= nil then
		
		local temp, temp, TrackName = string.find( sMessage, Strings["chat_playBeginSelf"] .. "\"(.+).\".*" );
		if TrackName then
			Synced_Song_TrackName = TrackName;
		end
		songbookWindow:SongStarted( );
		return;
	end

	if string.find( sMessage, Strings["chat_playerJoin"] ) ~= nil then
		songbookWindow:PlayerJoined( sMessage );
		return;
	end
	if string.find( sMessage, Strings["chat_playerLeave"] ) ~= nil then
		songbookWindow:PlayerLeft( sMessage );
		return;
	end
	
	local temp, sPlayerName, sTrackName;
	temp, temp, sPlayerName, sTrackName = string.find( sMessage, Strings["chat_playReadyMsg"] );
	if not sPlayerName or not sTrackName then
		sPlayerName = songbookWindow.sPlayerName;
		temp, temp, sTrackName = string.find( sMessage, Strings["chat_playSelfReadyMsg"] );
	end
	
	-- if sTrackName then
		-- Synced_Song_TrackName = sTrackName;
	-- end
	
	if sPlayerName and sTrackName and songbookWindow.aPlayers then
		if sPlayerName == songbookWindow.sPlayerName and songbookWindow.sPlayerName then
			
			Synced_Song_TrackName = sTrackName;
			
			--songbookWindow.aPlayers_sync_msg[ songbookWindow.sPlayerName ] = sTrackName;
			--songbookWindow.aPlayers[ songbookWindow.sPlayerName ] = "|sync_msg|" .. sTrackName .. "|";
			songbookWindow.aPlayers[ songbookWindow.sPlayerName ] = sTrackName;
			
			--local SongIndex = songbookWindow:Find_OtherPlayer_SyncedSong_Index_WithOnlySync(sTrackName);
			--OtherPlayer_Synced = 1;
			--songbookWindow:Update_syncMessage(SongIndex, sPlayerName, sTrackName);
			
			songbookWindow:SetListboxColours( songbookWindow.songlistBox );
			songbookWindow:SetTrackColours( selectedTrack );
			songbookWindow:SetPlayerColours( );
			songbookWindow:UpdateSetupColours( );
			PlayerSynced = 1;
			songbookWindow:PlayerSyncInfo();
		else
			if songbookWindow.aPlayers[ sPlayerName ] ~= nil then
				
				--songbookWindow.aPlayers_sync_msg[ sPlayerName ] = sTrackName;
				--songbookWindow.aPlayers[ sPlayerName ] = "|sync_msg|" .. sTrackName .. "|";
				songbookWindow.aPlayers[ sPlayerName ] = sTrackName;
				
				local SongIndex = songbookWindow:Find_OtherPlayer_SyncedSong_Index_WithOnlySync(sTrackName);
				OtherPlayer_Synced = 1;
				songbookWindow:Update_syncMessage(SongIndex, sPlayerName, sTrackName);
				
				songbookWindow:SetListboxColours( songbookWindow.songlistBox );
				songbookWindow:SetTrackColours( selectedTrack );
				songbookWindow:SetPlayerColours( );
				songbookWindow:UpdateSetupColours( );
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- Return a track state indicator: 
-- nil = track not ready, name of a player = ready by this player, 0 = ready by more than one player
function SongbookWindow:GetTrackReadyState( sSongIndex, sTrackIndex,  indicator )
	local ReadyState = {};
	ReadyState[0] = nil;
	ReadyState[1] = nil;
	ReadyState[2] = nil;
	ReadyState[3] = nil;
	ReadyState[4] = nil;
	ReadyState[5] = nil;
	ReadyState[6] = nil;
	ReadyState[7] = nil;
	ReadyState[8] = nil;
	ReadyState[9] = nil;
	local readyIndicator = 1;
	if indicator then readyIndicator = indicator; end
	
	local SyncedPlayersCounter = 0;
	local SyncedPlayersNames = {};
	local ReadyPlayersCounter = 0;
	local ReadyPlayersNames = {};
	local ReadyPlayersEquippedInstrument_Index = {};
	local WrongPlayersCounter = 0;
	local WrongPlayersNames = {};
	local WrongPlayersEquippedInstrument_Index = {};
	
	local SyncedPlayer = 0;
	
	if( self.aPlayers ~= nil ) then
		for k,v in pairs( self.aPlayers ) do
			
			v = string.gsub( v, "%s+", "" );
			
			local sPlayerName, SyncStatus, CorrectSongAndTrack, SongIndex, TrackIndex, equippedInstrument_Index, CorrectInstrument =  string.match( v, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|' );
			
			local Track_Name = SongDB.Songs[sSongIndex].Tracks[sTrackIndex].Name;
			
			if string.gsub( string.sub( Track_Name, 1, 63 ) , "%s+", "" ) == v or
			   string.gsub( string.sub( Track_Name, 1, -2 ) , "%s+", "" ) == v
			then
				SyncedPlayersNames[SyncedPlayersCounter] = k;
				SyncedPlayersCounter = SyncedPlayersCounter + 1;
			end
						
			local SongIndex_Synced = 0;
			
			if self.Players_Data[ k ] ~= nil then
			if self.Players_Data[ k ] ~= 0 then
			if self.Players_Data[ k ][0] ~= 0 then
				for i = 1, self.Players_Data[ k ][0] do
					if sSongIndex == self.Players_Data[ k ][i] then
						SongIndex_Synced = 1;
					end
				end
			end
			end
			end
			
			if SongIndex_Synced == 1 and sTrackIndex == tonumber(TrackIndex) and
			   tonumber(CorrectSongAndTrack) == 1 and tonumber(SyncStatus) == 1 then
				
				if sPlayerName == songbookWindow.sPlayerName then
					ReadyState[1] = "LocalPlayer";
				end

				if tonumber(CorrectInstrument) == 1 then
					ReadyPlayersNames[ReadyPlayersCounter] = k;
					ReadyPlayersEquippedInstrument_Index[ReadyPlayersCounter] = equippedInstrument_Index;
					ReadyPlayersCounter = ReadyPlayersCounter + 1;
				else
					WrongPlayersNames[WrongPlayersCounter] = k;
					WrongPlayersEquippedInstrument_Index[WrongPlayersCounter] = equippedInstrument_Index;
					WrongPlayersCounter = WrongPlayersCounter + 1;
				end
			else
				if sSongIndex == syncedSongIndex and  sTrackIndex == syncedTrack and k == songbookWindow.sPlayerName then
					
					--------------------------------------------------------------------
					local Track_Name = SongDB.Songs[sSongIndex].Tracks[sTrackIndex].Name; 

					local equippedInstrument_Index = self:UpdatePlayerTitle();
					local Track_Instrument = self:FindInstrumentInTrack( Track_Name );
					local Track_Instrument_Index = Track_Instrument[0];
					local CorrectInstrument = self:CompareInstrument (equippedInstrument_Index, Track_Instrument_Index);
					
					-------------------------------------------------------
					
					if CorrectInstrument == 1 then
						SyncedPlayer = 1;
					else
						SyncedPlayer = 2;
					end
				end
			end
		end
	end
	
	if ReadyPlayersCounter == 1 and SyncedPlayer == 0 and WrongPlayersCounter == 0 then
		ReadyState[0] = 10;
		self.aCurrentSongReady[ ReadyPlayersNames[0] ] = readyIndicator;
	elseif ReadyPlayersCounter > 1 and SyncedPlayer == 0 and WrongPlayersCounter == 0 then
		ReadyState[0] = 0;
		for i = 0, ReadyPlayersCounter-1, 1 do
			self.aCurrentSongReady[ ReadyPlayersNames[i] ] = 2;
		end
	elseif WrongPlayersCounter == 1 and ReadyPlayersCounter == 0 and SyncedPlayer == 0 then
		ReadyState[0] = 5;
	elseif WrongPlayersCounter >= 1 and ReadyPlayersCounter >= 0 and SyncedPlayer == 0 then
		ReadyState[0] = 4;
	elseif SyncedPlayer == 1 and ReadyPlayersCounter == 0 and WrongPlayersCounter == 0 then
		ReadyState[0] = 1;
	elseif SyncedPlayer == 1 and ReadyPlayersCounter >= 1 and WrongPlayersCounter == 0 then
		ReadyState[0] = 2;
	elseif SyncedPlayer == 1 and ReadyPlayersCounter >= 0 and WrongPlayersCounter >= 1 then
		ReadyState[0] = 6;
	elseif SyncedPlayer == 2 and ReadyPlayersCounter >= 1 and WrongPlayersCounter == 0 then
		ReadyState[0] = 6;
	elseif SyncedPlayer == 2 and ReadyPlayersCounter >= 0 and WrongPlayersCounter >= 1 then
		ReadyState[0] = 6;
	elseif SyncedPlayer == 2 and ReadyPlayersCounter == 0 and WrongPlayersCounter == 0 then
		ReadyState[0] = 3;
	end
	
	
	ReadyState[2] = ReadyPlayersNames;
	ReadyState[3] = ReadyPlayersEquippedInstrument_Index;
	ReadyState[4] = ReadyPlayersCounter;
	ReadyState[5] = WrongPlayersNames;
	ReadyState[6] = WrongPlayersEquippedInstrument_Index;
	ReadyState[7] = WrongPlayersCounter;
	
	ReadyState[8] = SyncedPlayersCounter;
	ReadyState[9] = SyncedPlayersNames;
	
	return ReadyState;
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:GetSongReadyState( sSongIndex )
	local ReadyState = {};
	ReadyState[0] = nil;
	ReadyState[1] = nil;

	local ReadyPlayersCounter = 0;
	local ReadyPlayersNames = {};
	
	local SyncedPlayer = 0;
			
	if( self.aPlayers ~= nil ) then
		for k,v in pairs( self.aPlayers ) do
			
			v = string.gsub( v, "%s+", "" );
			
			local sPlayerName, SyncStatus, CorrectSongAndTrack, SongIndex, TrackIndex, equippedInstrument_Index, CorrectInstrument =  string.match( v, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|' );
			
					
			local SongIndex_Synced = 0;
			
			if self.Players_Data[ k ] ~= nil then
			if self.Players_Data[ k ] ~= 0 then
			if self.Players_Data[ k ][0] ~= 0 then
				for i = 1, self.Players_Data[ k ][0] do
					if sSongIndex == self.Players_Data[ k ][i] then
						SongIndex_Synced = 1;
					end
				end
			end
			end
			end
			
			if SongIndex_Synced == 1 and tonumber(SyncStatus) == 1 then
			   
				if sPlayerName == songbookWindow.sPlayerName then
					ReadyState[1] = "LocalPlayer";
				end
				
				ReadyPlayersNames[ReadyPlayersCounter] = k;
				ReadyPlayersCounter = ReadyPlayersCounter + 1;
			end
		end
	end
	
	if ReadyPlayersCounter == 1 then
		ReadyState[0] = 10;
		--ReadyState[1] = ReadyPlayersNames[0];
	elseif ReadyPlayersCounter > 1 then
		ReadyState[0] = 0;
	end
	
	return ReadyState;
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Activated(sender, args)
	
	self:UpdatePlayerTitle();
	
	local width, height = self:GetSize();
	local left , top    = self:GetPosition();
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	
	local changeFlag = 0;
	-- Fix to prevent window to travel outside of the screen
	if width + 0 > displayWidth then
		width = displayWidth - 0;
		changeFlag = 1;
	end
	if height + 0 > displayHeight then
		height = displayHeight - 0;
		changeFlag = 1;
	end
	if left + width > displayWidth then
		left = displayWidth - width;
		changeFlag = 1;
	end
	if top + height > displayHeight then
		top = displayHeight - height;
		changeFlag = 1;
	end
	if left < 0 then
		left = 0;
		changeFlag = 1;
	end
	if top < 0 then
		top = 0;
		changeFlag = 1;
	end	
	
	Settings.WindowPosition.Left = left;
	Settings.WindowPosition.Top = top;
	Settings.WindowPosition.Width = width;
	Settings.WindowPosition.Height = height;
		
	if changeFlag == 1 then
		self:SetPosition( left, top );
		self:SetSize( width, height );
		self.resizeCtrl:SetPosition(self:GetWidth() - self.resizeCtrl:GetWidth(),self:GetHeight() - self.resizeCtrl:GetHeight()); 
		self:ResizeAll( );
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlayersSyncInfoWindow:Activated(sender, args)

	local width, height = self:GetSize();
	local left , top    = self:GetPosition();
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	
	local changeFlag = 0;
	-- Fix to prevent window to travel outside of the screen
	if width + 0 > displayWidth then
		width = displayWidth - 0;
		changeFlag = 1;
	end
	if height + 0 > displayHeight then
		height = displayHeight - 0;
		changeFlag = 1;
	end
	if left + width > displayWidth then
		left = displayWidth - width;
		changeFlag = 1;
	end
	if top + height > displayHeight then
		top = displayHeight - height;
		changeFlag = 1;
	end
	if left < 0 then
		left = 0;
		changeFlag = 1;
	end
	if top < 0 then
		top = 0;
		changeFlag = 1;
	end	
	
	Settings.PlayersSyncInfoWindowPosition.Left = left;
	Settings.PlayersSyncInfoWindowPosition.Top = top;
	Settings.PlayersSyncInfoWindowPosition.Width = width;
	Settings.PlayersSyncInfoWindowPosition.Height = height;
		
	if changeFlag == 1 then
		self:SetPosition( left, top );
		self:SetSize( width, height );
		self.resizeCtrl:SetPosition(self:GetWidth() - self.resizeCtrl:GetWidth(),self:GetHeight() - self.resizeCtrl:GetHeight());
		SyncInfolistbox:SetSize( self:GetWidth() - 60 , self:GetHeight() - 80  );
		scrollBarV:SetPosition(SyncInfolistbox:GetLeft() + SyncInfolistbox:GetWidth(), SyncInfolistbox:GetTop());
		scrollBarV:SetSize(10,SyncInfolistbox:GetHeight());
		scrollBarH:SetPosition(SyncInfolistbox:GetLeft(),SyncInfolistbox:GetHeight() + SyncInfolistbox:GetTop());
		scrollBarH:SetSize(SyncInfolistbox:GetWidth(), 10);
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:UserChatNameChange( Text )
	
	Settings.UserChatName = string.upper (Text);
	UserChatName = string.upper (Text);
	
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. UserChatName );
	self.joinUserChatSlot:SetShortcut( self.joinUserChatSlotShortcut );
	self.joinUserChatSlot:SetVisible( true );
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:FindInstrumentInTrack( Track_Name )
	local Track_Instrument = {};
	local Track_Instrument_Index = 0;
	local Track_Instrument_Name = "";
	
	local Track_Name_lowercase = string.lower(Track_Name);
	local found_Instruments = {};
	local found_Instruments_startIndex = {};
	local found_Instruments_count = 0;
	
	if  Track_Name == nil then return; end
		
	for k,v in pairs( self.Instruments_Names_inTrack ) do
		for k2,v2 in pairs( self.Instruments_Names_inTrack[k] ) do
			local startIndex = string.find( Track_Name_lowercase, string.lower(self.Instruments_Names_inTrack[k][k2]) );
			if startIndex then
				found_Instruments_count = found_Instruments_count + 1;
				found_Instruments[found_Instruments_count] = k;
				found_Instruments_startIndex[found_Instruments_count] = startIndex;
				break;
			end
		end
	end
	
	if found_Instruments_count > 1 then
		local startIndex = -1;
		for i = 1, found_Instruments_count do
			if found_Instruments_startIndex[i] > startIndex then
				startIndex = found_Instruments_startIndex[i];
				
				Track_Instrument_Index = found_Instruments[i];
				Track_Instrument_Name = self.Instruments_List[Track_Instrument_Index];
			end
		end
	elseif found_Instruments_count == 1 then
		Track_Instrument_Index = found_Instruments[1];
		Track_Instrument_Name = self.Instruments_List[Track_Instrument_Index];
	end
	
	if Track_Instrument_Index == 0 then
		if string.find( Track_Name_lowercase, "harp" ) then
			Track_Instrument_Index = 1;
			Track_Instrument_Name = "Basic Harp";
		elseif string.find( Track_Name_lowercase, "lute" ) then
			Track_Instrument_Index = 103;
			Track_Instrument_Name = "Basic Lute";
		elseif string.find( Track_Name_lowercase, "fiddle" ) or
			   string.find( Track_Name_lowercase, "fiddl" )
			then
			Track_Instrument_Index = 108;
			Track_Instrument_Name = "Basic Fiddle";
		elseif string.find( Track_Name_lowercase, "bassoon" ) or
			   string.find( Track_Name_lowercase, "basoon" ) or
			   string.find( Track_Name_lowercase, "basson" )
			then
			Track_Instrument_Index = 13;
			Track_Instrument_Name = "Basic Bassoon";
		end
	end
		
	Track_Instrument[0] = Track_Instrument_Index;
	Track_Instrument[1] = Track_Instrument_Name;
	
	return Track_Instrument;
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:UpdatePlayerTitle ( )

	self.playerInstance = Turbine.Gameplay.LocalPlayer:GetInstance( );
	self.playerEquipment = self.playerInstance:GetEquipment( );
	self.playerInstrument = self.playerEquipment:GetItem( Turbine.Gameplay.Equipment.Instrument );
			
	if not self.playerInstrument then return; end
	self.playerInstrumentName = self.playerInstrument:GetName( );
	if not self.playerInstrumentName then return; end

	self.Player_Name = self.playerInstance:GetName();
	if not self.Player_Name then return; end

	-------------------------------------------------------
	local equippedInstrument_Index = 0;
	for k,v in pairs( self.Instruments_List ) do
		if v == self.playerInstrumentName then
			equippedInstrument_Index = k;
			break;
		end
	end
	
	local playerInstrumentName = string.lower(self.playerInstrumentName);
	if equippedInstrument_Index == 0 then
		if string.find( playerInstrumentName , "harp" ) then
			equippedInstrument_Index = 1;
		elseif string.find( playerInstrumentName , "flute" ) then
			equippedInstrument_Index = 17;
		elseif string.find( playerInstrumentName , "lute" ) then
			equippedInstrument_Index = 3;
		elseif string.find( playerInstrumentName , "theorbo" ) then
			equippedInstrument_Index = 5;
		elseif string.find( playerInstrumentName , "fiddle" ) then
			equippedInstrument_Index = 8;
		elseif string.find( playerInstrumentName , "bagpipe" ) then
			equippedInstrument_Index = 12;
		elseif string.find( playerInstrumentName , "bassoon" ) then
			equippedInstrument_Index = 13;
		elseif string.find( playerInstrumentName , "clarinet" ) then
			equippedInstrument_Index = 16;
		elseif string.find( playerInstrumentName , "horn" ) then
			equippedInstrument_Index = 18;
		elseif string.find( playerInstrumentName , "pibgorn" ) then
			equippedInstrument_Index = 19;
		elseif string.find( playerInstrumentName , "cowbell" ) then
			equippedInstrument_Index = 21;
		elseif string.find( playerInstrumentName , "drum" ) then
			equippedInstrument_Index = 22;
		end
	end
	
	if equippedInstrument_Index ~= 0 then
		self.PlayerTitle:SetText(self.Player_Name .. " - " .. self.playerInstrumentName);
	else
		self.PlayerTitle:SetText(self.Player_Name .. " - No Instrument Equipped");
	end
	-------------------------------------------------------
	
	return equippedInstrument_Index;
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:CompareInstrument (equippedInstrument_Index, Track_Instrument_Index)
	
	local CorrectInstrument = 0;
	
	if equippedInstrument_Index ~= 0 then
		if Track_Instrument_Index ~= 0 then
			if Track_Instrument_Index == equippedInstrument_Index then
				CorrectInstrument = 1;
			elseif Track_Instrument_Index == 103 then
				if equippedInstrument_Index == 3 or equippedInstrument_Index == 4 then
					CorrectInstrument = 1;
				end
			elseif Track_Instrument_Index == 108 then
				if equippedInstrument_Index == 8 or equippedInstrument_Index == 9 then
					CorrectInstrument = 1;
				end
			end
		else
			CorrectInstrument = 1;
		end
	else
		CorrectInstrument = 0;
	end
	
	if CorrectInstrument == 0 then
		self.syncIcon:SetBackground(gDir .. "icn_s_f.tga");
		syncSlot_Correct_Instrument = 0;
	else
		self.syncIcon:SetBackground(gDir .. "icn_s.tga");
		syncSlot_Correct_Instrument = 1;
	end
	
	-------------------------------------------------------
	
	return CorrectInstrument;
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Find_OtherPlayer_SyncedSong_Index (Filename, TrackName, NumberOfParts)
	local SongIndex = {};
	
	local Number_Of_Found_Songs = 0;
	SongIndex[0] = Number_Of_Found_Songs;
	
	Filename = string.lower( Filename );
	Filename = string.gsub( Filename , "%s+", "" );
	
	TrackName = string.lower( TrackName );
	TrackName = string.gsub( TrackName , "%s+", "" );
	
	NumberOfParts = tonumber(NumberOfParts);
	
	for i = 1, librarySize do
		local SongDB_Filename = string.lower( SongDB.Songs[i].Filename );
		SongDB_Filename = string.gsub( SongDB_Filename , "%s+", "" );
		
		if SongDB_Filename == Filename then
			local trackcount = #SongDB.Songs[i].Tracks;
			
			if trackcount == NumberOfParts then
				for j = 1, trackcount do
					local SongDB_TrackName = string.lower( SongDB.Songs[i].Tracks[j].Name );
					SongDB_TrackName = string.gsub( SongDB_TrackName , "%s+", "" );
					
					if SongDB_TrackName == TrackName then
						
						Number_Of_Found_Songs = Number_Of_Found_Songs + 1;
						SongIndex[Number_Of_Found_Songs] = i;
						break;
					end
				end
			end
		end
	end
	
	if Number_Of_Found_Songs == 0 then
		for i = 1, librarySize do
			local trackcount = #SongDB.Songs[i].Tracks;
			
			if trackcount == NumberOfParts then
				for j = 1, trackcount do
					local SongDB_TrackName = string.lower( SongDB.Songs[i].Tracks[j].Name );
					SongDB_TrackName = string.gsub( SongDB_TrackName , "%s+", "" );
					
					if SongDB_TrackName == TrackName then
					
						Number_Of_Found_Songs = Number_Of_Found_Songs + 1;
						SongIndex[Number_Of_Found_Songs] = i;
						break;
					end
				end
			end
		end
	end
	
	SongIndex[0] = Number_Of_Found_Songs;
	
	return SongIndex;
end

function SongbookWindow:Find_OtherPlayer_SyncedSong_Index_WithOnlySync (TrackName)
	local SongIndex = {};
	
	local Number_Of_Found_Songs = 0;
	SongIndex[0] = Number_Of_Found_Songs;
	
	local Synced_TrackName = string.lower( TrackName );
	Synced_TrackName = string.gsub( string.sub( Synced_TrackName, 1, 63 ) , "%s+", "" );
	
	for i = 1, librarySize do
		
		local trackcount = #SongDB.Songs[i].Tracks;
		
		for j = 1, trackcount do
			local SongDB_TrackName = string.lower( SongDB.Songs[i].Tracks[j].Name );
			SongDB_TrackName = string.gsub( string.sub( SongDB_TrackName, 1, 63 ) , "%s+", "" );
			
			if SongDB_TrackName == Synced_TrackName then
				
				Number_Of_Found_Songs = Number_Of_Found_Songs + 1;
				SongIndex[Number_Of_Found_Songs] = i;
				break;
			end
		end
	end
	
	SongIndex[0] = Number_Of_Found_Songs;
	
	return SongIndex;
end

function SongbookWindow:Update_syncMessage (SongIndex, PlayerName, TrackName)
	
	Multiple_songs_match_Synced = 0;
	MatchedSongsWindow:SetVisible(false);
	
	if SongIndex[0] > 1 then
		YouDontHaveTheSameSong_Flag = 0;
		if PlayerName == songbookWindow.sPlayerName then
			-- OtherPlayer_SyncedSong_Index = selectedSongIndex;
			-- OtherPlayer_SyncedSong_Filepath = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filepath;
			-- OtherPlayer_SyncedSong_Filename = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filename;
			
			-- self.syncMessageTitle:SetText(PlayerName .. "-> " .. OtherPlayer_SyncedSong_Filepath .. " " .. OtherPlayer_SyncedSong_Filename);
			
			-- if OtherPlayer_Synced == 0 then
				-- self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
			-- else
				-- self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
			-- end
			
			-- self.syncMessageTitle:SetVisible(false);
		else
			--MatchedSongsIndex = SongIndex;
			Multiple_songs_match_Synced = 1;
			self.syncMessageTitle:SetText(PlayerName .. "-> " .. TrackName .. " - Multiple songs match");
			if OtherPlayer_Synced == 0 then
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
			end
			self.syncMessageTitle:SetVisible(true);
			
			MatchedSongsListbox:ClearItems( );
			for i = 1, SongIndex[0] do
				local SongItem = Turbine.UI.Label();
				SongItem:SetMultiline( false )
				SongItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				SongItem:SetSize( 2000, 20 );
				SongItem:SetMarkupEnabled(true);
				if OtherPlayer_Synced == 0 then
					SongItem:SetForeColor( self.colour_syncMessageTitle );
				else
					SongItem:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
				end
				SongItem:SetBackColor( self.backColourDefault );
				SongItem:SetText( SongDB.Songs[SongIndex[i]].Filepath .. " " .. SongDB.Songs[SongIndex[i]].Filename );
				MatchedSongsListbox:AddItem( SongItem );
				
				SongItem.MouseEnter = function(sender, args)
					if SongItem:IsVisible() then
						if OtherPlayer_Synced == 0 then
							SongItem:SetForeColor( self.colour_syncMessageTitle_Highlighted );
						else
							SongItem:SetForeColor( self.colour_syncMessageTitle_Highlighted_OnlySynced );
						end
					end
				end
				SongItem.MouseLeave = function(sender, args)
					if SongItem:IsVisible() then
						if OtherPlayer_Synced == 0 then
							SongItem:SetForeColor( self.colour_syncMessageTitle );
						else
							SongItem:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
						end
					end
				end
				SongItem.MouseDown = function(sender,args)
					if SongItem:IsVisible() then
						if OtherPlayer_Synced == 0 then
							SongItem:SetForeColor( self.colour_syncMessageTitle_MouseDown );
						else
							SongItem:SetForeColor( self.colour_syncMessageTitle_MouseDown_OnlySynced );
						end
					end
				end
				SongItem.MouseUp = function(sender,args)
					if SongItem:IsVisible() then
						if OtherPlayer_Synced == 0 then
							SongItem:SetForeColor( self.colour_syncMessageTitle );
						else
							SongItem:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
						end
						
						SelectedMatchedSong_Index = SongIndex[i];
	
						songbookWindow:SelectDir( nil, SongDB.Songs[SelectedMatchedSong_Index].Filepath );
						songbookWindow:SelectSong(SelectedMatchedSong_IndexListBox);
						local selectedItem = songbookWindow.songlistBox:GetItem( SelectedMatchedSong_IndexListBox )
						if selectedItem then selectedItem:SetForeColor( songbookWindow.colourDefaultHighlighted ); end
					end
				end
			end
		end
	elseif SongIndex[0] == 0 then
		self.syncMessageTitle:SetText("You don't have the same song. " .. PlayerName .. "-> " .. TrackName);
		if OtherPlayer_Synced == 0 then
			self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
		else
			self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
		end
		self.syncMessageTitle:SetVisible(true);
		YouDontHaveTheSameSong_Flag = 1;
	elseif SongIndex[0] == 1 then
		YouDontHaveTheSameSong_Flag = 0;
		
		OtherPlayer_SyncedSong_Index = SongIndex[1];
		OtherPlayer_SyncedSong_Filepath = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filepath;
		OtherPlayer_SyncedSong_Filename = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filename;
		
		self.syncMessageTitle:SetText(PlayerName .. "-> " .. OtherPlayer_SyncedSong_Filepath .. " " .. OtherPlayer_SyncedSong_Filename);
		
		
		if OtherPlayer_Synced == 0 then
			self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle );
		else
			self.syncMessageTitle:SetForeColor( self.colour_syncMessageTitle_OnlySynced );
		end
		
		if OtherPlayer_SyncedSong_Filepath .. OtherPlayer_SyncedSong_Filename == SongDB.Songs[selectedSongIndex].Filepath .. selectedSong then
			self.syncMessageTitle:SetVisible(false);
		else
			if OtherPlayer_SyncedSong_Filepath .. OtherPlayer_SyncedSong_Filename ~= "" then
				self.syncMessageTitle:SetVisible(true);
			end
		end
	end
end

function SongbookWindow:ToggleTimerWindow( State )
	self.TimerWindowVisible = State
	Timer_Window:SetVisible( self.TimerWindowVisible )
end

function SongbookWindow:ToggleUseRaidChat( State )
	self.UseRaidChat = State;
	if State == true then
		self.UseFellowshipChat = false;
	else
	end
	self:PlayerSyncInfo();
end

function SongbookWindow:ToggleUseFellowshipChat( State )
	self.UseFellowshipChat = State;
	if State == true then
		self.UseRaidChat = false;
	else
	end
	self:PlayerSyncInfo();
end

function SongbookWindow:ToggleHelpWindow( State )
	self.HelpWindowDisable = State;
end

function SongbookWindow:ShowHelpWindow( )
	Help_Window:SetVisible(true);
end

function SongbookWindow:HelpWindow( )
	if Settings.HelpWindowDisable == "false" and HelpWindow_Load_Flag == 1 then
		Help_Window:SetVisible(true);
		HelpWindow_Load_Flag = 0;
	end
end


