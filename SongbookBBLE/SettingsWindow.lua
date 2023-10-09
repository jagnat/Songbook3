SettingsWindow = class( Turbine.UI.Lotro.Window );


function SettingsWindow:NextPos( delta )
	delta = delta or 20
	self.yPos = self.yPos + delta
	return self.yPos
end

function SettingsWindow:CreateCheckBox( stringCode, yPos, state, func, width, xPos )
	width = width or 300
	xPos = xPos or 25
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetParent( self );
	cb:SetPosition(xPos, yPos );
	cb:SetSize(width,20);
	cb:SetText(" " .. Strings[stringCode]);
	cb:SetChecked(state == "yes" or state == "true" );
	cb.CheckedChanged = func
	return cb
end
	
function SettingsWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	local sCmd = 0;
	
	-- Nim: Fix location of settings window
	local xPos, yPos;
	local wndHeight = 500
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	if( Settings.WindowPosition.Left < 300 ) then xPos = 0; else xPos = Settings.WindowPosition.Left - 300; end
	if( Settings.WindowPosition.Top + 100 + wndHeight > displayHeight ) then
		yPos = displayHeight - wndHeight;
	else
		yPos = Settings.WindowPosition.Top + 100;
	end
	self:SetPosition( xPos, yPos );
	--Original line: self:SetPosition( Settings.WindowPosition.Left - 300, Settings.WindowPosition.Top + 100 );
	-- /Nim
	self:SetSize(550,wndHeight);
	--self:SetZOrder(20);
	self:SetText(Strings["ui_settings"]);

	self.yPos = 20
	-- general settings label
	self.genLabel = Turbine.UI.Label();
	self.genLabel:SetParent(self);
	self.genLabel:SetPosition(20,self:NextPos(20));
	self.genLabel:SetWidth(300);
	self.genLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.genLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.genLabel:SetText(Strings["ui_general"]);

	--Track display checkbox
	self.trackCheck = self:CreateCheckBox( "cb_parts", self:NextPos(20), Settings.TracksVisible,
		function(sender, args) songbookWindow:ToggleTracks(); end )
	
	--Search function enabled checkbox
	self.searchCheck = self:CreateCheckBox( "cb_search", self:NextPos(), Settings.SearchVisible,
		function(sender, args) songbookWindow:ToggleSearch(); end )
	
	--Show description in song list checkbox
	self.descCheck = self:CreateCheckBox( "cb_desc", self:NextPos(), Settings.DescriptionVisible,
		function(sender, args) songbookWindow:ToggleDescription(); end )
	
	--Show description first in song list checkbox
	self.descFirstCheck = self:CreateCheckBox( "cb_descfirst", self:NextPos(), Settings.DescriptionFirst,
		function(sender, args) songbookWindow:ToggleDescriptionFirst(); end )
	
	--Window visibility on load checkbox
	self.visibleCheck = self:CreateCheckBox( "cb_windowvis", self:NextPos(), Settings.WindowVisible,
		function(sender, args) self:ChangeVisibility(); end )

-- Badger settings --------------------------
	self.badgerLabel = Turbine.UI.Label();
	self.badgerLabel:SetParent(self);
	self.badgerLabel:SetPosition(20,self:NextPos(20));
	self.badgerLabel:SetWidth(300);
	self.badgerLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.badgerLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.badgerLabel:SetText(Strings["ui_badger"]);

	-- Filters on/off
	self.filterCheck = self:CreateCheckBox( "filters", self:NextPos(), Settings.FiltersState,
		function(sender, args) songbookWindow:ShowFilterUI( sender:IsChecked( ) ); end, 120 )

	-- Chief mode (uses party object, enables sync start quickslot)
	self.chiefCheck = self:CreateCheckBox( "cb_chief", self.yPos, Settings.ChiefMode,
		function(sender, args) songbookWindow:SetChiefMode( sender:IsChecked( ) ); end, 150, 170 )

	-- Countdown timer (if song duration available)
	self.countdownCheck = self:CreateCheckBox( "cb_timerDown", self:NextPos(), Settings.TimerCountdown,
		function(sender, args) songbookWindow.bTimerCountdown = sender:IsChecked( ); end, 150, 170 )
	-- Timer display on/off
	self.timerCheck = self:CreateCheckBox( "cb_timer", self.yPos, Settings.TimerState,
		function(sender, args) self:ToggleTimer( sender:IsChecked( ) ); end, 120 )
	if Settings.TimerState ~= "true" then self.countdownCheck:SetVisible( false ); end

	-- Hightlight issues in ready column (white background)
	self.readyHighlightCheck = self:CreateCheckBox( "cb_rdyColHL", self:NextPos(), Settings.ReadyColHighlight,
		function(sender, args) songbookWindow:HightlightReadyColumns( sender:IsChecked( ) ); end, 150, 170 )
	-- Additional ready state indicators
	self.readyColumnCheck = self:CreateCheckBox( "cb_rdyCol", self.yPos, Settings.ReadyColState,
		function(sender, args) self:ToggleReadyCol( sender:IsChecked( ) ); end, 145 )
	if Settings.ReadyColState ~= "true" then self.readyHighlightCheck:SetVisible( false ); end
