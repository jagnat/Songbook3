
ColorTheme = {}

-- Foreground colours for track/player ready states
ColorTheme.colourDefaultHighlighted                        = Turbine.UI.Color( 1, 0.15, 0.95, 0.15 )
ColorTheme.colourReadyHighlighted                          = Turbine.UI.Color( 1, 0.40, 0.8, 0.15 )
ColorTheme.colourSyncedHighlighted                         = Turbine.UI.Color( 1, 1, 1, 0 )
ColorTheme.colourSyncedHighlighted_notSelected             = Turbine.UI.Color( 1, 0.80, 0.80, 0.15 )
ColorTheme.colourReadyMultipleHighlighted                  = Turbine.UI.Color( 1, 0.7, 0.7, 1 )
ColorTheme.colourReadyMultipleHighlighted_synced           = Turbine.UI.Color( 1, 0.7, 0.7, 0.80 )
ColorTheme.colourReadyMultipleHighlighted_synced_notSelected = Turbine.UI.Color( 1, 0.6, 0.6, 0.70 )
ColorTheme.colourDefault                                   = Turbine.UI.Color( 1, 1, 1, 1 )
ColorTheme.colourReady                                     = Turbine.UI.Color( 1, 0.4, 0.4, 0 )
ColorTheme.colourReadyMultiple                             = Turbine.UI.Color( 1, 0.6, 0.6, 0.95 )
ColorTheme.colourReadyMultiple2                            = Turbine.UI.Color( 1, 0.4, 0.9 )
ColorTheme.colourDifferentSong                             = Turbine.UI.Color( 1, 0, 0 )
ColorTheme.colourDifferentSetup                            = Turbine.UI.Color( 1, 0.6, 0 )
ColorTheme.colourWrongInstrument                           = Turbine.UI.Color( 1, 0.2, 0 )
ColorTheme.colourWrongInstrument_synced                    = Turbine.UI.Color( 1, 0.5, 0 )
ColorTheme.colourWrongInstrument_notSelected               = Turbine.UI.Color( 1, 0.3, 0 )
ColorTheme.colourWrongInstrument_notSelected_synced        = Turbine.UI.Color( 1, 0.6, 0 )
ColorTheme.colourWrongInstrumentMultiple                   = Turbine.UI.Color( 1, 0.4, 0.9 )
ColorTheme.colourWrongInstrumentMultiple_notSelected       = Turbine.UI.Color( 1, 0.1, 0.9 )
ColorTheme.colourWrongInstrumentMultiple_synced            = Turbine.UI.Color( 1, 0.6, 1 )
ColorTheme.colourWrongInstrumentMultiple_synced_notSelected = Turbine.UI.Color( 1, 0.5, 1 )
ColorTheme.colourMessageTitle                              = Turbine.UI.Color( 1, 0.8, 0.8, 0 )
ColorTheme.colour_syncMessageTitle                         = Turbine.UI.Color( 1, 0, 1, 1 )
ColorTheme.colour_syncMessageTitle_OnlySynced              = Turbine.UI.Color( 1, 1, 1, 0 )
ColorTheme.colour_syncMessageTitle_Back                    = Turbine.UI.Color( 1, 0.1, 0.2, 0.2 )
ColorTheme.colour_syncMessageTitle_Highlighted             = Turbine.UI.Color( 1, 0, 0.8, 1 )
ColorTheme.colour_syncMessageTitle_Highlighted_OnlySynced  = Turbine.UI.Color( 1, 1, 0.8, 0 )
ColorTheme.colour_syncMessageTitle_MouseDown               = Turbine.UI.Color( 1, 0, 0.8, 0.8 )
ColorTheme.colour_syncMessageTitle_MouseDown_OnlySynced    = Turbine.UI.Color( 1, 0.8, 0.8, 0 )

