
-- Fanuilos, le linnathon

-- Songbook 3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SongbookWindow = class( Turbine.UI.Window );


ListBoxScrolled = class( Turbine.UI.ListBox ); -- Listbox with child scrollbar and separator
ListBoxCharColumn = class( ListBoxScrolled ) -- Listbox with single char column

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HelpWindow_Load_Flag = 1;
SelectedMatchedSong_Index = 1;
--MatchedSongsIndex = {};
InstrumentSlots_Shift = 45;
ShiftTop = 50;

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
Help_Window_CB:SetChecked(Settings.HelpWindowDisable );
Help_Window_CB.CheckedChanged = function(sender, args)
	if songbookWindow then
		songbookWindow:SetHelpWindowDisabled( sender:IsChecked( ) );
		songbookWindow:SaveSettings();
	end
end;

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TimerWindow = Songbook3.src.TimerWindow();

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

function SongbookWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	self.bFilter = false -- show/hide filter UI
	self.bShowPlayers = true -- show/hide players listbox (used to auto-hide, but disabled for now)
	self.maxPartCount = nil -- the number of parts to use as filter (nil if not filtering, else player count)
	self.alignTracksRight = false -- if true, track names are listed right-aligned (resize will reset to left aligned)
	self.listboxSetupsWidth = 20 -- width of the setups listbox (to the left of the tracks list)
	self.setupsWidth = self.listboxSetupsWidth + 10 -- total width of setup list including scrollbar
	self.bShowSetups = false -- show/hide setups (autohide for songs with no setups defined)

	self.TimerWindowVisible = true;
	self.HelpWindowDisable = false;
	
	
	
	self.bCheckInstrument = true
	self.bInstrumentOk = true
	self.bTimer = true
	self.bTimerCountdown = true
	
	self.bShowReadyChars = true
	self.bHighlightReadyCol = true
	self.chNone = " "
	self.chReady = "~"
	self.chWrongSong = "S"
	self.chWrongPart = "P"
	self.chMultiple = "M"
	
	-- Apply settings to instance state
	self:ToggleTimerWindow( Settings.TimerWindowVisible )
	self:SetHelpWindowDisabled( Settings.HelpWindowDisable )
	Help_Window_CB:SetChecked( Settings.HelpWindowDisable );

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

	TimerWindow:AdjustTimerPosition(displayWidth, displayHeight)

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
				
				if TimerWindow:IsVisible() then
					Timer_WindowWasVisible = true;
					TimerWindow:SetVisible(false);					
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
					PlayersSyncInfoWindow:SetVisible(true);	
					PlayersSyncInfoWindow:Activate();
				end
				if Timer_WindowWasVisible then
					TimerWindow:SetVisible(true);	
					TimerWindow:Activate();
				end
			end
		
		------------------------------------------------------
		
		--elseif (args.Action == 268435635) then
			
		end
	end
	
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
	
	TimerWindow:SetPosition( Settings.Timer_WindowPosition.Left, Settings.Timer_WindowPosition.Top );
	
	self:SetOpacity( Settings.WindowOpacity );
	--self:SetText("Songbook " .. Plugins[gPlugin]:GetVersion() .. Strings["title"] );
	self:SetText("Songbook " .. "3" );
	
	self.Version = Turbine.UI.Label();
	self.Version:SetParent( self );
	self.Version:SetFont(Turbine.UI.Lotro.Font.Verdana12);
	self.Version:SetForeColor( ColorTheme.colourMessageTitle );
	self.Version:SetPosition( 40, 25 );
	self.Version:SetSize(50, 14);
	self.Version:SetText("V" .. Plugins[gPlugin]:GetVersion());
	
	self.minWidth = 461;
	self.minHeight = 308;
	-- self.lFXmod = 23; -- listFrame x coord modifier
	-- self.lCXmod = 28; -- listContainer x coord modifier (original value was 42)

	-- if (CharSettings.InstrSlots[1]["visible"]) then
	-- 	self.lFYmod = 214 + ShiftTop + InstrumentSlots_Shift * ( CharSettings.InstrumentSlots_Rows - 1 ); -- listFrame     y coord modifier = difference between bottom pixels and window bottom
	-- 	self.lCYmod = 233 + ShiftTop + InstrumentSlots_Shift * ( CharSettings.InstrumentSlots_Rows - 1 ); -- listContainer y coord modifier = difference between bottom pixels and window bottom
	-- else
	-- 	self.lFYmod = 169 + ShiftTop + 0 * ( CharSettings.InstrumentSlots_Rows - 1 ) ; -- listFrame     y coord modifier = difference between bottom pixels and window bottom
	-- 	self.lCYmod = 188 + ShiftTop + 0 * ( CharSettings.InstrumentSlots_Rows - 1 ) ; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	-- end
	
	-- Frame for the song list
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.listFrame:SetPosition(12, 134 + ShiftTop);
	-- self.listFrame:SetSize(self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod);
	self.listContainer = Turbine.UI.Control();
	self.listContainer:SetParent( self );
	self.listContainer:SetBackColor( Turbine.UI.Color(1,0,0,0) );
	self.listContainer:SetPosition(18, 147 + ShiftTop);
	-- self.listContainer:SetSize(self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod);

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
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. SyncManager.userChatName );
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
			self:SelectTrack(SongLibrary.selectedTrack - 1);
		end
	end
	self.trackNext.MouseClick = function(sender, args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:SelectTrack(SongLibrary.selectedTrack + 1);
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
		if SyncManager.correctInstrument then
			self.syncIcon:SetBackground(gDir .. "icn_s.tga");
		else
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

		SyncManager.userChatBlocked = false;
		SyncManager.syncedSongIndex = SongLibrary.selectedSongIndex;
		SyncManager.syncedTrack = SongLibrary.selectedTrack;
		SyncManager.localPlayerSynced = false;
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

		SyncManager.userChatBlocked = false;
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

		if not SyncManager.syncStartReady then
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
	self.songTitle:SetForeColor( ColorTheme.colourDefaultHighlighted );	
	self.songTitle:SetPosition( 23, 90 + ShiftTop);
	self.songTitle:SetSize( self:GetWidth() - 52, 16);
	
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Player Name and Instrument display
	self.PlayerTitle = Turbine.UI.Label();
	self.PlayerTitle:SetParent( self );
	self.PlayerTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.PlayerTitle:SetForeColor( ColorTheme.colourDefaultHighlighted );
	self.PlayerTitle:SetPosition( 15, 30 );
	self.PlayerTitle:SetSize(self:GetWidth() - 30, 16);
	self.PlayerTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	self.PlayerTitle:SetText("");
	
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self:UpdatePlayerTitle();
	self.playerEquipment = self.playerInstance:GetEquipment()

	self.playerEquipment.ItemEquipped = function(sender, args)
		local insIndex = self:PlayerSyncInfo();
		if insIndex == 0 then return; end
		local trackListEmpty = self.tracklistBox == nil or self.tracklistBox:GetItemCount( ) < 1
		if Settings.AutoPickOnInsChange and not trackListEmpty then
			-- Check if current track is already the right instrument
			if self:IsAvailableTrackWithMatchingInstrument(SongLibrary.selectedSongIndex, SongLibrary.selectedTrack, insIndex) then
				return;
			end

			local iTrack = self:GetTrackToSelect(SongLibrary.selectedSongIndex);
			if iTrack == 0 then return; end
			if self.bShowReadyChars then iTrack = iTrack * 2; end
			self:SelectTrack(iTrack);
		end
	end
	
	
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Songbook Messages display
	self.MessageTitle = Turbine.UI.Label();
	self.MessageTitle:SetParent( self );
	self.MessageTitle:SetFont(Turbine.UI.Lotro.Font.Verdana12);
	self.MessageTitle:SetForeColor( ColorTheme.colourMessageTitle );
	self.MessageTitle:SetPosition( 23, 50 );
	self.MessageTitle:SetSize(self:GetWidth() - 30, 14);
	--self.MessageTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	
	if SyncManager.userChatNumber ~= 0 and SyncManager.userChatNumber ~= nil then
		SyncManager.chatChannel = "/" .. SyncManager.userChatNumber;
		self.MessageTitle:SetText("SongBook is using User Chat channel " .. SyncManager.userChatNumber .. " - " .. SyncManager.userChatName);
	else
		self.MessageTitle:SetText("SongBook is using Fellowship channel");
	end
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	-- Synced song Messages display
	self.syncMessageTitle = Turbine.UI.Label();
	self.syncMessageTitle:SetParent( self );
	self.syncMessageTitle:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
	self.syncMessageTitle:SetBackColor( ColorTheme.backColourHighlight );
	self.syncMessageTitle:SetPosition( 23, 70 );
	self.syncMessageTitle:SetSize(self:GetWidth() - 30, 16);
	--self.syncMessageTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	--self.syncMessageTitle:SetText("");
	self.syncMessageTitle:SetVisible(false);
	
	self.syncMessageTitle.MouseEnter = function(sender, args)
		if self.syncMessageTitle:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_Highlighted );
			else
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_Highlighted_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseLeave = function(sender, args)
		if self.syncMessageTitle:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseDown = function(sender,args)
		if self.syncMessageTitle:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_MouseDown );
			else
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_MouseDown_OnlySynced );
			end
		end
	end
	self.syncMessageTitle.MouseUp = function(sender,args)
		if self.syncMessageTitle:IsVisible() then
			if not SyncManager.otherPlayerSynced then
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
			end
			if SyncManager.multipleSongsMatch then
				MatchedSongsWindow:SetVisible( true );
			elseif not SyncManager.missingMatchedSong then
				self:SelectDir( nil, SyncManager.otherPlayerSong.filepath );
				self:SelectSong(SyncManager.otherPlayerSong.indexListBox);
				local selectedItem = self.songlistBox:GetItem( SyncManager.otherPlayerSong.indexListBox )
				if selectedItem then selectedItem:SetForeColor( ColorTheme.colourDefaultHighlighted ); end
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
	if (Settings.SearchVisible) then
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
	self:ShowTrackListbox( Settings.TracksVisible )
	
	
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
		if (CharSettings.InstrSlots[1]["visible"]) then
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
	
	self.bTimer = ( Settings.TimerState )
	self.bTimerCountdown = ( Settings.TimerCountdown )
	self.bShowReadyChars = ( Settings.ReadyColState )
	self.bHighlightReadyCol = ( Settings.ReadyColHighlight )
	self.tracklistBox:EnableCharColumn( self.bShowReadyChars )

	-- initialize list items from song database
	if (SongLibrary.librarySize ~= 0 and not SongDB.Songs[1].Realnames) then
		
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
		
		self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. SongLibrary.selectedDir .. ")" );
		
		if (self.dirlistBox:ContainsItem(1)) then
			local dirItem = self.dirlistBox:GetItem(1);
			dirItem:SetForeColor( ColorTheme.colourDefaultHighlighted );
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
			-- Turbine.Shell.WriteLine( "<rgb=#00FF00>SIC</rgb>");
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
		if not sender.dragging then return end

		local width, height = self:GetSize();
		local gameDisplayWidth, gameDisplayHeight = Turbine.UI.Display.GetSize();
		
		-- Apply drag deltas
		width = width + args.X - sender.dragStartX;
		height = height + args.Y - sender.dragStartY;

		local WindowLeft = self:GetLeft();
		local WindowTop  = self:GetTop ();
		
		-- Enforce minimum size
		if width < self.minWidth then width = self.minWidth; end
		if height < 200 then height = 200; end

		-- Clamp to lotro screen size
		if WindowLeft + width  > gameDisplayWidth  then
		width = gameDisplayWidth  - WindowLeft; end
		if WindowTop  + height > gameDisplayHeight then
		height = gameDisplayHeight - WindowTop ; end

		-- Optional: enforce enough vertical room for dirlist + tracks + songlist
		local tracksHeight = (Settings.TracksVisible) and Settings.TracksHeight or 0
		local minContentHeight = Settings.DirHeight + tracksHeight + 80  -- fudge room for list and padding
		if height < minContentHeight then
			height = minContentHeight
		end
		
		self:SetSize( width, height );

		-- self:ResizeAll( );
		self:ReflowLayout()
    	
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
				if (Settings.TracksVisible) then
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
			SyncManager.Shutdown();
		end
	end

	self:CreateTimerUI( )
	self:CreateFilterUI( ) -- Creates the UI elements for the filters

	SyncManager.onPlayerJoined = function(name) self:AddPlayerToList(name) end
	SyncManager.onPlayerLeft = function(name) self:RemovePlayerFromList(name) end
	SyncManager.onChiefModeChanged = function(state)
		self.syncStartSlot:SetVisible(state)
		self.syncStartIcon:SetVisible(state)
	end
	SyncManager.onPlayerStateChanged = function()
		self:SetListboxColours(self.songlistBox)
		self:SetTrackColours(SongLibrary.selectedTrack)
		self:SetPlayerColours()
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
		self.MessageTitle:SetText(message)
	end
	SyncManager.onMaxPartCountChanged = function()
		self:UpdateMaxPartCount()
	end
	SyncManager.onSongStateCleared = function()
	end

	self.listboxPlayers:EnableCharColumn( self.bShowReadyChars )
	self:RefreshPlayerListbox( ) -- lists the current party members; more will be added through chat messages

	if Settings.FiltersState then self:ShowFilterUI( true ); end
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
	self.bTimer = bActivate
	if not bActivate then self:StopTimer( ); end
