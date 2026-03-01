-- InstrumentManager
-- Instrument data and lookup logic for Songbook3.

InstrumentManager = {}

-- Unified instrument registry. Each entry's array index is the instrument ID.
-- name: display name (and primary item name)
-- itemNames: all official in-game item names that map to this instrument
-- aliases: strings that identify this instrument when found in track names
InstrumentManager.registry = {
    { -- 1
        name = "Basic Harp",
        itemNames = {"Basic Harp"},
        aliases = {"Basic Harp"}
    },
    { -- 2
        name = "Misty Mountain Harp",
        itemNames = {"Misty Mountain Harp", "Summer Celebration Mountain Harp"},
        aliases = {"Misty Mountain Harp", "Misty Harp", "MM Harp", "MMH", "Mountain Harp", "Mountains Harp"}
    },
    { -- 3
        name = "Basic Lute",
        itemNames = {"Basic Lute", "Summer Celebration Lute"},
        aliases = {"Basic Lute", "New Lute", "LuteB", "BLute", "B Lute"}
    },
    { -- 4
        name = "Lute of Ages",
        itemNames = {"Lute of Ages"},
        aliases = {"Lute of Ages", "Lute of Age", "Age Lute", "Ages Lute", "LuteA", "LOA", "Lute OA"}
    },
    { -- 5
        name = "Basic Theorbo",
        itemNames = {"Basic Theorbo"},
        aliases = {"Basic Theorbo", "Theorbo", " Theo "}
    },
    { -- 6
        name = "Traveller's Trusty Fiddle",
        itemNames = {"Traveller's Trusty Fiddle"},
        aliases = {"Traveller's Trusty Fiddle", "Traveller's Fiddle", "Travellers Fiddle", "Traveller Fiddle", "Traveler Fiddle", "Trusty Fiddle", "TT Fiddle", "TTF"}
    },
    { -- 7
        name = "Bardic Fiddle",
        itemNames = {"Bardic Fiddle"},
        aliases = {"Bardic Fiddle"}
    },
    { -- 8
        name = "Basic Fiddle",
        itemNames = {"Basic Fiddle"},
        aliases = {"Basic Fiddle", "B Fiddle", "BFiddle"}
    },
    { -- 9
        name = "Lonely Mountain Fiddle",
        itemNames = {"Lonely Mountain Fiddle", "Summer Celebration Fiddle"},
        aliases = {"Lonely Mountain Fiddle", "Lonely Fiddle", "LM Fiddle", "LMFiddle", "LMF", "Mountain Fiddle", "Mountains Fiddle"}
    },
    { -- 10
        name = "Sprightly Fiddle",
        itemNames = {"Sprightly Fiddle"},
        aliases = {"Sprightly Fiddle", "Spright Fiddle"}
    },
    { -- 11
        name = "Student's Fiddle",
        itemNames = {"Student's Fiddle"},
        aliases = {"Student's Fiddle", "Students Fiddle", "Student Fiddle"}
    },
    { -- 12
        name = "Basic Bagpipe",
        itemNames = {"Basic Bagpipe"},
        aliases = {"Basic Bagpipe", "Bagpipe", "Bag pipe"}
    },
    { -- 13
        name = "Basic Bassoon",
        itemNames = {"Basic Bassoon"},
        aliases = {"Basic Bassoon"}
    },
    { -- 14
        name = "Brusque Bassoon",
        itemNames = {"Brusque Bassoon"},
        aliases = {"Brusque Bassoon", "Brusk Bassoon"}
    },
    { -- 15
        name = "Lonely Mountain Bassoon",
        itemNames = {"Lonely Mountain Bassoon"},
        aliases = {"Lonely Mountain Bassoon", "Lonely Bassoon", "LM Bassoon", "Mountain Bassoon", "Mountains Bassoon"}
    },
    { -- 16
        name = "Basic Clarinet",
        itemNames = {"Basic Clarinet"},
        aliases = {"Basic Clarinet", "Clarinet"}
    },
    { -- 17
        name = "Basic Flute",
        itemNames = {"Basic Flute"},
        aliases = {"Basic Flute", "Flute"}
    },
    { -- 18
        name = "Basic Horn",
        itemNames = {"Basic Horn"},
        aliases = {"Basic Horn", "Horn"}
    },
    { -- 19
        name = "Basic Pibgorn",
        itemNames = {"Basic Pibgorn"},
        aliases = {"Basic Pibgorn", "Pibgorn"}
    },
    { -- 20
        name = "Basic Cowbell",
        itemNames = {"Basic Cowbell", "Summer Celebration Cowbell"},
        aliases = {"Basic Cowbell"}
    },
    { -- 21
        name = "Moor Cowbell",
        itemNames = {"Moor Cowbell"},
        aliases = {"Moor Cowbell", "More Cowbell"}
    },
    { -- 22
        name = "Basic Drum",
        itemNames = {"Basic Drum"},
        aliases = {"Basic Drum", "Drum"}
    },
    { -- 23
        name = "Jaunty Hand-knells",
        itemNames = {"Jaunty Hand-knells"},
        aliases = {"Jaunty Hand-knells", "Hand-knells", "Jaunty", "Glockenspiel"}
    }
}

InstrumentManager.specialInstruments = {}
InstrumentManager.specialInstruments["satakieli"] = 6

function InstrumentManager.GetName(index)
    local entry = InstrumentManager.registry[index]
    if entry then return entry.name end
    return nil
end

