
-- SyncManager
-- Sync state, player tracking, and chat message parsing for Songbook3.

SyncManager = {}

-- Sync state (was global variables in SongbookWindow.lua)
SyncManager.syncedTrackName = ""
SyncManager.otherPlayerSynced = false
SyncManager.multipleSongsMatch = false
SyncManager.missingMatchedSong = false
SyncManager.otherPlayerSong = { filepath = "", filename = "", index = 1, indexListBox = 1 }
SyncManager.isRaid = false
SyncManager.userChatBlocked = false
SyncManager.userChatName = ""
SyncManager.chatChannel = "/f"
SyncManager.correctInstrument = false
SyncManager.userChatNumber = 0
SyncManager.localPlayerSynced = false
SyncManager.syncedSongIndex = -1
SyncManager.syncedTrack = -1
SyncManager.syncStartReady = false

-- Player state (was self.* in SongbookWindow constructor)
SyncManager.players = {}
SyncManager.playerCount = 0
SyncManager.currentSongReady = {}
SyncManager.readyTracks = ""
SyncManager.playerSongMatches = {}
SyncManager.chiefMode = true
SyncManager.useRaidChat = false
SyncManager.useFellowshipChat = false
SyncManager.localPlayerName = nil
SyncManager.initialized = false

-- Callbacks (set by SongbookWindow in its constructor)
SyncManager.onPlayerStateChanged = nil
SyncManager.onPlayerJoined = nil
SyncManager.onPlayerLeft = nil
SyncManager.onSongStarted = nil
SyncManager.onSyncMessage = nil
SyncManager.onChatChannelChanged = nil
SyncManager.onChiefModeChanged = nil
SyncManager.onSongStateCleared = nil
SyncManager.onMaxPartCountChanged = nil

local handleChat

function SyncManager.Init()
    local player = Turbine.Gameplay.LocalPlayer:GetInstance()
    if player then
        SyncManager.localPlayerName = player:GetName()
    end
    SyncManager.chiefMode = Settings.ChiefMode
    SyncManager.useRaidChat = Settings.UseRaidChat
    SyncManager.useFellowshipChat = Settings.UseFellowshipChat
    SyncManager.userChatName = string.upper(Settings.UserChatName)
    SyncManager.userChatNumber = CharSettings.UserChatNumber or 0
    AddCallback(Turbine.Chat, "Received", handleChat)
    SyncManager.initialized = true
end

function SyncManager.AddPlayer(name)
    if SyncManager.players[name] then return end
    SyncManager.currentSongReady[name] = false
    SyncManager.players[name] = 0
    SyncManager.playerSongMatches[name] = 0
    if SyncManager.onPlayerJoined then SyncManager.onPlayerJoined(name) end
end

function SyncManager.RemovePlayer(name)
    if not SyncManager.players[name] then return end
    SyncManager.currentSongReady[name] = nil
    SyncManager.players[name] = nil
    SyncManager.playerSongMatches[name] = nil
    if SyncManager.onPlayerLeft then SyncManager.onPlayerLeft(name) end
end

function SyncManager.PlayerJoined(msg)
    local temp, sPlayerName
    temp, temp, sPlayerName = string.find(msg, "(%a+)" .. Strings["chat_playerJoin"])
    if sPlayerName then SyncManager.AddPlayer(sPlayerName) end
end

function SyncManager.PlayerLeft(msg)
    local temp, sPlayerName
    temp, temp, sPlayerName = string.find(msg, "(%a+)" .. Strings["chat_playerLeave"])
    if sPlayerName then SyncManager.RemovePlayer(sPlayerName) end
end

function SyncManager.ClearPlayerStates()
    for k in pairs(SyncManager.players) do
        SyncManager.players[k] = 0
        SyncManager.playerSongMatches[k] = 0
    end
end

function SyncManager.ClearPlayerReadyStates()
    for k in pairs(SyncManager.players) do
        SyncManager.currentSongReady[k] = false
    end
end