end

function SongbookWindow:CreateTimerUI( )
	self.tracksMsg = Turbine.UI.Label( )
	self.tracksMsg:SetParent( self.listContainer )
	self.tracksMsg:SetMultiline( false )
	self.tracksMsg:SetSize( 150, 22 )
	self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold22 );
	--self.tracksMsg:SetForeColor( ColorTheme.colourMessageTitle );
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
	TimerWindow:SetTimerText( string.format("%u:%02u", mins, value - mins * 60 ) )
end
	
function SongbookWindow:StartTimer( )
	self.startTimer = Turbine.Engine.GetLocalTime( )
	self.songDuration = 0
	--local item, songTime
	local songTime
	-- for i = 1, self.tracklistBox:GetItemCount( ) do
		-- item = self.tracklistBox:GetItem( i )
		sMinutes, sSeconds = string.match( SyncManager.syncedTrackName , ".*%((%d+):(%d+)%).*" ) -- try (mm:ss)
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
	TimerWindow:SetTimerText("0:00");
	TimerWindow:SetSongText( "" );
end

function SongbookWindow:ReflowLayout()
	local width, height = self:GetSize()

	local HEADER_HEIGHT = 134 + ShiftTop
	local LIST_FRAME_MARGIN_LEFT = 12
	local LIST_FRAME_MARGIN_RIGHT = 11
	local LIST_CONTAINER_MARGIN_LEFT = 18
	local LIST_CONTAINER_MARGIN_RIGHT = 10
	local BOTTOM_BUTTON_HEIGHT = 30
	local SEPARATOR_HEIGHT = 13

	local currentY = HEADER_HEIGHT

	-- Search
	local searchHeight = 0
	if Settings.SearchVisible then
		searchHeight = 20
		self.searchInput:SetVisible(true)
		self.searchBtn:SetVisible(true)
		self.clearBtn:SetVisible(true)
	else
		self.searchInput:SetVisible(false)
		self.searchBtn:SetVisible(false)
		self.clearBtn:SetVisible(false)
	end

	currentY = currentY + searchHeight
	-- Position the main list containers
	self.listFrame:SetPosition(LIST_FRAME_MARGIN_LEFT, currentY)
	self.listContainer:SetPosition(LIST_CONTAINER_MARGIN_LEFT, currentY + SEPARATOR_HEIGHT)

	-- Calculate instrument slot height
	local instrHeight = 0
	if CharSettings.InstrSlots[1]["visible"] then
		instrHeight = InstrumentSlots_Shift * CharSettings.InstrumentSlots_Rows
	end

	-- Calculate track height
	local tracksHeight = 0
	if Settings.TracksVisible then
		tracksHeight = Settings.TracksHeight
	end

	-- Calculate available space for lists
	local INSTR_PADDING = 12
	local availableListHeight = height - currentY - instrHeight - BOTTOM_BUTTON_HEIGHT - INSTR_PADDING
	
	-- Size the main containers
	local listFrameWidth = width - LIST_FRAME_MARGIN_LEFT - LIST_FRAME_MARGIN_RIGHT
	local listContainerWidth = width - LIST_CONTAINER_MARGIN_LEFT - LIST_CONTAINER_MARGIN_RIGHT
	
	self.listFrame:SetSize(listFrameWidth, availableListHeight)
	self.listContainer:SetSize(listContainerWidth, availableListHeight)
	self.listFrame.heading:SetSize(listFrameWidth, SEPARATOR_HEIGHT)

	-- Stack list sections within the container
	Layout.stackVertical({
		{ control = self.dirlistBox,     height = Settings.DirHeight },
		{ control = self.separator1,     height = SEPARATOR_HEIGHT },
		{ control = self.songlistBox,    height = "fill" },
		{ control = self.sepSongsTracks, height = SEPARATOR_HEIGHT,     visible = Settings.TracksVisible },
		{ control = self.tracklistBox,   height = Settings.TracksHeight, visible = Settings.TracksVisible },
	}, { height = availableListHeight })

	-- Position heading labels above their separators
	if self.separator1.heading then
		self.separator1.heading:SetTop(self.separator1:GetTop() - SEPARATOR_HEIGHT)
	end
	if self.sepSongsTracks.heading then
		self.sepSongsTracks.heading:SetTop(self.sepSongsTracks:GetTop() - SEPARATOR_HEIGHT)
	end

	-- Horizontal positioning and widths (layout handles vertical only)
	self:AdjustDirlistPosition()
	self:AdjustSonglistLeft()
	self.separator1:SetWidth(listContainerWidth)
	self.sArrows1:SetLeft(self.separator1:GetWidth() / 2 - 10)

	-- Controls that move with the song list
	self.btnParty:SetTop(self.songlistBox:GetTop())
	self.listboxPlayers:SetTop(self.songlistBox:GetTop() + 20)
	self.listboxPlayers:SetHeight(self.songlistBox:GetHeight() - 20)

	-- Track list associated controls
	if Settings.TracksVisible then
		self:ShowTrackListbox(true)
		self:AdjustTracklistLeft()
		self:AdjustTracklistWidth()
		self.listboxSetups:SetTop(self.tracklistBox:GetTop())
		self.listboxSetups:SetHeight(self.tracklistBox:GetHeight())
		self.listboxSetups:SetVisible(self.bShowSetups)
	else
		self:ShowTrackListbox(false)
		self.listboxSetups:SetVisible(false)
		self.tracksMsg:SetPosition(
			self.dirlistBox:GetLeft() + self.dirlistBox:GetWidth() - 160,
			self.dirlistBox:GetTop() + self.dirlistBox:GetHeight())
	end

	-- Reposition instrument containers
	for j = 1, CharSettings.InstrumentSlots_Rows do
		local TopShift = 75 + InstrumentSlots_Shift * (j - 1)
		if self.instrContainer and self.instrContainer[j] then
			self.instrContainer[j]:SetTop(height - TopShift)
			self.instrContainer[j]:SetVisible(CharSettings.InstrSlots[1]["visible"])
		end
	end

	-- Reposition bottom buttons
	self.settingsBtn:SetPosition(width / 2 - 55, height - BOTTOM_BUTTON_HEIGHT)
	self.SyncInfoBtn:SetPosition(width - 150, height - BOTTOM_BUTTON_HEIGHT)

	-- Update other width-dependent elements
	self.songTitle:SetWidth(width - 52)
	self.listFrame.heading:SetSize(listFrameWidth, SEPARATOR_HEIGHT)
	self.PlayerTitle:SetWidth(width - 30)
	self.MessageTitle:SetWidth(width - 30)
	self.syncMessageTitle:SetWidth(width - 30)
	
	-- Update filter UI positioning
	self:AdjustFilterUI()

	-- Tooltip and resizer
	self.tipLabel:SetLeft(width - 270)
	if self.resizeCtrl then
		self.resizeCtrl:SetPosition(width - self.resizeCtrl:GetWidth(), height - self.resizeCtrl:GetHeight())
	end
