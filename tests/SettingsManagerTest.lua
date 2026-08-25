dofile("src/SettingsManager.lua")

local pendingLoad
Turbine = {
	DataScope = { Account = "Account" },
	PluginData = {
		Load = function(scope, key, callback)
			assert(scope == "Account")
			assert(key == "SongbookData")
			pendingLoad = callback
		end,
	},
}

local database = { Directories = {}, Songs = {} }
local loadedDatabase
assert(SettingsManager.ReloadSongDatabase(function(success, result)
	assert(success)
	loadedDatabase = result
end))
assert(loadedDatabase == nil, "reload completed before the asynchronous callback")
pendingLoad(database)
assert(loadedDatabase == database)

local firstLoad
assert(SettingsManager.ReloadSongDatabase(function() end))
firstLoad = pendingLoad
local busyReason
assert(not SettingsManager.ReloadSongDatabase(function(success, reason)
	assert(not success)
	busyReason = reason
end))
assert(busyReason == "busy")
firstLoad(database)

Turbine.PluginData.Load = function(scope, key, callback)
	callback(nil)
end
local missingReason
assert(SettingsManager.ReloadSongDatabase(function(success, reason)
	assert(not success)
	missingReason = reason
end))
assert(missingReason == "load")

Turbine.PluginData.Load = function()
	error("load failed")
end
local loadReason
assert(not SettingsManager.ReloadSongDatabase(function(success, reason)
	assert(not success)
	loadReason = reason
end))
assert(loadReason == "load")

print("SettingsManager tests passed")