function InstrumentManager.FindInstrumentInTrack(trackName)
    local Track_Instrument = {}
    local Track_Instrument_Index = 0
    local Track_Instrument_Name = ""

    local Track_Name_lowercase = string.lower(trackName)
    local found_Instruments = {}
    local found_Instruments_startIndex = {}
    local found_Instruments_count = 0

    if trackName == nil then return end

    for k, entry in pairs(InstrumentManager.registry) do
        for _, alias in pairs(entry.aliases) do
            local startIndex = string.find(Track_Name_lowercase, string.lower(alias))
            if startIndex then
                found_Instruments_count = found_Instruments_count + 1
                found_Instruments[found_Instruments_count] = k
                found_Instruments_startIndex[found_Instruments_count] = startIndex
                break
            end
        end
    end

    if found_Instruments_count > 1 then
        local startIndex = -1
        for i = 1, found_Instruments_count do
            if found_Instruments_startIndex[i] > startIndex then
                startIndex = found_Instruments_startIndex[i]
                Track_Instrument_Index = found_Instruments[i]
                Track_Instrument_Name = InstrumentManager.registry[Track_Instrument_Index].name
            end
        end
    elseif found_Instruments_count == 1 then
        Track_Instrument_Index = found_Instruments[1]
        Track_Instrument_Name = InstrumentManager.registry[Track_Instrument_Index].name
    end

    if Track_Instrument_Index == 0 then
        if string.find(Track_Name_lowercase, "harp") then
            Track_Instrument_Index = 1
            Track_Instrument_Name = "Basic Harp"
        elseif string.find(Track_Name_lowercase, "lute") then
            Track_Instrument_Index = 103
            Track_Instrument_Name = "Basic Lute"
        elseif string.find(Track_Name_lowercase, "fiddle") or
               string.find(Track_Name_lowercase, "fiddl")
            then
            Track_Instrument_Index = 108
            Track_Instrument_Name = "Basic Fiddle"
        elseif string.find(Track_Name_lowercase, "bassoon") or
               string.find(Track_Name_lowercase, "basoon") or
               string.find(Track_Name_lowercase, "basson")
            then
            Track_Instrument_Index = 13
            Track_Instrument_Name = "Basic Bassoon"
        end
    end

    Track_Instrument[0] = Track_Instrument_Index
    Track_Instrument[1] = Track_Instrument_Name

    return Track_Instrument
end

function InstrumentManager.GetEquippedInstrument()
    local player = Turbine.Gameplay.LocalPlayer:GetInstance()
    if not player then return nil, nil end
    local equipment = player:GetEquipment()
    if not equipment then return nil, nil end
    local instrument = equipment:GetItem(Turbine.Gameplay.Equipment.Instrument)
    if not instrument then return nil, nil end
    local name = instrument:GetName()
    if not name then return nil, nil end

    local equippedInstrument_Index = 0
    for k, entry in pairs(InstrumentManager.registry) do
        for _, itemName in pairs(entry.itemNames) do
            if itemName == name then
                equippedInstrument_Index = k
                break
            end
        end
    end

    local nameLower = string.lower(name)
    if equippedInstrument_Index == 0 then
        if string.find(nameLower, "harp") then
            equippedInstrument_Index = 1
        elseif string.find(nameLower, "flute") then
            equippedInstrument_Index = 17
        elseif string.find(nameLower, "lute") then
            equippedInstrument_Index = 3
        elseif string.find(nameLower, "theorbo") then
            equippedInstrument_Index = 5
        elseif string.find(nameLower, "fiddle") then
            equippedInstrument_Index = 8
        elseif string.find(nameLower, "bagpipe") then
            equippedInstrument_Index = 12
        elseif string.find(nameLower, "bassoon") then
            equippedInstrument_Index = 13
        elseif string.find(nameLower, "clarinet") then
            equippedInstrument_Index = 16
        elseif string.find(nameLower, "horn") then
            equippedInstrument_Index = 18
        elseif string.find(nameLower, "pibgorn") then
            equippedInstrument_Index = 19
        elseif string.find(nameLower, "cowbell") then
            equippedInstrument_Index = 21
        elseif string.find(nameLower, "drum") then
            equippedInstrument_Index = 22
        end
    end

    if equippedInstrument_Index == 0 then
        return nil, nil
    end
    return equippedInstrument_Index, name
end

function InstrumentManager.GetInstrumentIndex(itemName)
    if InstrumentManager.specialInstruments and InstrumentManager.specialInstruments[itemName] then
        return InstrumentManager.specialInstruments[itemName]
    end
    for k,v in pairs(aInstrumentsLoc) do
        if itemName:find(v) then return k end
    end
    return nil
end

function InstrumentManager.CheckTracksForInstrument(sTrack, iInstrument, aInstruments)
    if not iInstrument or iInstrument > #aInstruments then return nil end
    local sName = aInstruments[iInstrument]
    for k,v in pairs(aInstruments) do
        if sTrack:find(v) then
            local bInstrumentOk = not not string.find(sTrack, "[^%a]" .. sName:lower())
            return k, bInstrumentOk
        end
    end
    return nil
end

function InstrumentManager.CompareInstrument(equippedInstrument_Index, Track_Instrument_Index)
    local CorrectInstrument = 0

    if equippedInstrument_Index ~= 0 then
        if Track_Instrument_Index ~= 0 then
            if Track_Instrument_Index == equippedInstrument_Index then
                CorrectInstrument = 1
            elseif Track_Instrument_Index == 103 then
                if equippedInstrument_Index == 3 or equippedInstrument_Index == 4 then
                    CorrectInstrument = 1
                end
            elseif Track_Instrument_Index == 108 then
                if equippedInstrument_Index == 8 or equippedInstrument_Index == 9 then
                    CorrectInstrument = 1
                end
            end
        else
            CorrectInstrument = 1
        end
    else
        CorrectInstrument = 0
    end

    return CorrectInstrument
end