end -- ReflowLayout


-- action for selecting a directory
function SongbookWindow:SelectDir(iDir, Directory)
	if not Directory then
		local selectedItem = self:SetListboxColours(self.dirlistBox)
		if not selectedItem then return end
		Directory = selectedItem:GetText()
		if Directory == ".." then
			SongLibrary.NavigateUp()
		else
			SongLibrary.NavigateToDirectory(Directory)
		end
	else
		SongLibrary.NavigateToPath(Directory)
	end

	local dir = SongLibrary.selectedDir
	if string.len(dir) < 31 then
		self.listFrame.heading:SetText(Strings["ui_dirs"] .. " (" .. dir .. ")")
	else
		self.listFrame.heading:SetText(Strings["ui_dirs"] .. " (" .. string.sub(dir, string.len(dir)-30) .. ")")
	end

	self.dirlistBox:ClearItems()
	if SongLibrary.selectedDir ~= "/" then
		local dotdot = Turbine.UI.Label()
		dotdot:SetText("..")
		dotdot:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
		dotdot:SetSize(1000, 20)
		self.dirlistBox:AddItem(dotdot)
	end
	local subdirs = SongLibrary.GetSubdirectories()
	for _, name in ipairs(subdirs) do
		local dirItem = Turbine.UI.Label()
		dirItem:SetText(name)
		dirItem:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
		dirItem:SetSize(1000, 20)
		self.dirlistBox:AddItem(dirItem)
	end

	self.songlistBox:ClearItems()
	self:LoadSongs()
	self:InitSonglist()
end -- SelectDir


function SongbookWindow:LoadSongs()
	local songs = SongLibrary.GetSongsInDirectory(self:GetFilters())
	for pos, entry in ipairs(songs) do
		local songItem = Turbine.UI.Label()
		songItem:SetText(entry.text)
		songItem:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
		songItem:SetSize(1000, 20)
		self.songlistBox:AddItem(songItem)
		if SelectedMatchedSong_Index == entry.index then
			SelectedMatchedSong_IndexListBox = pos
		end
		if SyncManager.otherPlayerSong.index == entry.index then
			SyncManager.otherPlayerSong.indexListBox = pos
		end
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
	local trackcount = #SongDB.Songs[songIdx].Tracks;

	-- Get instrument of current player
	local equippedInstrument_Index = self:UpdatePlayerTitle();

	for iTrack = 1,trackcount do
		if self:IsAvailableTrackWithMatchingInstrument(songIdx, iTrack, equippedInstrument_Index) then
			return iTrack;
		end
	end

	return 0;