function SyncManager.GetPlayerNames()
    local names = {}
    for k in pairs(SyncManager.players) do
        names[#names + 1] = k
    end
    return names
end

function SyncManager.RefreshPlayers(localPlayerName)
    local player = Turbine.Gameplay.LocalPlayer:GetInstance()
    if player == nil then return end

    if localPlayerName then
        SyncManager.localPlayerName = localPlayerName
    elseif SyncManager.localPlayerName == nil then
        SyncManager.localPlayerName = player:GetName()
    end

    local party = player:GetParty()
    if party == nil or party:GetMemberCount() <= 0 then
        if SyncManager.chiefMode then
            SyncManager.players = {}
            SyncManager.currentSongReady = {}
        end
        SyncManager.players[SyncManager.localPlayerName] = 0
        SyncManager.playerSongMatches[SyncManager.localPlayerName] = 0
        if SyncManager.onPlayerJoined then SyncManager.onPlayerJoined(SyncManager.localPlayerName) end
        return
    end

    if SyncManager.chiefMode then
        SyncManager.players = {}
        SyncManager.playerSongMatches = {}
        SyncManager.currentSongReady = {}
    else
        -- not chiefMode: re-list existing players via callbacks
        for k in pairs(SyncManager.players) do
            if SyncManager.onPlayerJoined then SyncManager.onPlayerJoined(k) end
        end
    end

    for iPlayer = 1, party:GetMemberCount() do
        local member = party:GetMember(iPlayer)
        local sName = member:GetName()
        if SyncManager.players[sName] == nil then
            SyncManager.AddPlayer(sName)
        end
    end
end

function SyncManager.SetChiefMode(state)
    SyncManager.chiefMode = (state == true)
    Settings.ChiefMode = SyncManager.chiefMode
    if SyncManager.onChiefModeChanged then SyncManager.onChiefModeChanged(SyncManager.chiefMode) end
end

function SyncManager.SetUseRaidChat(state)
    SyncManager.useRaidChat = state
    if state then SyncManager.useFellowshipChat = false end
    Settings.UseRaidChat = SyncManager.useRaidChat
    Settings.UseFellowshipChat = SyncManager.useFellowshipChat
end

function SyncManager.SetUseFellowshipChat(state)
    SyncManager.useFellowshipChat = state
    if state then SyncManager.useRaidChat = false end
    Settings.UseRaidChat = SyncManager.useRaidChat
    Settings.UseFellowshipChat = SyncManager.useFellowshipChat
end

function SyncManager.SetUserChatName(text)
    SyncManager.userChatName = string.upper(text)
    Settings.UserChatName = SyncManager.userChatName
end

function SyncManager.GetTrackReadyState(sSongIndex, sTrackIndex, indicator)
    local ReadyState = {}
    ReadyState[0] = nil
    ReadyState[1] = nil
    ReadyState[2] = nil
    ReadyState[3] = nil
    ReadyState[4] = nil
    ReadyState[5] = nil
    ReadyState[6] = nil
    ReadyState[7] = nil
    ReadyState[8] = nil
    ReadyState[9] = nil
    local readyIndicator = 1
    if indicator then readyIndicator = indicator end

    local SyncedPlayersCounter = 0
    local SyncedPlayersNames = {}
    local ReadyPlayersCounter = 0
    local ReadyPlayersNames = {}
    local ReadyPlayersEquippedInstrument_Index = {}
    local WrongPlayersCounter = 0
    local WrongPlayersNames = {}
    local WrongPlayersEquippedInstrument_Index = {}

    local SyncedPlayer = 0

    if SyncManager.players ~= nil then
        for k, v in pairs(SyncManager.players) do

            v = string.gsub(v, "%s+", "")

            local sPlayerName, SyncStatus, CorrectSongAndTrack, SongIndex, TrackIndex, equippedInstrument_Index, CorrectInstrument = string.match(v, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|')

            local Track_Name = SongDB.Songs[sSongIndex].Tracks[sTrackIndex].Name

            if string.gsub(string.sub(Track_Name, 1, 63), "%s+", "") == v or
               string.gsub(string.sub(Track_Name, 1, -2), "%s+", "") == v
            then
                SyncedPlayersNames[SyncedPlayersCounter] = k
                SyncedPlayersCounter = SyncedPlayersCounter + 1
            end

            local SongIndex_Synced = 0

            if SyncManager.playerSongMatches[k] ~= nil then
            if SyncManager.playerSongMatches[k] ~= 0 then
            if SyncManager.playerSongMatches[k][0] ~= 0 then
                for i = 1, SyncManager.playerSongMatches[k][0] do
                    if sSongIndex == SyncManager.playerSongMatches[k][i] then
                        SongIndex_Synced = 1
                    end
                end
            end
            end
            end

            if SongIndex_Synced == 1 and sTrackIndex == tonumber(TrackIndex) and
               tonumber(CorrectSongAndTrack) == 1 and tonumber(SyncStatus) == 1 then

                if sPlayerName == SyncManager.localPlayerName then
                    ReadyState[1] = "LocalPlayer"
                end

                if tonumber(CorrectInstrument) == 1 then
                    ReadyPlayersNames[ReadyPlayersCounter] = k
                    ReadyPlayersEquippedInstrument_Index[ReadyPlayersCounter] = equippedInstrument_Index
                    ReadyPlayersCounter = ReadyPlayersCounter + 1
                else
                    WrongPlayersNames[WrongPlayersCounter] = k
                    WrongPlayersEquippedInstrument_Index[WrongPlayersCounter] = equippedInstrument_Index
                    WrongPlayersCounter = WrongPlayersCounter + 1
                end
            else
                if sSongIndex == SyncManager.syncedSongIndex and sTrackIndex == SyncManager.syncedTrack and k == SyncManager.localPlayerName then

                    local equippedIndex, name = InstrumentManager.GetEquippedInstrument()
                    local Track_Instrument = InstrumentManager.FindInstrumentInTrack(Track_Name)
                    local Track_Instrument_Index = Track_Instrument[0]
                    local CorrectInstr = InstrumentManager.CompareInstrument(equippedIndex, Track_Instrument_Index)
                    if CorrectInstr == 0 then
                        SyncManager.correctInstrument = false
                    else
                        SyncManager.correctInstrument = true
                    end

                    if CorrectInstr == 1 then
                        SyncedPlayer = 1
                    else
                        SyncedPlayer = 2
                    end
                end
            end
        end
    end

    if ReadyPlayersCounter == 1 and SyncedPlayer == 0 and WrongPlayersCounter == 0 then
        ReadyState[0] = 10
        SyncManager.currentSongReady[ReadyPlayersNames[0]] = readyIndicator
    elseif ReadyPlayersCounter > 1 and SyncedPlayer == 0 and WrongPlayersCounter == 0 then
        ReadyState[0] = 0
        for i = 0, ReadyPlayersCounter - 1, 1 do
            SyncManager.currentSongReady[ReadyPlayersNames[i]] = 2
        end
    elseif WrongPlayersCounter == 1 and ReadyPlayersCounter == 0 and SyncedPlayer == 0 then
        ReadyState[0] = 5
    elseif WrongPlayersCounter >= 1 and ReadyPlayersCounter >= 0 and SyncedPlayer == 0 then
        ReadyState[0] = 4
    elseif SyncedPlayer == 1 and ReadyPlayersCounter == 0 and WrongPlayersCounter == 0 then
        ReadyState[0] = 1
    elseif SyncedPlayer == 1 and ReadyPlayersCounter >= 1 and WrongPlayersCounter == 0 then
        ReadyState[0] = 2
    elseif SyncedPlayer == 1 and ReadyPlayersCounter >= 0 and WrongPlayersCounter >= 1 then
        ReadyState[0] = 6
    elseif SyncedPlayer == 2 and ReadyPlayersCounter >= 1 and WrongPlayersCounter == 0 then
        ReadyState[0] = 6
    elseif SyncedPlayer == 2 and ReadyPlayersCounter >= 0 and WrongPlayersCounter >= 1 then
        ReadyState[0] = 6
    elseif SyncedPlayer == 2 and ReadyPlayersCounter == 0 and WrongPlayersCounter == 0 then
        ReadyState[0] = 3
    end

    ReadyState[2] = ReadyPlayersNames
    ReadyState[3] = ReadyPlayersEquippedInstrument_Index
    ReadyState[4] = ReadyPlayersCounter
    ReadyState[5] = WrongPlayersNames
    ReadyState[6] = WrongPlayersEquippedInstrument_Index
    ReadyState[7] = WrongPlayersCounter

    ReadyState[8] = SyncedPlayersCounter
    ReadyState[9] = SyncedPlayersNames

    return ReadyState
end

function SyncManager.GetSongReadyState(sSongIndex)
    local ReadyState = {}
    ReadyState[0] = nil
    ReadyState[1] = nil

    local ReadyPlayersCounter = 0
    local ReadyPlayersNames = {}

    if SyncManager.players ~= nil then
        for k, v in pairs(SyncManager.players) do

            v = string.gsub(v, "%s+", "")

            local sPlayerName, SyncStatus, CorrectSongAndTrack, SongIndex, TrackIndex, equippedInstrument_Index, CorrectInstrument = string.match(v, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|')

            local SongIndex_Synced = 0

            if SyncManager.playerSongMatches[k] ~= nil then
            if SyncManager.playerSongMatches[k] ~= 0 then
            if SyncManager.playerSongMatches[k][0] ~= 0 then
                for i = 1, SyncManager.playerSongMatches[k][0] do
                    if sSongIndex == SyncManager.playerSongMatches[k][i] then
                        SongIndex_Synced = 1
                    end
                end
            end
            end
            end

            if SongIndex_Synced == 1 and tonumber(SyncStatus) == 1 then

                if sPlayerName == SyncManager.localPlayerName then
                    ReadyState[1] = "LocalPlayer"
                end

                ReadyPlayersNames[ReadyPlayersCounter] = k
                ReadyPlayersCounter = ReadyPlayersCounter + 1
            end
        end
    end

    if ReadyPlayersCounter == 1 then
        ReadyState[0] = 10
    elseif ReadyPlayersCounter > 1 then
        ReadyState[0] = 0
    end

    return ReadyState
end

function SyncManager.UpdateReadyTracks(trackCount, selectedTrackIndexFn)
    SyncManager.readyTracks = ""
    for iList = 1, trackCount do
        local i = selectedTrackIndexFn(iList)
        local readyState = SyncManager.GetTrackReadyState(SongLibrary.selectedSongIndex, i)
        if readyState[4] > 0 then
            SyncManager.readyTracks = SyncManager.readyTracks .. string.char(0x40 + i)
        end
    end
end

function SyncManager.ClearSongState()
    SyncManager.syncedSongIndex = -1
    SyncManager.syncedTrack = -1
    SyncManager.readyTracks = ""
    SyncManager.ClearPlayerStates()
    if SyncManager.onSongStateCleared then SyncManager.onSongStateCleared() end
end

function SyncManager.Shutdown()
    RemoveCallback(Turbine.Chat, "Received", handleChat)
end

handleChat = function(sender, args)
    local sMessage = args.Message
    if sMessage == nil or not SyncManager.initialized then return end

    if args.ChatType == Turbine.ChatType.Error then
        if string.find(sMessage, "You are not in a Raid.") ~= nil then
            if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "You are not in a Raid.") end
            SyncManager.isRaid = false
        end
        return
    end

    if args.ChatType == Turbine.ChatType.UserChat1 or args.ChatType == Turbine.ChatType.UserChat2 or
       args.ChatType == Turbine.ChatType.UserChat3 or args.ChatType == Turbine.ChatType.UserChat4 or
       args.ChatType == Turbine.ChatType.UserChat5 or args.ChatType == Turbine.ChatType.UserChat6 or
       args.ChatType == Turbine.ChatType.UserChat7 or args.ChatType == Turbine.ChatType.UserChat8 or
       args.ChatType == Turbine.ChatType.Raid      or args.ChatType == Turbine.ChatType.Fellowship
    then

        if string.find(sMessage, "raid chat is now available.") ~= nil then
            SyncManager.isRaid = true
            SyncManager.chatChannel = "/ra"
            if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
            return
        end

        if string.find(sMessage, "You left room '" .. SyncManager.userChatName .. "'") ~= nil then
            SyncManager.userChatNumber = 0
            CharSettings.UserChatNumber = 0
            if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
            return
        end

        if string.match(sMessage, "uc(%d+): '" .. SyncManager.userChatName .. "'") ~= nil then
            SyncManager.userChatNumber = string.match(sMessage, "uc(%d+): '" .. SyncManager.userChatName .. "'")
            CharSettings.UserChatNumber = SyncManager.userChatNumber
            if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
            return
        end

        if string.find(sMessage, "@SBL") then

            local sPlayerName, Filename, TrackName, SyncStatus, CorrectSongAndTrack, NumberOfParts, SongIndexListBox, SongIndex_OtherPlayer, TrackIndex, neededInstrument, equippedInstrument_Index, CorrectInstrument = string.match(sMessage, '|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|(.+)|')

            local PlayerIsInParty_Flag = 0

            if SyncManager.players ~= nil then
                for k, v in pairs(SyncManager.players) do
                    if k == sPlayerName then
                        PlayerIsInParty_Flag = 1
                        break
                    end
                end
            end

            if PlayerIsInParty_Flag == 0 then return end

            local SongIndex = SongLibrary.FindSongByMatch(Filename, TrackName, NumberOfParts)

            if sPlayerName ~= nil then

                SyncManager.otherPlayerSynced = false
                if sPlayerName ~= SyncManager.localPlayerName then
                    if SyncManager.onSyncMessage then SyncManager.onSyncMessage(SongIndex, sPlayerName, TrackName) end
                end

                if not SyncManager.players[sPlayerName] then
                    SyncManager.playerCount = SyncManager.playerCount + 1
                    if SyncManager.onPlayerJoined then SyncManager.onPlayerJoined(sPlayerName) end
                    if SyncManager.onMaxPartCountChanged then SyncManager.onMaxPartCountChanged() end
                end

                SyncManager.players[sPlayerName] = "|" .. sPlayerName .. "|" .. SyncStatus .. "|" .. CorrectSongAndTrack .. "|" .. SongIndex[0] .. "|" .. TrackIndex .. "|" .. equippedInstrument_Index .. "|" .. CorrectInstrument .. "|"

                SyncManager.playerSongMatches[sPlayerName] = SongIndex

                if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
            end
        end

        return
    end

    if args.ChatType ~= Turbine.ChatType.Standard then
        return
    end

    if string.find(sMessage, "You have joined a Fellowship.") ~= nil then
        local player = Turbine.Gameplay.LocalPlayer:GetInstance()
        local Party = player:GetParty()
        local PartyMemberCount = 0
        if Party ~= nil then PartyMemberCount = Party:GetMemberCount() end

        if PartyMemberCount > 1 then
            for i = 1, PartyMemberCount do
                local PartyMember = Party:GetMember(i)
                local MemberName = PartyMember:GetName()
                if SyncManager.players[MemberName] == nil then SyncManager.AddPlayer(MemberName) end
            end
        end

        SyncManager.chatChannel = "/f"
        SyncManager.isRaid = false
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, "You have joined a Raid.") ~= nil then
        local player = Turbine.Gameplay.LocalPlayer:GetInstance()
        local Party = player:GetParty()
        local PartyMemberCount = 0
        if Party ~= nil then PartyMemberCount = Party:GetMemberCount() end

        if PartyMemberCount > 1 then
            for i = 1, PartyMemberCount do
                local PartyMember = Party:GetMember(i)
                local MemberName = PartyMember:GetName()
                if SyncManager.players[MemberName] == nil then SyncManager.AddPlayer(MemberName) end
            end
        end

        SyncManager.isRaid = true
        SyncManager.chatChannel = "/ra"
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, "You joined room '" .. SyncManager.userChatName .. "'") ~= nil then
        SyncManager.userChatNumber = string.match(sMessage, 'UserChat(%d+)')
        CharSettings.UserChatNumber = SyncManager.userChatNumber
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, "You are already in room '" .. SyncManager.userChatName .. "'") ~= nil then
        if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "You are already in room '" .. SyncManager.userChatName .. "'. Use recover button to find it.") end
        return
    end

    if string.find(sMessage, "You are not in room '" .. SyncManager.userChatName .. "'") ~= nil then
        SyncManager.userChatNumber = 0
        CharSettings.UserChatNumber = 0
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, "You are already in 8 rooms, which is the maximum allowed") ~= nil then
        if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "You are already in 8 rooms, which is the maximum allowed") end
        return
    end

    if string.find(sMessage, "You haven't played this character for long enough to use this chat channel.") ~= nil then
        SyncManager.userChatNumber = 0
        CharSettings.UserChatNumber = 0
        SyncManager.userChatBlocked = true
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, "Your Raid has been disbanded.") ~= nil then
        if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "Your Raid has been disbanded.") end
        SyncManager.chatChannel = "/f"
        SyncManager.isRaid = false
        return
    end

    if string.find(sMessage, "dismiss") ~= nil then
        if string.find(sMessage, "You have been dismissed from your") ~= nil then
            if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "You have been dismissed.") end
            SyncManager.chatChannel = "/f"
            SyncManager.isRaid = false
            return
        end

        if string.find(sMessage, "You dismiss") ~= nil then
            local temp, sPlayerName
            temp, temp, sPlayerName = string.find(sMessage, "You dismiss (%a+)")
            if sPlayerName then SyncManager.RemovePlayer(sPlayerName) end

            if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end

            local PartyMemberCount = 0
            if SyncManager.players ~= nil then
                for k, v in pairs(SyncManager.players) do
                    PartyMemberCount = PartyMemberCount + 1
                end
            end

            if PartyMemberCount == 1 then
                if SyncManager.onChatChannelChanged then SyncManager.onChatChannelChanged(SyncManager.chatChannel, "You dismiss party.") end
                SyncManager.chatChannel = "/f"
                SyncManager.isRaid = false
                return
            end

            return
        end

        local temp, sPlayerName
        temp, temp, sPlayerName = string.find(sMessage, "(%a+) has been dismissed from your")
        if sPlayerName then SyncManager.RemovePlayer(sPlayerName) end
        if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        return
    end

    if string.find(sMessage, Strings["chat_playBegin"]) ~= nil or string.find(sMessage, Strings["chat_playBeginSelf"]) ~= nil then

        local temp, temp, TrackName = string.find(sMessage, Strings["chat_playBeginSelf"] .. "\"(.+).\".*")
        if TrackName then
            SyncManager.syncedTrackName = TrackName
        end
        SyncManager.SongStarted()
        return
    end

    if string.find(sMessage, Strings["chat_playerJoin"]) ~= nil then
        SyncManager.PlayerJoined(sMessage)
        return
    end
    if string.find(sMessage, Strings["chat_playerLeave"]) ~= nil then
        SyncManager.PlayerLeft(sMessage)
        return
    end

    local temp, sPlayerName, sTrackName
    temp, temp, sPlayerName, sTrackName = string.find(sMessage, Strings["chat_playReadyMsg"])
    if not sPlayerName or not sTrackName then
        sPlayerName = SyncManager.localPlayerName
        temp, temp, sTrackName = string.find(sMessage, Strings["chat_playSelfReadyMsg"])
    end

    if sPlayerName and sTrackName and SyncManager.players then
        if sPlayerName == SyncManager.localPlayerName and SyncManager.localPlayerName then

            SyncManager.syncedTrackName = sTrackName

            SyncManager.players[SyncManager.localPlayerName] = sTrackName

            SyncManager.localPlayerSynced = true
            if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
        else
            if SyncManager.players[sPlayerName] ~= nil then

                SyncManager.players[sPlayerName] = sTrackName

                local SongIndex = SongLibrary.FindSongByTrackName(sTrackName)
                SyncManager.otherPlayerSynced = true
                if SyncManager.onSyncMessage then SyncManager.onSyncMessage(SongIndex, sPlayerName, sTrackName) end

                if SyncManager.onPlayerStateChanged then SyncManager.onPlayerStateChanged() end
            end
        end
    end
end

function SyncManager.SongStarted()
    SyncManager.ClearSongState()
    SyncManager.syncStartReady = false
    if SyncManager.onSongStarted then SyncManager.onSongStarted(SyncManager.syncedTrackName) end
end