-- /Badger settings -------------------------

-- Legendary Edition settings --------------------------

	self.UserChatLabel = Turbine.UI.Label();
	self.UserChatLabel:SetParent(self);
	self.UserChatLabel:SetPosition(300,40);
	self.UserChatLabel:SetWidth(200);
	self.UserChatLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.UserChatLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.UserChatLabel:SetText("User Chat Name");
	
	-- User Chat Name field
	self.UCNameInput = Turbine.UI.Lotro.TextBox();
	self.UCNameInput:SetParent(self);
	self.UCNameInput:SetPosition(300, 60);
	self.UCNameInput:SetSize(230, 20);
	self.UCNameInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	self.UCNameInput:SetMultiline(false);
	self.UCNameInput:SetText( Settings.UserChatName );
	self.UCNameInput:SetVisible( true );
	local searchFocus = false; 
	self.UCNameInput.KeyDown = function(sender, args)
		if (args.Action == 162) then
			if (searchFocus) then
				Settings.UserChatName = self.UCNameInput:GetText( );
				songbookWindow:UserChatNameChange( self.UCNameInput:GetText( ) );
			end
		end
	end
	self.UCNameInput.TextChanged = function(sender, args)
		if (searchFocus) then
			Settings.UserChatName = self.UCNameInput:GetText( );
			songbookWindow:UserChatNameChange( self.UCNameInput:GetText( ) );
		end
	end
	self.UCNameInput.FocusGained = function(sender, args)
		searchFocus = true;
	end
	self.UCNameInput.FocusLost = function(sender, args)
		searchFocus = false;
	end
	

	self.ManualChetSelectionLabel = Turbine.UI.Label();
	self.ManualChetSelectionLabel:SetParent(self);
	self.ManualChetSelectionLabel:SetPosition(300,80);
	self.ManualChetSelectionLabel:SetWidth(200);
	self.ManualChetSelectionLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.ManualChetSelectionLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.ManualChetSelectionLabel:SetText("Manual Chat Selection");
	
	--Raid Chat checkbox
	self.RaidChat_CB = Turbine.UI.Lotro.CheckBox();
	self.RaidChat_CB:SetParent( self );
	self.RaidChat_CB:SetPosition(300, 100 );
	self.RaidChat_CB:SetSize(200,20);
	self.RaidChat_CB:SetText(" Raid Chat");
	self.RaidChat_CB:SetChecked(Settings.UseRaidChat == "true" );
	self.RaidChat_CB.CheckedChanged = function(sender, args)
		songbookWindow:ToggleUseRaidChat( sender:IsChecked( ) );
		self.RaidChat_CB:SetChecked( sender:IsChecked( ) );
		
		if sender:IsChecked( ) then
			self.FellowshipChat_CB:SetChecked( false );
			songbookWindow:ToggleUseFellowshipChat( false );
		end
	end
	
	--Fellowship chat checkbox
	self.FellowshipChat_CB = Turbine.UI.Lotro.CheckBox();
	self.FellowshipChat_CB:SetParent( self );
	self.FellowshipChat_CB:SetPosition(300, 120 );
	self.FellowshipChat_CB:SetSize(200,20);
	self.FellowshipChat_CB:SetText(" Fellowship Chat");
	self.FellowshipChat_CB:SetChecked(Settings.UseFellowshipChat == "true" );
	self.FellowshipChat_CB.CheckedChanged = function(sender, args)
		songbookWindow:ToggleUseFellowshipChat( sender:IsChecked( ) );
		
		if sender:IsChecked( ) then
			self.RaidChat_CB:SetChecked( false );
			songbookWindow:ToggleUseRaidChat( false );
		end
	end

	self.AutoTrackPickerLabel = Turbine.UI.Label();
	self.AutoTrackPickerLabel:SetParent(self);
	self.AutoTrackPickerLabel:SetPosition(300,140);
	self.AutoTrackPickerLabel:SetWidth(200);
	self.AutoTrackPickerLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.AutoTrackPickerLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.AutoTrackPickerLabel:SetText("Automatic Part Picking");

	--Automatic track picking based on instrument
	self.AutoPickSongChange_CB = Turbine.UI.Lotro.CheckBox();
	self.AutoPickSongChange_CB:SetParent( self );
	self.AutoPickSongChange_CB:SetPosition(300, 160 );
	self.AutoPickSongChange_CB:SetSize(220,20);
	self.AutoPickSongChange_CB:SetText(" Auto-pick on song change");
	self.AutoPickSongChange_CB:SetChecked(Settings.AutoPickOnSongChange == "true" );
	self.AutoPickSongChange_CB.CheckedChanged = function(sender, args)
		Settings.AutoPickOnSongChange = sender:IsChecked() and "true" or "false";
	end

	--Automatic track picking based on instrument
	self.AutoPickInsChange_CB = Turbine.UI.Lotro.CheckBox();
	self.AutoPickInsChange_CB:SetParent( self );
	self.AutoPickInsChange_CB:SetPosition(300, 180 );
	self.AutoPickInsChange_CB:SetSize(240,20);
	self.AutoPickInsChange_CB:SetText(" Auto-pick on instrument change");
	self.AutoPickInsChange_CB:SetChecked(Settings.AutoPickOnInsChange == "true");
	self.AutoPickInsChange_CB.CheckedChanged = function(sender, args)
		Settings.AutoPickOnInsChange = sender:IsChecked() and "true" or "false";
	end
	
	
	self.TimerWindowLabel = Turbine.UI.Label();
	self.TimerWindowLabel:SetParent(self);
	self.TimerWindowLabel:SetPosition(300,200);
	self.TimerWindowLabel:SetWidth(200);
	self.TimerWindowLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.TimerWindowLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.TimerWindowLabel:SetText("Timer Window");
	
	--Timer Window display checkbox
	local Timer_Window_CB = Turbine.UI.Lotro.CheckBox();
	Timer_Window_CB:SetParent( self );
	Timer_Window_CB:SetPosition(300, 220 );
	Timer_Window_CB:SetSize(200,20);
	Timer_Window_CB:SetText(" Timer Window Visible");
	Timer_Window_CB:SetChecked(Settings.TimerWindowVisible == "true" );
	Timer_Window_CB.CheckedChanged = function(sender, args) songbookWindow:ToggleTimerWindow( sender:IsChecked( ) ); end;
	
	
	-- Help button
	self.HelpBtn = Turbine.UI.Lotro.Button();
	self.HelpBtn:SetParent(self);
	self.HelpBtn:SetPosition(self:GetWidth()-160,self:GetHeight()-35);
	self.HelpBtn:SetSize(100,20);
	self.HelpBtn:SetText("Help");
	
	self.HelpBtn.MouseDown = function(sender,args)
		songbookWindow:ShowHelpWindow();
	end
	