end

-- action for selecting a song
function SongbookWindow:SelectSong( iSong )
	if( iSong < 1 or iSong > self.songlistBox:GetItemCount( ) ) then
		return;
	end
	local track = 1;
	SongLibrary.setupTrackIndices = { };
	SongLibrary.setupListIndices = { };
	SongLibrary.currentSetup = nil

	-- clear focus
	self:SetListboxColours( self.songlistBox ) --, iSong )
	
	SongLibrary.selectedSongIndexListBox = iSong;
	SongLibrary.selectedSongIndex = SongLibrary.filteredIndices[ iSong ];
	SongLibrary.selectedSong = SongDB.Songs[SongLibrary.selectedSongIndex].Filename;

	if Settings.AutoPickOnSongChange then
			track = self:GetTrackToSelect(SongLibrary.selectedSongIndex);
			if track == 0 then track = 1; end
			if self.bShowReadyChars then track = track * 2; end
	end
			
	if ( SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[1].Name ~= "") then
		self.songTitle:SetText( SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[1].Name );	
	else
		self.songTitle:SetText( SongDB.Songs[SongLibrary.selectedSongIndex].Filename );	
	end
	self.trackNumber:SetText( SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[1].Id );
	self.trackPrev:SetVisible(false);
	
	if (#SongDB.Songs[SongLibrary.selectedSongIndex].Tracks > 1) then
		self.trackNext:SetVisible(true);
	else
		self.trackNext:SetVisible(false);
	end

	self:ListTracks(SongLibrary.selectedSongIndex);	
	
	self:ClearPlayerReadyStates( );
	self:SelectTrack( track );
	self:SetPlayerColours( );
	self:ListSetups( SongLibrary.selectedSongIndex )
	SongLibrary.currentSetup = SongLibrary.SetupIndexForCount( SongLibrary.selectedSongIndex, SongLibrary.selectedSetupCount )
	self:SelectSetup( SongLibrary.currentSetup )
	self:UpdateSetupColours( );
	
	self:SetTrackColours( SongLibrary.selectedTrack );
	
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
	trackItem:SetForeColor( ColorTheme.colourDefault );
	return trackItem
end

function SongbookWindow:AddTrackToList( iSong, iTrack )
	local sTerseName = SongLibrary.TerseTrackname( SongDB.Songs[iSong].Tracks[iTrack].Name );
	local trackItem = self:CreateTracklistItem( "[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "] " .. sTerseName )
	trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	trackItem:SetSize( 1000, 20 );
	self.tracklistBox:AddItem( trackItem );
	
	local Track_Instrument = InstrumentManager.FindInstrumentInTrack( sTerseName );

	trackItem = Turbine.UI.Label();
	trackItem:SetMultiline( false )
	trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	trackItem:SetSize( 2000, 20 );
	trackItem:SetMarkupEnabled(true);
	trackItem:SetText( "[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "] " .. Track_Instrument[1] );
	trackItem:SetBackColor( ColorTheme.backColourDefault );
	
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


function SongbookWindow:SearchSongs()
	self.songlistBox:ClearItems()
	local songs = SongLibrary.SearchSongs(self.searchInput:GetText(), self:GetFilters())
	for _, entry in ipairs(songs) do
		local songItem = Turbine.UI.Label()
		songItem:SetText(entry.text)
		songItem:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
		songItem:SetSize(1000, 20)
		self.songlistBox:AddItem(songItem)
	end
	if #songs > 0 then self:SelectSong(1) end
	self.separator1.heading:SetText(Strings["ui_songs"] .. " (" .. #songs .. ")")
end

-- action for toggling search function on and off
function SongbookWindow:ToggleSearch(mode)
	if (Settings.SearchVisible or mode == "off") then		
		Settings.SearchVisible = false;
		self:SetSearch( -20, false )
	else
		Settings.SearchVisible = true;
		self:SetSearch( 20, true )
	end

	self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);	
	self.listContainer:SetHeight(self:GetHeight() - self.lCYmod);		
	if (not Settings.TracksVisible) then
		self:ShowTrackListbox( false ) -- ?
	end
end

-- function SongbookWindow:SetSearch( delta, bShow )
-- 	self.searchInput:SetVisible(bShow);
-- 	self.searchBtn:SetVisible(bShow);
-- 	self.clearBtn:SetVisible(bShow);		
-- 	self.lFYmod = self.lFYmod + delta;		
-- 	self.lCYmod = self.lCYmod + delta;
-- 	self.listFrame:SetTop( self.listFrame:GetTop( ) + delta);
-- 	self.listContainer:SetTop( self.listContainer:GetTop( ) + delta );
-- 	self:SetSonglistHeight(self.songlistBox:GetHeight() - delta);		
-- 	self:MoveTracklistTop( -delta );
	
-- 	if not Settings.TracksVisible then
-- 		self.tracksMsg:SetTop( self.dirlistBox:GetTop()+self.dirlistBox:GetHeight() );
-- 	end
-- end

-- action for toggling description on and off
function SongbookWindow:ToggleDescription()
	if (Settings.DescriptionVisible) then
		Settings.DescriptionVisible = false;
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then self:SelectSong(1);
		else self:ClearSongState( ); end
	else
		Settings.DescriptionVisible = true;
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();		
		if (found > 0) then self:SelectSong(1);
		else self:ClearSongState( ); end
	end
end

-- action for toggling description on and off
function SongbookWindow:ToggleDescriptionFirst()
	if (Settings.DescriptionFirst) then
		Settings.DescriptionFirst = false;		
		if (Settings.DescriptionVisible) then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then self:SelectSong(1);
			else self:ClearSongState( ); end
		end
	else
		Settings.DescriptionFirst = true;
		if (Settings.DescriptionVisible) then
			self.songlistBox:ClearItems();
			self:LoadSongs();
			local found = self.songlistBox:GetItemCount();		
			if (found > 0) then self:SelectSong(1);
			else self:ClearSongState( ); end
		end
	end
end

-- -- action for toggling tracks display on and off
-- function SongbookWindow:ToggleTracks()
-- 	if (Settings.TracksVisible) then
-- 		Settings.TracksVisible = "no";
-- 		self:SetSonglistHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13);
-- 		self:ShowTrackListbox( false )
-- 		self.listboxSetups:SetVisible(false);
-- 		self.tracksMsg:SetPosition( self.dirlistBox:GetLeft()+self.dirlistBox:GetWidth()-150, self.dirlistBox:GetTop()+self.dirlistBox:GetHeight());	
-- 	else
-- 		Settings.TracksVisible = "yes";
-- 		self:ShowTrackListbox( true )
-- 		self.listboxSetups:SetVisible(self.bShowSetups)
		
-- 		-- check if there's room for the track list and adjust
-- 		local h = self.dirlistBox:GetHeight() + Settings.TracksHeight + 26;
-- 		if (self.listContainer:GetHeight() - h < 40) then
-- 			self.listContainer:SetHeight(h + self.songlistBox:GetHeight())
-- 			self:SetHeight(self.listContainer:GetHeight() + self.lCYmod);
-- 			self.listFrame:SetHeight(self:GetHeight() - self.lFYmod);
-- 			self.resizeCtrl:SetTop(self:GetHeight() - 20); 
-- 		end
					
