import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay" -- needed for access to party object

-- Some global variables to differentiate between the patch version and the alternate (BBLE) version
gPlugin = "SongbookBBLE"
gDir = "ChiranBBLE/SongbookBBLE/"
gSettings = "SongbookSettingsBBLE"

import "ChiranBBLE.SongbookBBLE.Class"; -- Turbine library included so that there's no outside dependencies
import "ChiranBBLE.SongbookBBLE.ToggleWindow";
import "ChiranBBLE.SongbookBBLE.SettingsWindow";
import "ChiranBBLE.SongbookBBLE.SongbookLang";
import "ChiranBBLE.SongbookBBLE";

--import "ChiranBBLE.SongbookBBLE.std.io";


songbookWindow = ChiranBBLE.SongbookBBLE.SongbookWindow();
if (Settings.WindowVisible == "yes") then
	songbookWindow:SetVisible( true );
else
	songbookWindow:SetVisible( false );
end
settingsWindow = ChiranBBLE.SongbookBBLE.SettingsWindow();
settingsWindow:SetVisible( false );

toggleWindow = ChiranBBLE.SongbookBBLE.ToggleWindow();
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

Turbine.Shell.AddCommand( "songbookbble", songbookCommand );
Turbine.Shell.WriteLine("SongbookBBLE v"..Plugins["SongbookBBLE"]:GetVersion().." (0.92 Chiran + 0.01a The Brandy Badgers + Legendary Edition 1.05 (by Almiyan) )");
