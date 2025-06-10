-- Fanuilos, le linnathon

-- Songbook 3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TimerWindow = class(Turbine.UI.Window);

function TimerWindow:Constructor()
	Turbine.UI.Window.Constructor( self );
	--self:SetBackColor(Turbine.UI.Color(0,0,0,0));
	--self:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
	--self:SetBackColorBlendMode(Turbine.UI.BlendMode.AlphaBlend);
	self:SetPosition(50,1);
	--self:SetBackground(gDir .. "BarBase2.tga");
	self.Width = 150;
	self.Height = 94;
	self:SetSize(self.Width, self.Height);
	self:SetOpacity(1);
	self:SetZOrder(100);
	self:SetVisible( true );

	self.Timer_Frame = Turbine.UI.Control();
	self.Timer_Frame:SetParent(self);
	self.Timer_Frame:SetPosition(0,0);
	self.Timer_Frame:SetSize(self.Width, self.Height);
	self.Timer_Frame:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.Timer_Frame:SetBackground(gDir .. "SongbookTimer.tga");

	self.Timer_Label = Turbine.UI.Label( );
	self.Timer_Label:SetParent(self);
	self.Timer_Label:SetMultiline( false );
	self.Timer_Label:SetSize(self.Width,40);
	self.Timer_Label:SetPosition( 0, 9 );
	self.Timer_Label:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold24 );
	self.Timer_Label:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
	self.Timer_Label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	self.Timer_Label:SetZOrder( 100 );
	self.Timer_Label:SetVisible( true );
	self.Timer_Label:SetText( "0:00" );

	self.Song_Label = Turbine.UI.Label( );
	self.Song_Label:SetParent(self);
	--self.Song_Label:SetMultiline( false );
	self.Song_Label:SetSize(119,40);
	self.Song_Label:SetPosition( 17, 37 );
	self.Song_Label:SetFont( Turbine.UI.Lotro.Font.BookAntiquaBold18 );
	self.Song_Label:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
	self.Song_Label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	self.Song_Label:SetZOrder( 100 );
	self.Song_Label:SetVisible( true );
	--self.Song_Label:SetText( "Song" );

	self.Click_Label = Turbine.UI.Label( );
	self.Click_Label:SetParent(self);
	self.Click_Label:SetSize(self.Width, self.Height);
	self.Click_Label:SetPosition( 0, 0 );
	self.Click_Label:SetZOrder( 100 );
	self.Click_Label:SetVisible( true );

	self.Click_Label.MouseEnter = function(sender,args)
		--Timer_Frame:SetBackground("ChiranBBLE/SongbookBBLE/toggle_hover.tga");
		self:SetOpacity(0.9);
	end
	self.Click_Label.MouseLeave = function(sender,args)
		--Timer_Frame:SetBackground("ChiranBBLE/SongbookBBLE/toggle.tga");
		self:SetOpacity(1);
	end		
	self.Click_Label.MouseDown = function( sender, args )
		if(args.Button == Turbine.UI.MouseButton.Left) then
			sender.dragStartX = args.X;
			sender.dragStartY = args.Y;
			sender.dragging = true;
			sender.dragged = false;
			self:SetBackColor( Turbine.UI.Color(0,0,1,0) );
		end
	end
	self.Click_Label.MouseUp = function( sender, args ) 
		if (args.Button == Turbine.UI.MouseButton.Left) then			
			if (sender.dragging) then
				sender.dragging = false;
			end
			if not sender.dragged then
				songbookWindow:SetVisible( not songbookWindow:IsVisible() );
			end
			self:SetBackColor( Turbine.UI.Color(0,0,0,0) );
			Settings.ToggleLeft = self:GetLeft();
			Settings.ToggleTop = self:GetTop();			
		end
	end
	self.Click_Label.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local left, top = self:GetPosition();
			self:SetPosition( left + ( args.X - sender.dragStartX ), top + args.Y - sender.dragStartY );
			sender:SetPosition( 0, 0 );
			sender.dragged = true;
			-- checks to restrict moving outside the screen space
			if (self:GetLeft() > Turbine.UI.Display.GetWidth() - 150) then
				self:SetLeft(Turbine.UI.Display.GetWidth() - 150);				
			end
			if (self:GetLeft() < 0) then
				self:SetLeft(0);				
			end			
			if (self:GetTop() > Turbine.UI.Display.GetHeight() - 94) then
				self:SetTop(Turbine.UI.Display.GetHeight() - 94);				
			end
			if (self:GetTop() < 0) then
				self:SetTop(0);				
			end	
			
			Settings.Timer_WindowPosition.Left = self:GetLeft();
			Settings.Timer_WindowPosition.Top  = self:GetTop();
		end
	end
end

function TimerWindow:AdjustTimerPosition(displayWidth, displayHeight)
	if Settings.Timer_WindowPosition.Left + self.Width > displayWidth then
		Settings.Timer_WindowPosition.Left = displayWidth - self.Width;
	end
	if Settings.Timer_WindowPosition.Top + self.Height > displayHeight then
		Settings.Timer_WindowPosition.Top = displayHeight - self.Height;
	end
	if Settings.Timer_WindowPosition.Left < 0 then
		Settings.Timer_WindowPosition.Left = 0;
	end
	if Settings.Timer_WindowPosition.Top < 0 then
		Settings.Timer_WindowPosition.Top = 0;
	end
end

function TimerWindow:SetTimerText(str)
	self.Timer_Label:SetText(str)
end


function TimerWindow:SetSongText(str)
	self.Song_Label:SetText(str)
end