-- 		self:SetTracklistTop( self.listContainer:GetHeight() - Settings.TracksHeight )
-- 		self:AdjustTracklistSize( Settings.TracksHeight )			
-- 		self:SetSonglistHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - self.tracklistBox:GetHeight() - 26);
-- 		self.settingsBtn:SetPosition(self:GetWidth()/2 - 55, self:GetHeight() - 30 );
-- 		self.SyncInfoBtn:SetPosition(self:GetWidth() - 150, self:GetHeight() - 30 );	
-- 		--self.cbFilters:SetPosition( self:GetWidth()/2 + 65, self:GetHeight() - 30 );
		
-- 		if (CharSettings.InstrSlots[1]["visible"]) then
-- 			for j = 1, CharSettings.InstrumentSlots_Rows do
-- 				local TopShift = 75 + InstrumentSlots_Shift * ( j - 1 );
-- 				self.instrContainer[j]:SetTop( self:GetHeight() - TopShift );
-- 			end
-- 		end
-- 	end
-- end

-- action for toggling instrument slots on and off
function SongbookWindow:ToggleInstrSlots()
	local hMod = InstrumentSlots_Shift * CharSettings.InstrumentSlots_Rows;
	if (CharSettings.InstrSlots[1]["visible"]) then		
		CharSettings.InstrSlots[1]["visible"] = false;
		
		self:SetInstrSlots( -hMod );
		for j = 1, CharSettings.InstrumentSlots_Rows do
			self.instrContainer[j]:SetVisible( false );
		end
	else
		CharSettings.InstrSlots[1]["visible"] = true;
		
		self:SetInstrSlots( hMod );
		for j = 1, CharSettings.InstrumentSlots_Rows do
			self.instrContainer[j]:SetVisible( true );
		end
	end
end

-- function SongbookWindow:SetInstrSlots( delta )
-- 	self.lFYmod = self.lFYmod + delta;
-- 	self.lCYmod = self.lCYmod + delta;
-- 	self.listFrame:SetHeight(self.listFrame:GetHeight() - delta);
-- 	self.listContainer:SetHeight(self.listContainer:GetHeight() - delta);
-- 	self:SetSonglistHeight(self.songlistBox:GetHeight() - delta);
-- 	if (Settings.TracksVisible) then
-- 		self:MoveTracklistTop( -delta )
-- 		--self.tracklistBox:SetTop(self.tracklistBox:GetTop() - hMod);
-- 		--self.sepSongsTracks:SetTop(self.sepSongsTracks:GetTop() - hMod);		
-- 	end
	
-- 	local height = self:GetHeight();
-- 	if height < 45 then height = 45; end
	
-- 	local listContainerHeight = height - self.lCYmod;
-- 	local tracksHeight = 0;
-- 	if Settings.TracksVisible then tracksHeight = Settings.TracksHeight; end
-- 	if listContainerHeight < Settings.DirHeight + 13 + tracksHeight + 13 + 40 then
-- 		listContainerHeight = Settings.DirHeight + 13 + tracksHeight + 13 + 40;
-- 		height = listContainerHeight + self.lCYmod;
-- 	end
	
-- 	self:SetHeight( height );
-- 	self:ResizeAll( );
-- 	self.resizeCtrl:SetPosition( self:GetWidth() - self.resizeCtrl:GetWidth(), self:GetHeight() - self.resizeCtrl:GetHeight() );
-- end

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
	if (CharSettings.InstrSlots[1]["visible"]) then
		CharSettings.InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows + 1;
		local InstrumentSlots_Rows = CharSettings.InstrumentSlots_Rows;
		
		table.insert(self.instrContainer , Turbine.UI.Control);
		
		self.instrContainer[InstrumentSlots_Rows] = Turbine.UI.Control();
		self.instrContainer[InstrumentSlots_Rows]:SetParent( self );
		local TopShift = 75 + InstrumentSlots_Shift * ( InstrumentSlots_Rows - 1 );
		self.instrContainer[InstrumentSlots_Rows]:SetPosition( 10, self:GetHeight() - TopShift );
		if (CharSettings.InstrSlots[1]["visible"]) then
			self.instrContainer[InstrumentSlots_Rows]:SetVisible( true );
		else
			self.instrContainer[InstrumentSlots_Rows]:SetVisible( false );
		end
		self.instrContainer[InstrumentSlots_Rows]:SetSize( 40*CharSettings.InstrSlots[1]["number"], 38 );
		self.instrContainer[InstrumentSlots_Rows]:SetZOrder(90);
		
		
		table.insert(self.instrSlot , {});
		
		table.insert(CharSettings.InstrSlots , {});
		CharSettings.InstrSlots[InstrumentSlots_Rows]["visible"] = true;
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
	if (CharSettings.InstrSlots[1]["visible"]) then
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
	Settings.FiltersState = self.bFilter
	Settings.ChiefMode = SyncManager.chiefMode
	Settings.TimerState = self.bTimer
	Settings.TimerCountdown = self.bTimerCountdown
	Settings.ReadyColState = self.bShowReadyChars
	Settings.ReadyColHighlight = self.bHighlightReadyCol
	Settings.TimerWindowVisible = self.TimerWindowVisible
	Settings.HelpWindowDisable = self.HelpWindowDisable
	Settings.UseRaidChat = SyncManager.useRaidChat
	Settings.UseFellowshipChat = SyncManager.useFellowshipChat
	Settings.PlayersSyncInfoWindowPosition.Left = PlayersSyncInfoWindow:GetLeft()
	Settings.PlayersSyncInfoWindowPosition.Top = PlayersSyncInfoWindow:GetTop()
	Settings.PlayersSyncInfoWindowPosition.Width = PlayersSyncInfoWindow:GetWidth()
	Settings.PlayersSyncInfoWindowPosition.Height = PlayersSyncInfoWindow:GetHeight()

	SettingsManager.Save()
end


function SongbookWindow:GetFilters()
	local filters = { maxPartCount = self.maxPartCount }
	if self.cbComposer and self.cbComposer:IsChecked() then
		filters.composer = self.editComposer:GetText()
	end
	if self.cbPartcount and self.cbPartcount:IsChecked() then
		filters.partcount = self.editPartcount:GetText()
	end
	if self.cbGenre and self.cbGenre:IsChecked() then
		filters.genre = self.editGenre:GetText()
	end
	if self.cbMood and self.cbMood:IsChecked() then
		filters.mood = self.editMood:GetText()
	end
	if self.cbAuthor and self.cbAuthor:IsChecked() then
		filters.author = self.editAuthor:GetText()
	end
	return filters
end

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

function SongbookWindow:ClearSongState()
	SyncManager.ClearSongState()
	self:ClearSetups()
	self:SetTrackColours(SongLibrary.selectedTrack)
	self:SetPlayerColours()
	self:SetListboxColours(self.songlistBox)
end

