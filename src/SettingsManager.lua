
-- SettingsManager
-- Centralized settings load/save for Songbook3.
-- Defines schema with proper types (booleans, numbers, strings).
-- Handles coercion of legacy string-based values on load.

SettingsManager = {}

local DATA_KEY = "Songbook3Settings"

SettingsManager.AccountDefaults = {
	WindowPosition = { Left = 300, Top = 20, Width = 700, Height = 750 },
	WindowVisible = false,
	WindowOpacity = 0.9,
	DirHeight = 100,
	TracksHeight = 150,
	TracksVisible = true,
	ToggleVisible = true,
	ToggleLeft = 10,
	ToggleTop = 10,
	ToggleOpacity = 1,
	SearchVisible = true,
	DescriptionVisible = false,
	DescriptionFirst = false,
	UserChatName = "",
	PlayersSyncInfoWindowPosition = { Left = 350, Top = 100, Width = 400, Height = 300 },
	Timer_WindowPosition = { Left = 50, Top = 1 },
	TimerWindowVisible = true,
	TimerState = true,
	TimerCountdown = true,
	FiltersState = false,
	ChiefMode = true,
	ReadyColState = true,
	ReadyColHighlight = true,
	UseRaidChat = false,
	UseFellowshipChat = false,
	AutoPickOnSongChange = true,
	AutoPickOnInsChange = true,
	hideMatchedSongsPopup = false,
	HelpWindowDisable = false,
	Commands = {},
	DefaultCommand = "1",
}

SettingsManager.CharacterDefaults = {
	UserChatNumber = 0,
	InstrumentSlots_Rows = 1,
	InstrSlots = {},
}

-- Convert a string value to match the type of the corresponding default.
-- Handles "yes"/"no" and "true"/"false" → boolean, numeric strings → number.
local function CoerceValue(value, default)
	if value == nil then
		return nil
	end
	local defaultType = type(default)
	local valueType = type(value)

	if valueType == defaultType then
		return value
	end

	if defaultType == "boolean" and valueType == "string" then
		local lower = value:lower()
		if lower == "true" or lower == "yes" then return true end
		if lower == "false" or lower == "no" then return false end
	end

	if defaultType == "number" and valueType == "string" then
		-- Handle European decimal format (comma instead of period)
		local normalized = value:gsub(",", ".")
		local num = tonumber(normalized)
		if num then return num end
	end

	return value
end

-- Recursively apply defaults: fill in missing keys from defaults,
-- and coerce existing string values to match the default's type.
local function ApplyDefaults(data, defaults)
	if type(data) ~= "table" then
		return defaults
	end
	for key, defaultValue in pairs(defaults) do
		if data[key] == nil then
			-- Missing key: use default (deep copy tables)
			if type(defaultValue) == "table" then
				data[key] = ApplyDefaults({}, defaultValue)
			else
				data[key] = defaultValue
			end
		elseif type(defaultValue) == "table" and type(data[key]) == "table" then
			-- Both are tables: recurse
			ApplyDefaults(data[key], defaultValue)
		else
			-- Existing value: coerce type if needed
			data[key] = CoerceValue(data[key], defaultValue)
		end
	end
	return data
end

-- Fix up InstrSlots after loading: coerce types inside the dynamic structure.
-- InstrSlots has a dynamic schema (rows × slots) so it can't use the normal
-- defaults-based coercion.
local function FixupInstrSlots(charSettings)
	if type(charSettings.InstrSlots) ~= "table" then return end

	charSettings.InstrumentSlots_Rows = tonumber(charSettings.InstrumentSlots_Rows) or 1

	for j = 1, charSettings.InstrumentSlots_Rows do
		local row = charSettings.InstrSlots[j]
		if type(row) == "table" then
			-- Coerce visible: "yes"/"true" → true
			if type(row.visible) == "string" then
				local lower = row.visible:lower()
				row.visible = (lower == "yes" or lower == "true")
			end
			-- Coerce number
			row.number = tonumber(row.number) or 11
			-- Coerce slot qsType values
			for i = 1, row.number do
				local slot = row[tostring(i)]
				if type(slot) == "table" and slot.qsType then
					slot.qsType = tonumber(slot.qsType) or slot.qsType
				end
			end
		end
	end
end

-- Initialize default InstrSlots structure if empty.
local function InitInstrSlots(charSettings)
	if next(charSettings.InstrSlots) ~= nil then return end

	for j = 1, charSettings.InstrumentSlots_Rows do
		charSettings.InstrSlots[j] = {
			visible = true,
			number = 11,
		}
		for i = 1, 11 do
			charSettings.InstrSlots[j][tostring(i)] = { qsType = "", qsData = "" }
		end
	end
end

-- Initialize default Commands if empty.
local function InitCommands(settings)
	if next(settings.Commands) ~= nil then return end

	settings.Commands["1"] = { Title = Strings["cmd_demo1_title"], Command = Strings["cmd_demo1_cmd"] }
	settings.Commands["2"] = { Title = Strings["cmd_demo2_title"], Command = Strings["cmd_demo2_cmd"] }
	settings.Commands["3"] = { Title = Strings["cmd_demo3_title"], Command = Strings["cmd_demo3_cmd"] }
end

function SettingsManager.Load()
	-- Load song database
	-- SongDB is created externally by songbook filler applications (read-only)
	SongDB = Turbine.PluginData.Load(Turbine.DataScope.Account, "SongbookData") or SongDB or {}
	if not SongDB.Songs then
		SongDB = { Directories = {}, Songs = {} }
	end
	table.sort(SongDB, sortby_Name)

	-- Load account settings
	local loadedSettings = Turbine.PluginData.Load(Turbine.DataScope.Account, DATA_KEY)
	if loadedSettings and loadedSettings.Timer_WindowPosition then
		Settings = ApplyDefaults(loadedSettings, SettingsManager.AccountDefaults)
	else
		Settings = ApplyDefaults({}, SettingsManager.AccountDefaults)
	end
	InitCommands(Settings)

	-- Load character settings
	local loadedCharSettings = Turbine.PluginData.Load(Turbine.DataScope.Character, DATA_KEY)
	if loadedCharSettings and loadedCharSettings.InstrSlots and loadedCharSettings.InstrSlots[1] then
		CharSettings = ApplyDefaults(loadedCharSettings, SettingsManager.CharacterDefaults)
	else
		CharSettings = ApplyDefaults({}, SettingsManager.CharacterDefaults)
	end
	FixupInstrSlots(CharSettings)
	InitInstrSlots(CharSettings)
end

function SettingsManager.Save()
	Turbine.PluginData.Save(Turbine.DataScope.Account, DATA_KEY, Settings,
		function(result, message)
			if result then
				Turbine.Shell.WriteLine("<rgb=#00FF00>" .. Strings["sh_saved"] .. "</rgb>")
			else
				Turbine.Shell.WriteLine("<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>")
			end
		end)
	Turbine.PluginData.Save(Turbine.DataScope.Character, DATA_KEY, CharSettings,
		function(result, message)
			if not result then
				Turbine.Shell.WriteLine("<rgb=#FF0000>" .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>")
			end
		end)
end