-- Background colours
ColorTheme.backColourDefault                    = Turbine.UI.Color( 1, 0, 0, 0 )
ColorTheme.backColourHighlight                  = Turbine.UI.Color( 1, 0.1, 0.1, 0.1 )
ColorTheme.backColourHighlight_self             = Turbine.UI.Color( 1, 0.1, 0.15, 0.1 )
ColorTheme.backColourHighlight_wrong            = Turbine.UI.Color( 1, 0.15, 0.15, 0.1 )
ColorTheme.backColourHighlight_Multiple         = Turbine.UI.Color( 1, 0.15, 0.15, 0.2 )
ColorTheme.backColourHighlight_Multiple_synced  = Turbine.UI.Color( 1, 0.15, 0.15, 0.15 )
ColorTheme.backColourWrongInstrument            = Turbine.UI.Color( 1, 0.15, 0.1, 0.1 )
ColorTheme.backColourWrongInstrument_ready      = Turbine.UI.Color( 1, 0.2, 0.1, 0.1 )
ColorTheme.backColour_synced                    = Turbine.UI.Color( 1, 0.1, 0.1, 0 )
ColorTheme.backColour_synced_multiple           = Turbine.UI.Color( 1, 0.1, 0.1, 0.15 )

-- Foreground colour for a track row based on its ready state.
-- readyState: nil = not ready, 0–6+ = various ready/sync/instrument states
-- bSelectedTrack: true if the local player has this track selected
function ColorTheme.GetColourForTrack( readyState, bSelectedTrack )
	if bSelectedTrack then
		if not readyState then
			return ColorTheme.colourDefaultHighlighted
		elseif readyState == 0 then
			return ColorTheme.colourReadyMultipleHighlighted
		elseif readyState == 1 then
			return ColorTheme.colourSyncedHighlighted
		elseif readyState == 2 then
			return ColorTheme.colourReadyMultipleHighlighted_synced
		elseif readyState == 3 then
			return ColorTheme.colourWrongInstrument_synced
		elseif readyState == 4 then
			return ColorTheme.colourWrongInstrumentMultiple
		elseif readyState == 5 then
			return ColorTheme.colourWrongInstrument
		elseif readyState == 6 then
			return ColorTheme.colourWrongInstrumentMultiple_synced
		else
			return ColorTheme.colourReadyHighlighted
		end
	else
		if not readyState then
			return ColorTheme.colourDefault
		elseif readyState == 0 then
			return ColorTheme.colourReadyMultiple
		elseif readyState == 1 then
			return ColorTheme.colourSyncedHighlighted_notSelected
		elseif readyState == 2 then
			return ColorTheme.colourReadyMultipleHighlighted_synced_notSelected
		elseif readyState == 3 then
			return ColorTheme.colourWrongInstrument_notSelected_synced
		elseif readyState == 4 then
			return ColorTheme.colourWrongInstrumentMultiple_notSelected
		elseif readyState == 5 then
			return ColorTheme.colourWrongInstrument_notSelected
		elseif readyState == 6 then
			return ColorTheme.colourWrongInstrumentMultiple_synced_notSelected
		else
			return ColorTheme.colourReady
		end
	end
end

-- Background colour for a track row based on its ready state and player.
function ColorTheme.GetBackColourForTrack( readyState, playerName, readyState8 )
	if readyState8 >= 1 then
		if playerName == "LocalPlayer" then
			return ColorTheme.backColour_synced_multiple
		elseif readyState == 10 and playerName == SyncManager.localPlayerName then
			return ColorTheme.backColour_synced_multiple
		elseif readyState8 > 1 then
			return ColorTheme.backColour_synced_multiple
		else
			return ColorTheme.backColour_synced
		end
	end

	if not readyState then
		return ColorTheme.backColourDefault
	elseif playerName == "LocalPlayer" then
		return ColorTheme.backColourHighlight
	elseif readyState == 10 and playerName == SyncManager.localPlayerName then
		return ColorTheme.backColourHighlight
	else
		return ColorTheme.backColourDefault
	end
end