function SongbookWindow:SongStarted()
	self:ClearSongState()

	TimerWindow:SetSongText( SyncManager.syncedTrackName )

	songbookWindow.syncMessageTitle:SetText("")
	songbookWindow.syncMessageTitle:SetVisible(false)
	MatchedSongsWindow:SetVisible( false )

	SyncStartWindow.Message:SetText("Nothing to Start")
	SyncStartWindow.YesSlot:SetVisible( false )
	SyncStartWindow.NoSlot:SetVisible( false )
	SyncStartWindow.YesIcon:SetVisible( false )
	SyncStartWindow.NoIcon:SetVisible( false )

	self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined , "" )
	self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut )
	self.syncStartSlot:SetVisible( true )

	if self.bInstrumentOk == false then
		self.tracksMsg:SetForeColor( ColorTheme.colourDefault )
		self.tracksMsg:SetVisible( false )
		self.bInstrumentOk = true
	end
	if self.bTimer then self:StartTimer() end
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
	
	-- self:ResizeAll( );
	self:ReflowLayout();
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
	self.bInstrumentOk = true -- only set to false if we can successfully determine track and equipped instrument
	local iName = InstrumentManager.GetInstrumentIndex( item:GetName( ):lower( ) )
	if not iName then return; end -- can't determine equipped instrument, disable message

	local iTrackInstrument, bOk = InstrumentManager.CheckTracksForInstrument( sTrack, iName, InstrumentManager.genericNames )
	if iTrackInstrument then
		self.bInstrumentOk = bOk
	else -- try localized names
		iTrackInstrument, bOk = InstrumentManager.CheckTracksForInstrument( sTrack, iName, aInstrumentsLoc )
		if iTrackInstrument then
			self.bInstrumentOk = bOk
		end
	end

	if not iTrackInstrument then return; end -- could not determine the track instrument
	self:SetInstrumentMessage( aInstrumentsLoc[ iTrackInstrument ] ) -- print the localized name
end
	

function SongbookWindow:SetInstrumentMessage( sInstr )
	if self.bInstrumentOk then
		self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold22 );
		self.tracksMsg:SetForeColor( ColorTheme.colourDefault )
		self.tracksMsg:SetVisible( false )
	else
		self.tracksMsg:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold18 );
		self.tracksMsg:SetForeColor( ColorTheme.colourWrongInstrument )
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
	if SongLibrary.selectedSongIndex then
		--self:ListTracks( SongLibrary.selectedSongIndex )
		--self:RefreshPlayerListbox( )
		self:SetTrackColours( SongLibrary.selectedTrack );
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
	if self.listboxPlayers == nil then return end
	self.listboxPlayers:ClearItems()
	SyncManager.RefreshPlayers()
	self:SetPlayerColours()
	self:UpdateMaxPartCount()
	if self.maxPartCount then self:UpdateSongs() end
	self:UpdateSetupColours()
end


-- Update item colours in party listbox to indicate ready states
function SongbookWindow:SetPlayerColours( )
	if not SyncManager.players or not self.listboxPlayers then return; end

	local iMember;
	for iMember=1,self.listboxPlayers:GetItemCount( ) do
		local item = self.listboxPlayers:GetItem( iMember );
		if( SyncManager.players[ item:GetText( ) ] == nil ) then	-- should not happen
			item:SetForeColor( ColorTheme.colourDefault );
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chNone, false ); end
		elseif( SyncManager.players[ item:GetText( ) ] == 0 ) then -- present, but no song ready
			item:SetForeColor( ColorTheme.colourDefault );
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chNone, false ); end
		elseif SyncManager.currentSongReady and SyncManager.currentSongReady[ item:GetText( ) ] == 1 then
			item:SetForeColor( ColorTheme.colourReady ); -- Track from the currently displayed song ready
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chReady, false ); end
		elseif SyncManager.currentSongReady and SyncManager.currentSongReady[ item:GetText( ) ] == 2 then
			item:SetForeColor( ColorTheme.colourReadyMultiple ); -- Correct song, but same track as another player
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chMultiple, true ); end
		elseif SyncManager.currentSongReady and SyncManager.currentSongReady[ item:GetText( ) ] == 3 then
			item:SetForeColor( ColorTheme.colourDifferentSetup ); -- Correct song, but track not in current setup
			if self.bShowReadyChars then self.listboxPlayers:SetColumnChar( iMember, self.chWrongPart, true ); end
		else
			item:SetForeColor( ColorTheme.colourDifferentSong ); -- Track ready, but different song
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
	if not SongDB.Songs[SongLibrary.selectedSongIndex] or not SongDB.Songs[SongLibrary.selectedSongIndex].Setups then return; end
	
	for iItem = 1, self.listboxSetups:GetItemCount( ) do
		self.listboxSetups:GetItem( iItem ):SetBackColor( ColorTheme.backColourDefault );
	end

	local selTrack = self.tracklistBox:GetSelectedIndex( );
	
	SongLibrary.setupTrackIndices = { };
	SongLibrary.setupListIndices = { };
	SongLibrary.currentSetup = nil;

	if not iSetup or iSetup >= self.listboxSetups:GetItemCount( ) then
		self:ListTracks( SongLibrary.selectedSongIndex );
		SongLibrary.selectedSetupCount = nil
	else
		SongLibrary.currentSetup = iSetup;
		self.tracklistBox:ClearItems( );
		SyncInfolistbox:ClearItems( );
		for i = 1, #SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ iSetup ] do
			local iTrack = SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ iSetup ]:byte( i ) - 64;
			SongLibrary.setupTrackIndices[ i ] = iTrack;
			SongLibrary.setupListIndices[ iTrack ] = i;
			self:AddTrackToList( SongLibrary.selectedSongIndex, iTrack )
		end
		SongLibrary.selectedSetupCount = #SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ iSetup ]
	end

	local selItem = self.listboxSetups:GetSelectedItem( );
	if selItem then selItem:SetBackColor( ColorTheme.backColourHighlight ); end
	
	self:SelectTrack( 1 ); --selTrack );
	self:SetPlayerColours( );
	local found = self.tracklistBox:GetItemCount( );
	self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
end

function SongbookWindow:UpdateSetupColours(  )
	if not self.listboxSetups or not SongDB.Songs[SongLibrary.selectedSongIndex] or not SongDB.Songs[SongLibrary.selectedSongIndex].Setups then return; end
	
	self:UpdateTrackReadyString( );

	local item;
	local matchPattern;
	local antiMatchPattern;
	local matchLength = 0;
	for i = 1, self.listboxSetups:GetItemCount( ) - 1 do
		item = self.listboxSetups:GetItem( i );

		matchPattern = "[" .. SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ i ] .. "]";
		antiMatchPattern = "[^" .. SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ i ] .. "]";
		_, matchLength = string.gsub( SyncManager.readyTracks, matchPattern, " " )

		if SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ i ] == SyncManager.readyTracks then
			item:SetForeColor( ColorTheme.colourReady );
		elseif string.match( SyncManager.readyTracks, antiMatchPattern ) then
			item:SetForeColor( Turbine.UI.Color( 0.7, 0, 0 ) );
		elseif matchLength and matchLength + 1 == #SongDB.Songs[SongLibrary.selectedSongIndex].Setups[ i ] then
			item:SetForeColor( Turbine.UI.Color( 0, 0.7, 0 ) );
		else
			item:SetForeColor( ColorTheme.colourDefault );
		end
	end
end

function SongbookWindow:ClearSetups(  )
	if not self.listboxSetups then return; end	
	local selItem = self:SetListboxColours( self.listboxSetups, true );
	if selItem then selItem:SetBackColor( ColorTheme.backColourHighlight ); end
end

function SongbookWindow:UpdateTrackReadyString()
	SyncManager.UpdateReadyTracks(
		self.tracklistBox:GetItemCount(),
		SongLibrary.SelectedTrackIndex
	)
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
	SyncManager.ClearPlayerReadyStates()
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

