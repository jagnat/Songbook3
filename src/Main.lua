
-- Fanuilos, le linnathon

-- Songbook 3

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay" -- needed for access to party object

-- Some global variables to differentiate between the patch version and the alternate (BBLE) version
gPlugin = "Songbook3"
gDir = "Songbook3/resources/"
gSettings = "Songbook3Settings"

import "Songbook3.src.Class"; -- Turbine library included so that there's no outside dependencies
import "Songbook3.src.ToggleWindow";
import "Songbook3.src.SettingsWindow";
import "Songbook3.src.SongbookLang";
import "Songbook3.src";


songbookWindow = Songbook3.src.SongbookWindow();
if (Settings.WindowVisible == "yes") then
	songbookWindow:SetVisible( true );
else
	songbookWindow:SetVisible( false );
end
settingsWindow = Songbook3.src.SettingsWindow();
settingsWindow:SetVisible( false );

toggleWindow = Songbook3.src.ToggleWindow();
if (Settings.ToggleVisible == "yes") then
	toggleWindow:SetVisible( true );
else 
	toggleWindow:SetVisible( false );
end

songbookCommand = Turbine.ShellCommand();

function songbookCommand:Execute(cmd, args)
	if ( args == Strings["sh_show"] ) then
		songbookWindow:SetVisible( true );
	elseif ( args == Strings["sh_hide"] ) then
		songbookWindow:SetVisible( false );
	elseif ( args == Strings["sh_toggle"] ) then
		songbookWindow:SetVisible( not songbookWindow:IsVisible() );
	elseif ( args ~= nil ) then
		songbookCommand:GetHelp();
	end
end

function songbookCommand:GetHelp()
	Turbine.Shell.WriteLine( Strings["sh_help1"] );
	Turbine.Shell.WriteLine( Strings["sh_help2"] );
	Turbine.Shell.WriteLine( Strings["sh_help3"] );
end

Turbine.Shell.AddCommand( "songbook3", songbookCommand );
Turbine.Shell.WriteLine("Songbook 3 v".. Plugins["Songbook3"]:GetVersion() .." (Chiran + Brandy Badgers + Almiyan + Elamond)");