-- /Legendary Edition settings ----------------------------------------------	

	self.sbbtnLabel = Turbine.UI.Label();
	self.sbbtnLabel:SetParent(self);
	self.sbbtnLabel:SetPosition(20,self:NextPos(25));
	self.sbbtnLabel:SetWidth(300);
	self.sbbtnLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.sbbtnLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.sbbtnLabel:SetText(Strings["ui_icon"]);
	
	--Songbook button visibility checkbox	
	self.toggleCheck = self:CreateCheckBox( "cb_iconvis", self:NextPos(20), Settings.ToggleVisible,
		function(sender, args) self:ChangeToggleVisibility(); end )

	-- Toggle button opacity controls
	self.toggleOpacityLabel = Turbine.UI.Label();
	self.toggleOpacityLabel:SetParent(self);
	self.toggleOpacityLabel:SetPosition(20,self:NextPos(30));
	self.toggleOpacityLabel:SetWidth(300);
	self.toggleOpacityLabel:SetText(Strings["ui_btn_opacity"]);
	
	self.toggleOpacityScroll = Turbine.UI.Lotro.ScrollBar();
	self.toggleOpacityScroll:SetParent(self);
	self.toggleOpacityScroll:SetOrientation( Turbine.UI.Orientation.Horizontal );
	self.toggleOpacityScroll:SetPosition(20,self:NextPos(15));
	self.toggleOpacityScroll:SetSize(220,10);
	self.toggleOpacityScroll:SetValue( 100*Settings.ToggleOpacity );
	self.toggleOpacityScroll:SetMaximum( 100 );
	self.toggleOpacityScroll:SetMinimum( 0 );
	self.toggleOpacityScroll:SetSmallChange( 1 );
	self.toggleOpacityScroll:SetLargeChange( 5 );
	self.toggleOpacityScroll:SetBackColor(Turbine.UI.Color(.1,.1,.1));
	
	self.toggleOpacityScroll.ValueChanged = function(sender,args)
		newvalue = sender:GetValue()/100;
		Settings.ToggleOpacity = newvalue;
		self.toggleOpacityInd:SetText(newvalue);
		toggleWindow:SetOpacity(newvalue);
	end
	
	self.toggleOpacityInd = Turbine.UI.Label();
	self.toggleOpacityInd:SetParent(self);
	self.toggleOpacityInd:SetPosition(250,self.yPos);
	self.toggleOpacityInd:SetWidth(30);
	self.toggleOpacityInd:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.toggleOpacityInd:SetText(Settings.ToggleOpacity);

	----------------------------------------------------------------------
	self.instrLabel = Turbine.UI.Label();
	self.instrLabel:SetParent(self);
	self.instrLabel:SetPosition(300,240);
	self.instrLabel:SetWidth(250);
	self.instrLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.instrLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.instrLabel:SetText(Strings["ui_instr"]);
	
	--Instrument bar visibility checkbox
	self.instrCheck = Turbine.UI.Lotro.CheckBox();
	self.instrCheck:SetParent( self );
	self.instrCheck:SetPosition(300, 260 );
	self.instrCheck:SetSize(200,20);
	self.instrCheck:SetText(" " .. Strings["cb_instrvis"]);
	self.instrCheck:SetChecked(CharSettings.InstrSlots[1]["visible"] == "true" or CharSettings.InstrSlots[1]["visible"] == "yes");
	self.instrCheck.CheckedChanged = function(sender, args) songbookWindow:ToggleInstrSlots(); end;
	
	--self.instrCheck = self:CreateCheckBox( "cb_instrvis", self:NextPos(20), CharSettings.InstrSlots[1]["visible"],
		--function(sender, args) songbookWindow:ToggleInstrSlots(); end )
	
	-- clear slots button
	self.clrSlotsBtn = Turbine.UI.Lotro.Button();
	self.clrSlotsBtn:SetParent(self);
	self.clrSlotsBtn:SetPosition(300, 285);
	self.clrSlotsBtn:SetSize(110,20);
	self.clrSlotsBtn:SetText(Strings["ui_clr_slots"]);
	
	self.clrSlotsBtn.MouseDown = function(sender,args)
		songbookWindow:ClearSlots();
	end
	
	
	self.slotsLabel = Turbine.UI.Label();
	self.slotsLabel:SetParent(self);
	self.slotsLabel:SetPosition(300, 315);
	self.slotsLabel:SetWidth(50);
	self.slotsLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.slotsLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro14 );
	self.slotsLabel:SetText("Slots:");
	
	-- add / remove slots
	self.addSlotBtn = Turbine.UI.Lotro.Button();
	self.addSlotBtn:SetParent(self);
	self.addSlotBtn:SetPosition(350, 315);
	self.addSlotBtn:SetSize(50,20);
	self.addSlotBtn:SetText(Strings["ui_add_slot"]);
	
	self.addSlotBtn.MouseDown = function(sender,args)
		songbookWindow:AddSlot();
	end
	
	self.delSlotBtn = Turbine.UI.Lotro.Button();
	self.delSlotBtn:SetParent(self);
	self.delSlotBtn:SetPosition(410	, 315);
	self.delSlotBtn:SetSize(70,20);
	self.delSlotBtn:SetText(Strings["ui_del_slot"]);
	
	self.delSlotBtn.MouseDown = function(sender,args)
		songbookWindow:DelSlot();
	end	
	
	
	self.rowsLabel = Turbine.UI.Label();
	self.rowsLabel:SetParent(self);
	self.rowsLabel:SetPosition(300, 340);
	self.rowsLabel:SetWidth(50);
	self.rowsLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.rowsLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro14 );
	self.rowsLabel:SetText("Rows:");
	
	-- add / remove slots rows
	self.addSlotBtn_rows = Turbine.UI.Lotro.Button();
	self.addSlotBtn_rows:SetParent(self);
	self.addSlotBtn_rows:SetPosition(350, 340);
	self.addSlotBtn_rows:SetSize(50,20);
	self.addSlotBtn_rows:SetText(Strings["ui_add_slot"]);
	
	self.addSlotBtn_rows.MouseDown = function(sender,args)
		songbookWindow:AddSlot_row();
	end
	self.delSlotBtn_rows = Turbine.UI.Lotro.Button();
	self.delSlotBtn_rows:SetParent(self);
	self.delSlotBtn_rows:SetPosition(410, 340);
	self.delSlotBtn_rows:SetSize(70,20);
	self.delSlotBtn_rows:SetText(Strings["ui_del_slot"]);
	
	self.delSlotBtn_rows.MouseDown = function(sender,args)
		songbookWindow:DelSlot_row();
	end	
	
	----------------------------------------------------------------------
	
	
	-- commands label
	self.cmdLabel = Turbine.UI.Label();
	self.cmdLabel:SetParent(self);
	self.cmdLabel:SetPosition(20,self:NextPos(25));
	self.cmdLabel:SetWidth(300);
	self.cmdLabel:SetForeColor(Turbine.UI.Color(1,0.77,0.64,0.22));
	self.cmdLabel:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	self.cmdLabel:SetText(Strings["ui_custom"]);
	
	self.addBtn = Turbine.UI.Lotro.Button();
	self.addBtn:SetParent(self);
	self.addBtn:SetPosition(20,self:NextPos(20));
	self.addBtn:SetSize(85,20);
	self.addBtn:SetText(Strings["ui_cus_add"]);
	
	self.addBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ShowAddWindow(0);
		end
	end
	
	self.editBtn = Turbine.UI.Lotro.Button();
	self.editBtn:SetParent(self);
	self.editBtn:SetPosition(115,self.yPos);
	self.editBtn:SetSize(70,20);
	self.editBtn:SetText(Strings["ui_cus_edit"]);
	self.editBtn:SetEnabled(false);
	
	self.editBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self:ShowAddWindow(sCmd);
		end	
	end
	
	self.delBtn = Turbine.UI.Lotro.Button();
	self.delBtn:SetParent(self);
	self.delBtn:SetPosition(195,self.yPos);
	self.delBtn:SetSize(75,20);
	self.delBtn:SetText(Strings["ui_cus_del"]);
	self.delBtn:SetEnabled(false);
	
	self.delBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			self.cmdlistBox:RemoveItemAt(sCmd);
			local size = self:CountCmds();
			for i=sCmd,size do
				if (i == size) then
					Settings.Commands[tostring(i)] = nil;
				else					
					Settings.Commands[tostring(i)].Title = Settings.Commands[tostring(i+1)].Title;
					Settings.Commands[tostring(i)].Command = Settings.Commands[tostring(i+1)].Command;
				end
			end
			
			sCmd = 0;
	
			self.editBtn:SetEnabled(false);
			self.delBtn:SetEnabled(false);
		end	
	end
	
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent(self);
	self.listFrame:SetPosition(20, self:NextPos(25));
	self.listFrame:SetSize(self:GetWidth() - 40, 80);
	self.listFrame:SetBackColor(Turbine.UI.Color(1, 0.15, 0.15, 0.15));
	
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft(0);
	self.listFrame.heading:SetSize(100,13);
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_cmds"] );
	
	self.listBg = Turbine.UI.Control();
	self.listBg:SetParent(self.listFrame);
	self.listBg:SetPosition(0,15);
	self.listBg:SetSize(self.listFrame:GetWidth() - 19, self.listFrame:GetHeight() - 19);
	self.listBg:SetBackColor(Turbine.UI.Color(1, 0, 0, 0));
	
	self.cmdlistBox = Turbine.UI.ListBox();
	self.cmdlistBox:SetParent(self.listFrame);
	self.cmdlistBox:SetPosition(5,15);
	self.cmdlistBox:SetSize(self.listFrame:GetWidth() - 23,self.listFrame:GetHeight() - 19);
	
	self:RefreshCmds();
	
	self.cmdScroll = Turbine.UI.Lotro.ScrollBar();
	self.cmdScroll:SetParent(self);
	self.cmdScroll:SetOrientation( Turbine.UI.Orientation.Vertical );	
	self.cmdScroll:SetPosition(self.listFrame:GetLeft() + self.listFrame:GetWidth() -12, self.listFrame:GetTop() + 13);
	self.cmdScroll:SetSize(10,self.cmdlistBox:GetHeight());
	self.cmdScroll:SetValue(0);
	self.cmdlistBox:SetVerticalScrollBar( self.cmdScroll );	
	self.cmdScroll:SetVisible( false );
	
	self.cmdlistBox.SelectedIndexChanged = function(sender,args)
		self:ChangeCmd(sender:GetSelectedIndex());
	end
	
	
	function self:ChangeVisibility()
		if (Settings.WindowVisible == "yes") then
			Settings.WindowVisible = "no";			
		else
			Settings.WindowVisible = "yes";
		end
	end
	
	function self:ChangeToggleVisibility()
		if (Settings.ToggleVisible == "yes") then
			Settings.ToggleVisible = "no";
			toggleWindow:SetVisible(false);
		else
			Settings.ToggleVisible = "yes";
			toggleWindow:SetVisible(true);
		end
	end
	
	function self:ToggleTimer( bChecked )
		songbookWindow:ActivateTimer( bChecked )
		self.countdownCheck:SetVisible( bChecked )
	end

	function self:ToggleReadyCol( bChecked )
		songbookWindow:ShowReadyColumns( bChecked )
		self.readyHighlightCheck:SetVisible( bChecked )
	end

	function self:ChangeCmd(cmdId)
		self.editBtn:SetEnabled(true);
		self.delBtn:SetEnabled(true);
		local selectedItem = self.cmdlistBox:GetItem(cmdId);
		sCmd = cmdId;
		self:SetCmdFocus(sCmd);
	end
	
	function self:SetCmdFocus(cmdId)
		for i = 1,self.cmdlistBox:GetItemCount() do
			local item = self.cmdlistBox:GetItem(i);
			if (i == cmdId) then
				item:SetForeColor( Turbine.UI.Color(1, 0.15, 0.95, 0.15) );
			else
				item:SetForeColor( Turbine.UI.Color(1, 1, 1, 1) );
			end
		end		
	end
	
	self.saveBtn = Turbine.UI.Lotro.Button();
	self.saveBtn:SetParent(self);
	self.saveBtn:SetPosition(self:GetWidth()/2-50,self:GetHeight()-35);
	self.saveBtn:SetSize(100,20);	
	self.saveBtn:SetText(Strings["ui_save"]);
	self.saveBtn.MouseDown = function(sender,args)
		if(args.Button == Turbine.UI.MouseButton.Left) then
			songbookWindow:SaveSettings();
			self:SetVisible(false);
		end
	end
	
	function self:ShowAddWindow(cmdId)		
		self.addWindow = Turbine.UI.Lotro.Window();
		self.addWindow:SetPosition( self:GetLeft() - 50, self:GetTop() + 50);
		self.addWindow:SetSize( 315, 300 );
		self.addWindow:SetZOrder(21);
		self.addWindow:SetVisible(true);
		
		if (cmdId == 0) then
			self.addWindow:SetText(Strings["ui_cus_winadd"]);
		else
			self.addWindow:SetText(Strings["ui_cus_winedit"]);
		end

		--title label
		self.addWindow.titleLabel = Turbine.UI.Label();
		self.addWindow.titleLabel:SetParent(self.addWindow);
		self.addWindow.titleLabel:SetPosition(20,45);
		self.addWindow.titleLabel:SetSize(100,20);
		self.addWindow.titleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.titleLabel:SetText(Strings["ui_cus_title"]);
		
		--text input for command title
		self.addWindow.titleInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.titleInput:SetParent(self.addWindow);
		self.addWindow.titleInput:SetPosition(20,60);
		self.addWindow.titleInput:SetSize(270,20);
		self.addWindow.titleInput:SetMultiline(false);
		self.addWindow.titleInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		if (cmdId == 0) then
			self.addWindow.titleInput:SetText("");			
		else
			self.addWindow.titleInput:SetText(Settings.Commands[tostring(cmdId)].Title);
		end
		
		--title label
		self.addWindow.editLabel = Turbine.UI.Label();
		self.addWindow.editLabel:SetParent(self.addWindow);
		self.addWindow.editLabel:SetPosition(20,85);
		self.addWindow.editLabel:SetSize(100,20);
		self.addWindow.editLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.editLabel:SetText(Strings["ui_cus_command"]);
		
		--text input for command title
		self.addWindow.editInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.editInput:SetParent(self.addWindow);
		self.addWindow.editInput:SetPosition(20,100);
		self.addWindow.editInput:SetSize(270,20);
		self.addWindow.editInput:SetMultiline(false);
		self.addWindow.editInput:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		if (cmdId == 0) then
			self.addWindow.editInput:SetText("");			
		else
			self.addWindow.editInput:SetText(Settings.Commands[tostring(cmdId)].Command);
		end

		--ok button for saving
		self.addWindow.okBtn = Turbine.UI.Lotro.Button();
		self.addWindow.okBtn:SetParent(self.addWindow);
		self.addWindow.okBtn:SetPosition(20,130);
		self.addWindow.okBtn:SetSize(100,20);
		self.addWindow.okBtn:SetText(Strings["ui_ok"]);
		
		self.addWindow.error = Turbine.UI.Label();
		self.addWindow.error:SetParent(self.addWindow);
		self.addWindow.error:SetPosition(20,260);
		self.addWindow.error:SetSize(280,50);
		self.addWindow.error:SetForeColor(Turbine.UI.Color(1,1,0,0));
		self.addWindow.error:SetText("");
		
		
		self.addWindow.okBtn.MouseDown = function(sender,args)
			if(args.Button == Turbine.UI.MouseButton.Left) then
				if (self.addWindow.titleInput:GetText() ~= "" and self.addWindow.editInput:GetText() ~= "") then
					if (cmdId == 0) then
						newId = tostring(self:CountCmds()+1);
						Settings.Commands[newId] = {};
						Settings.Commands[newId].Title = self.addWindow.titleInput:GetText();	
						Settings.Commands[newId].Command = self.addWindow.editInput:GetText();					
					else
						cmdId = tostring(cmdId);
						Settings.Commands[tostring(cmdId)].Title = self.addWindow.titleInput:GetText();					
						Settings.Commands[tostring(cmdId)].Command = self.addWindow.editInput:GetText();					
					end
					
					self.addWindow.error:SetText("");
					self.addWindow:Close();		
					self:RefreshCmds();		
				else
					self.addWindow.error:SetText(Strings["ui_cus_err"]);
				end
			end
		end
		
		
		--cancel button		
		self.addWindow.cancelBtn = Turbine.UI.Lotro.Button();
		self.addWindow.cancelBtn:SetParent(self.addWindow);
		self.addWindow.cancelBtn:SetPosition(150,130);
		self.addWindow.cancelBtn:SetSize(100,20);
		self.addWindow.cancelBtn:SetText(Strings["ui_cancel"]);
		
		self.addWindow.cancelBtn.MouseDown = function(sender,args)
			if(args.Button == Turbine.UI.MouseButton.Left) then
				self.addWindow.error:SetText("");
				self.addWindow:Close();
			end
		end
		
		self.addWindow.help = Turbine.UI.Label();
		self.addWindow.help:SetParent(self.addWindow);
		self.addWindow.help:SetPosition(20,170);
		self.addWindow.help:SetSize(300, 200);
		self.addWindow.help:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		self.addWindow.help:SetText(Strings["ui_cus_help"]);
		
	end
	
end

function SettingsWindow:RefreshCmds()
	local size = self.cmdlistBox:GetItemCount();	
	self.cmdlistBox:ClearItems();
	
	for i=1,self:CountCmds() do
		local cmdItem = Turbine.UI.Label();
		cmdItem:SetText(Settings.Commands[tostring(i)].Title);		
		cmdItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		cmdItem:SetSize( 1000, 20 );				
		self.cmdlistBox:AddItem( cmdItem );	
	end
	sCmd = 0;
	
	self.editBtn:SetEnabled(false);
	self.delBtn:SetEnabled(false);
end

function SettingsWindow:CountCmds()
	local cSize = 0;
	for k, v in pairs(Settings.Commands) do 
		cSize = cSize + 1;
	end
	return cSize;
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SettingsWindow:Activated(sender, args)
	
	local width, height = self:GetSize();
	local left , top    = self:GetPosition();
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	
	local changeFlag = 0;
	-- Fix to prevent window to travel outside of the screen
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
		
	if changeFlag == 1 then
		self:SetPosition( left, top );
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