function ListBoxCharColumn:SetSelectedIndex( item )
	-- if self.bShowReadyChars then
	-- 	ListBoxScrolled.SetSelectedIndex(i * 2 + 1);
	-- else
		-- ListBoxScrolled.SetSelectedIndex(i);
	-- end
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
		local SongIndex = SongLibrary.filteredIndices[ i ];
		
		local ReadyState = SyncManager.GetSongReadyState( SongIndex );
		
		if ReadyState[0] == nil then
			item:SetForeColor( ColorTheme.colourDefault );
			item:SetBackColor( ColorTheme.backColourDefault );
		elseif ReadyState[0] == 10 then
			item:SetForeColor( ColorTheme.colourSyncedHighlighted );
			if ReadyState[1] == "LocalPlayer" then
				item:SetBackColor( ColorTheme.backColourHighlight );
			else
				item:SetBackColor( ColorTheme.backColourDefault );
			end
		elseif ReadyState[0] == 0 then
			item:SetForeColor( ColorTheme.colourReadyMultiple2 );
			if ReadyState[1] == "LocalPlayer" then
				item:SetBackColor( ColorTheme.backColourHighlight );
			else
				item:SetBackColor( ColorTheme.backColourDefault );
			end
		end
	end
	if bNoSelectionHighlight then return nil; end 
	local selectedItem = listbox:GetSelectedItem( )
	if selectedItem then selectedItem:SetForeColor( ColorTheme.colourDefaultHighlighted ); end
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
	if Settings.TracksVisible then height = height - self.tracklistBox:GetHeight() - 13; end
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
	if Settings.TracksVisible then height = height - Settings.TracksHeight - 13; end

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

-- function SongbookWindow:MoveTracklistTop( delta )
-- 	self:SetTracklistTop( self.tracklistBox:GetTop( ) + delta )
-- end

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


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- action for changing track selection (trackid is listbox index)
function SongbookWindow:SelectTrack( trackid )
	self.tracklistBox.SetSelectedIndex(trackid);
	if self.bShowReadyChars then trackid = math.floor( (trackid+1) / 2 ); end
	SongLibrary.selectedTrack = trackid;
	local iTrack = SongLibrary.SelectedTrackIndex( trackid );
	local trackcount = #SongDB.Songs[SongLibrary.selectedSongIndex].Tracks;

	if SongLibrary.selectedTrack > 1 then
		if SongLibrary.selectedTrack == trackcount then
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( false );
		else
			self.trackPrev:SetVisible( true );
			self.trackNext:SetVisible( true );
		end
	end
	if ( SongLibrary.selectedTrack == 1) then
		self.trackPrev:SetVisible( false );
		if (trackcount == 1) then		
			self.trackNext:SetVisible( false );
		else
			self.trackNext:SetVisible( true );
		end
	end

	self.trackNumber:SetText(SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id);
	self.songTitle:SetText(SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Name);

	self.playSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong .. "\" " .. SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id);
	self.playSlot:SetShortcut( self.playSlotShortcut );
	self.playSlot:SetVisible( true );

	self.syncSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong .. "\" " .. SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id .. " " .. Strings["cmd_sync"]);
	self.syncSlot:SetShortcut( self.syncSlotShortcut );
	self.syncSlot:SetVisible( true );
	
	self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));		
	self.shareSlot:SetVisible( true );
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	self:PlayerSyncInfo();
	
	if not SyncManager.missingMatchedSong then

		if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename == SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong then
			self.syncMessageTitle:SetVisible(false);
		else
			if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename ~= "" then
				if self.syncMessageTitle:GetText() ~= "" then
					self.syncMessageTitle:SetVisible(true);
				end
			end
		end
	end
	
	self:SetTrackColours( SongLibrary.selectedTrack );
end

-- action for setting focus on the track list
function SongbookWindow:SetTrackColours( iSelectedTrack )
	if not self.tracklistBox or self.tracklistBox:GetItemCount( ) < 1 then return; end
	self:ClearPlayerReadyStates( ); -- Clear ready states for currently displayed song
	local trackcount = #SongDB.Songs[SongLibrary.selectedSongIndex].Tracks;
	
	local numberOfCorrectStates = 0;
	for iTrack = 1,trackcount do
		if SongLibrary.currentSetup and not SongLibrary.setupListIndices[ iTrack ] then
			SyncManager.GetTrackReadyState( SongLibrary.selectedSongIndex, iTrack, 3 );
		else
			local iList = iTrack;
			if SongLibrary.setupListIndices[ iTrack ] then iList = SongLibrary.setupListIndices[ iTrack ]; end
			local item = self.tracklistBox:GetItem(iList);
			local readyState = SyncManager.GetTrackReadyState( SongLibrary.selectedSongIndex, iTrack );
			
			
			if readyState[0] == 10 then numberOfCorrectStates = numberOfCorrectStates + 1; end
			
			item:SetForeColor( ColorTheme.GetColourForTrack( readyState[0], iList == iSelectedTrack ) );
			item:SetBackColor( ColorTheme.GetBackColourForTrack( readyState[0] , readyState[1] , readyState[8] ) );
			
			
			self:SetTrackReadyChar( iList, readyState[0] );
			
			local sTerseName = SongLibrary.TerseTrackname( SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Name );
			local Track_Instrument = InstrumentManager.FindInstrumentInTrack( sTerseName );
			local Track_item = SyncInfolistbox:GetItem(iTrack);
			Track_item:SetText( "[" .. SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[iTrack].Id .. "] " .. Track_Instrument[1] );

			Track_item:SetForeColor( ColorTheme.GetColourForTrack( readyState[0], iList == iSelectedTrack ) );
			Track_item:SetBackColor( ColorTheme.GetBackColourForTrack( readyState[0] , readyState[1] , readyState[8] ) );

			for i = 0, readyState[4]-1 do
				if tonumber( readyState[3][i] ) > 0 then
					Track_item:AppendText("  - <rgb=0x00FF00>" .. readyState[2][i] .. "</rgb> [<rgb=0x00FF80>" ..
						InstrumentManager.GetName(tonumber( readyState[3][i] )) .. "</rgb>]" );
				else
					Track_item:AppendText("  - <rgb=0x00FF00>" .. readyState[2][i] .. "</rgb> [<rgb=0x00FF80>No Instrument</rgb>]" );
				end
			end

			for i = 0, readyState[7]-1 do
				if tonumber( readyState[6][i] ) > 0 then
					Track_item:AppendText("  - <rgb=0xFF0000>" .. readyState[5][i] .. "</rgb> [<rgb=0xFF0080>" ..
						InstrumentManager.GetName(tonumber( readyState[6][i] )) .. "</rgb>]" );
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
		SyncManager.syncStartReady = true;
		self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"] );
		self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut );
		self.syncStartSlot:SetVisible( true );
	else
		SyncManager.syncStartReady = false;
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
	if not self.sendSyncInfoSlot then return 0; end
	
	local trackcount = #SongDB.Songs[SongLibrary.selectedSongIndex].Tracks;
	local Track_Name = SongDB.Songs[SongLibrary.selectedSongIndex].Tracks[SongLibrary.selectedTrack].Name; 

	local equippedInstrument_Index = self:UpdatePlayerTitle();
	if equippedInstrument_Index == nil then return; end
	local Track_Instrument = InstrumentManager.FindInstrumentInTrack( Track_Name );
	local Track_Instrument_Index = Track_Instrument[0];
	local CorrectInstrument = InstrumentManager.CompareInstrument(equippedInstrument_Index, Track_Instrument_Index);
	if CorrectInstrument == 0 then
		self.syncIcon:SetBackground(gDir .. "icn_s_f.tga");
		SyncManager.correctInstrument = false;
	else
		self.syncIcon:SetBackground(gDir .. "icn_s.tga");
		SyncManager.correctInstrument = true;
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
		self.MessageTitle:SetText("SongBook is using Fellowship channel");
	else
	if SyncManager.useRaidChat then
		SyncManager.chatChannel = "/ra";
		self.MessageTitle:SetText("SongBook is using Raid channel");
	else
		if SyncManager.userChatNumber ~= 0 and SyncManager.userChatNumber ~= nil then
			SyncManager.chatChannel = "/" .. SyncManager.userChatNumber;
			self.MessageTitle:SetText("SongBook is using User Chat channel " .. SyncManager.userChatNumber .. " - " .. SyncManager.userChatName);
		else
			if PartyMemberCount > 6 or SyncManager.isRaid then
				SyncManager.chatChannel = "/ra";
				if not SyncManager.userChatBlocked then
					self.MessageTitle:SetText("SongBook is using Raid channel");
				else
					songbookWindow.MessageTitle:SetText("Low level to use User chat. Now using Raid channel");
				end
			elseif PartyMemberCount > 1 then
				SyncManager.chatChannel = "/f";
				if not SyncManager.userChatBlocked then
					self.MessageTitle:SetText("SongBook is using Fellowship channel");
				else
					songbookWindow.MessageTitle:SetText("Low level to use User chat. Now using Fellowship channel");
				end
			end
		end
	end
	end

	if CorrectSongAndTrack == 1 and SyncManager.localPlayerSynced then

		self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, SyncManager.chatChannel .. " <rgb=#211f1d>@SBL|" .. self.Player_Name .. "|" .. SongDB.Songs[SongLibrary.selectedSongIndex].Filename .. "|" .. Track_Name .. "|1|" .. CorrectSongAndTrack .. "|" .. trackcount .. "|" .. SongLibrary.selectedSongIndexListBox .. "|" .. SongLibrary.selectedSongIndex .. "|" .. SongLibrary.selectedTrack .. "|" .. Track_Instrument_Index .. "|".. equippedInstrument_Index .. "|" .. CorrectInstrument .. "|</rgb>");
		self.sendSyncInfoSlot:SetShortcut( self.sendSyncInfoSlotShortcut );
		self.sendSyncInfoSlot:SetVisible( true );
	else
		self.sendSyncInfoSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "");
		self.sendSyncInfoSlot:SetShortcut( self.sendSyncInfoSlotShortcut );
		self.sendSyncInfoSlot:SetVisible( true );
	end

	return equippedInstrument_Index;
end
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
		-- self:ResizeAll( );
		self:ReflowLayout();
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
	SyncManager.SetUserChatName(Text)
	self.joinUserChatSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, "/joinchannel " .. SyncManager.userChatName )
	self.joinUserChatSlot:SetShortcut( self.joinUserChatSlotShortcut )
	self.joinUserChatSlot:SetVisible( true )
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
		self.PlayerTitle:SetText(self.Player_Name .. " - No Instrument Equipped")
		return
	end
	self.PlayerTitle:SetText(self.Player_Name .. " - " .. instrumentName)
	return equippedIndex
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SongbookWindow:Update_syncMessage (SongIndex, PlayerName, TrackName)

	SyncManager.multipleSongsMatch = false;
	MatchedSongsWindow:SetVisible(false);

	if SongIndex[0] > 1 and not Settings.hideMatchedSongsPopup then
		SyncManager.missingMatchedSong = false;
		if PlayerName == SyncManager.localPlayerName then
			-- OtherPlayer_SyncedSong_Index = SongLibrary.selectedSongIndex;
			-- SyncManager.otherPlayerSong.filepath = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filepath;
			-- SyncManager.otherPlayerSong.filename = SongDB.Songs[OtherPlayer_SyncedSong_Index].Filename;

			-- self.syncMessageTitle:SetText(PlayerName .. "-> " .. SyncManager.otherPlayerSong.filepath .. " " .. SyncManager.otherPlayerSong.filename);

			-- if not SyncManager.otherPlayerSynced then
				-- self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
			-- else
				-- self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
			-- end

			-- self.syncMessageTitle:SetVisible(false);
		else
			--MatchedSongsIndex = SongIndex;
			SyncManager.multipleSongsMatch = true;
			self.syncMessageTitle:SetText(PlayerName .. "-> " .. TrackName .. " - Multiple songs match");
			if not SyncManager.otherPlayerSynced then
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
			else
				self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
			end
			self.syncMessageTitle:SetVisible(true);

			MatchedSongsListbox:ClearItems( );
			for i = 1, SongIndex[0] do
				local SongItem = Turbine.UI.Label();
				SongItem:SetMultiline( false )
				SongItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				SongItem:SetSize( 2000, 20 );
				SongItem:SetMarkupEnabled(true);
				if not SyncManager.otherPlayerSynced then
					SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle );
				else
					SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
				end
				SongItem:SetBackColor( ColorTheme.backColourDefault );
				SongItem:SetText( SongDB.Songs[SongIndex[i]].Filepath .. " " .. SongDB.Songs[SongIndex[i]].Filename );
				MatchedSongsListbox:AddItem( SongItem );

				SongItem.MouseEnter = function(sender, args)
					if SongItem:IsVisible() then
						if not SyncManager.otherPlayerSynced then
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_Highlighted );
						else
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_Highlighted_OnlySynced );
						end
					end
				end
				SongItem.MouseLeave = function(sender, args)
					if SongItem:IsVisible() then
						if not SyncManager.otherPlayerSynced then
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle );
						else
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
						end
					end
				end
				SongItem.MouseDown = function(sender,args)
					if SongItem:IsVisible() then
						if not SyncManager.otherPlayerSynced then
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_MouseDown );
						else
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_MouseDown_OnlySynced );
						end
					end
				end
				SongItem.MouseUp = function(sender,args)
					if SongItem:IsVisible() then
						if not SyncManager.otherPlayerSynced then
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle );
						else
							SongItem:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
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

		self.syncMessageTitle:SetText(PlayerName .. "-> " .. SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename);

		if not SyncManager.otherPlayerSynced then
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
		else
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
		end

		if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename == SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong then
			self.syncMessageTitle:SetVisible(false);
		else
			if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename ~= "" then
				self.syncMessageTitle:SetVisible(true);
			end
		end
	elseif SongIndex[0] == 0 then
		self.syncMessageTitle:SetText("You don't have the same song. " .. PlayerName .. "-> " .. TrackName);
		if not SyncManager.otherPlayerSynced then
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
		else
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
		end
		self.syncMessageTitle:SetVisible(true);
		SyncManager.missingMatchedSong = true;
	elseif SongIndex[0] == 1 then
		SyncManager.missingMatchedSong = false;

		SyncManager.otherPlayerSong.index = SongIndex[1];
		SyncManager.otherPlayerSong.filepath = SongDB.Songs[SyncManager.otherPlayerSong.index].Filepath;
		SyncManager.otherPlayerSong.filename = SongDB.Songs[SyncManager.otherPlayerSong.index].Filename;

		self.syncMessageTitle:SetText(PlayerName .. "-> " .. SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename);

		if not SyncManager.otherPlayerSynced then
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle );
		else
			self.syncMessageTitle:SetForeColor( ColorTheme.colour_syncMessageTitle_OnlySynced );
		end

		if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename == SongDB.Songs[SongLibrary.selectedSongIndex].Filepath .. SongLibrary.selectedSong then
			self.syncMessageTitle:SetVisible(false);
		else
			if SyncManager.otherPlayerSong.filepath .. SyncManager.otherPlayerSong.filename ~= "" then
				self.syncMessageTitle:SetVisible(true);
			end
		end
	end
end

function SongbookWindow:ToggleTimerWindow( State )
	self.TimerWindowVisible = State
	TimerWindow:SetVisible( self.TimerWindowVisible )
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
	Help_Window:SetVisible(true);
end

function SongbookWindow:HelpWindow( )
	if not Settings.HelpWindowDisable and HelpWindow_Load_Flag == 1 then
		Help_Window:SetVisible(true);
	end
	HelpWindow_Load_Flag = 0;
end


