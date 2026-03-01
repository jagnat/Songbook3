
-- SongLibrary
-- Song/directory/track data management for Songbook3.

SongLibrary = {}

SongLibrary.selectedSong = ""
SongLibrary.selectedSongIndex = 1
SongLibrary.selectedTrack = 1
SongLibrary.selectedDir = "/"
SongLibrary.dirPath = {"/"}
SongLibrary.librarySize = 0
SongLibrary.selectedSongIndexListBox = 0
SongLibrary.filteredIndices = {}
SongLibrary.setupTrackIndices = {}
SongLibrary.setupListIndices = {}
SongLibrary.currentSetup = nil
SongLibrary.selectedSetupCount = 'A'

function SongLibrary.Init()
	SongLibrary.librarySize = #SongDB.Songs
	table.sort(SongDB.Songs, SongLibrary.SortByName)
end

function SongLibrary.SortByName(song1, song2)
	if song1.Filepath == song2.Filepath then
		return string.lower(song1.Filename) < string.lower(song2.Filename)
	else
		return string.lower(song1.Filepath) < string.lower(song2.Filepath)
	end
end

function SongLibrary.MatchStringList(list1, list2)
	for word1 in string.gmatch(list1, "%a+") do
		for word2 in string.gmatch(list2, "%a+") do
			if word1 == word2 then return true end
		end
	end
	return false
end

function SongLibrary.IsEmptyString(s)
	return not not tostring(s):find("^%s*$")
end

function SongLibrary.TerseTrackname(sTrack)
	return sTrack
end

function SongLibrary.ParsePartsFilter(sText, maxTrackCount)
	if not maxTrackCount then maxTrackCount = 25 end
	local sPattern = "["
	local iEnd = 0
	local number, numberTo, iEndTo, temp

	for _ = 1, maxTrackCount do
		iEnd = iEnd + 1
		temp, iEnd, number = string.find(sText, "%s*(%d+)%s*", iEnd)

		if iEnd == nil then break end

		iEnd = iEnd + 1
		if string.sub(sText, iEnd, iEnd) == "-" then
			temp, iEndTo, numberTo = string.find(sText, "%s*(%d+)%s*", iEnd + 1)
			if iEndTo == nil then
				numberTo = maxTrackCount
			else
				iEnd = iEndTo + 1
			end
		else
			numberTo = number
		end

		for temp = number, numberTo do
			sPattern = sPattern .. string.char(0x40 + temp)
		end
	end

	if sPattern == "[" then
		return "[a-z]"
	else
		return sPattern .. "]"
	end
end

function SongLibrary.ApplyFilters(songData, filters)
	if songData == nil then return false end
	if not filters then return true end

	if filters.composer ~= nil then
		if songData.Artist == nil then return false end
		local sFilter = string.lower(filters.composer)
		if sFilter ~= "" and string.find(string.lower(songData.Artist), sFilter) == nil then
			return false
		end
	end
	if filters.partcount ~= nil then
		local sFilter = filters.partcount
		if sFilter == "" then
			if not filters.maxPartCount then return true
			else sFilter = "1-" .. tostring(filters.maxPartCount) end
		end
		if songData.Partcounts == nil then return false end
		local pattern = SongLibrary.ParsePartsFilter(sFilter, 25)
		if string.match(songData.Partcounts, pattern) == nil then
			return false
		end
	end
	if filters.genre ~= nil then
		if songData.Genre == nil then return false end
		local sFilter = string.lower(filters.genre)
		if sFilter ~= "" and not SongLibrary.MatchStringList(sFilter, string.lower(songData.Genre)) then
			return false
		end
	end
	if filters.mood ~= nil then
		if songData.Mood == nil then return false end
		local sFilter = string.lower(filters.mood)
		if sFilter ~= "" and not SongLibrary.MatchStringList(sFilter, string.lower(songData.Mood)) then
			return false
		end
	end
	if filters.author ~= nil then
		if songData.Transcriber == nil then return false end
		local sFilter = string.lower(filters.author)
		if sFilter ~= "" and string.find(sFilter, string.lower(songData.Transcriber)) == nil then
			return false
		end
	end
	return true
end

function SongLibrary.GetDisplayText(songIndex)
	local song = SongDB.Songs[songIndex]
	if Settings.DescriptionVisible then
		if Settings.DescriptionFirst then
			return song.Tracks[1].Name .. " / " .. song.Filename
		else
			return song.Filename .. " / " .. song.Tracks[1].Name
		end
	end
	return song.Filename
end

function SongLibrary.GetSubdirectories()
	local result = {}
	local _, dirLevelIni = string.gsub(SongLibrary.selectedDir, "/", "/")
	for i = 1, #SongDB.Directories do
		local _, dirLevel = string.gsub(SongDB.Directories[i], "/", "/")
		if dirLevel == dirLevelIni + 1 then
			if SongLibrary.selectedDir ~= "/" then
				local matchPos = string.find(SongDB.Directories[i], SongLibrary.selectedDir, 1, true)
				if matchPos == 1 then
					local _, cutPoint = string.find(SongDB.Directories[i], SongLibrary.dirPath[#SongLibrary.dirPath], 1, true)
					result[#result+1] = string.sub(SongDB.Directories[i], cutPoint+1)
				end
			else
				result[#result+1] = string.sub(SongDB.Directories[i], 2)
			end
		end
	end
	return result
end

function SongLibrary.NavigateToDirectory(dirName)
	SongLibrary.selectedDir = SongLibrary.selectedDir .. dirName
	SongLibrary.dirPath[#SongLibrary.dirPath+1] = dirName
end

function SongLibrary.NavigateUp()
	table.remove(SongLibrary.dirPath, #SongLibrary.dirPath)
	SongLibrary.selectedDir = ""
	for i = 1, #SongLibrary.dirPath do
		SongLibrary.selectedDir = SongLibrary.selectedDir .. SongLibrary.dirPath[i]
	end
end

function SongLibrary.NavigateToPath(path)
	SongLibrary.selectedDir = path
	SongLibrary.dirPath = {"/"}
	for token in string.gmatch(path, "([^/]+)") do
		SongLibrary.dirPath[#SongLibrary.dirPath+1] = token .. "/"
	end
end

function SongLibrary.GetSongsInDirectory(filters)
	local result = {}
	SongLibrary.filteredIndices = {}
	local n = 0
	for i = 1, SongLibrary.librarySize do
		if SongDB.Songs[i].Filepath == SongLibrary.selectedDir and SongLibrary.ApplyFilters(SongDB.Songs[i], filters) then
			n = n + 1
			SongLibrary.filteredIndices[n] = i
			result[n] = { index = i, text = SongLibrary.GetDisplayText(i) }
		end
	end
	return result
end

function SongLibrary.SearchSongs(searchText, filters)
	local result = {}
	SongLibrary.filteredIndices = {}
	local n = 0
	local lowerSearch = string.lower(searchText)
	for i = 1, SongLibrary.librarySize do
		if SongLibrary.ApplyFilters(SongDB.Songs[i], filters) then
			local found = false
			if string.find(string.lower(SongDB.Songs[i].Filename), lowerSearch) ~= nil then
				found = true
			else
				for j = 1, #SongDB.Songs[i].Tracks do
					if string.find(string.lower(SongDB.Songs[i].Tracks[j].Name), lowerSearch) ~= nil then
						found = true
						break
					end
				end
			end
			if found then
				n = n + 1
				SongLibrary.filteredIndices[n] = i
				result[n] = { index = i, text = SongLibrary.GetDisplayText(i) }
			end
		end
	end
	return result
end

function SongLibrary.SelectedTrackIndex(iList)
	if not iList then iList = SongLibrary.selectedTrack end
	if SongLibrary.currentSetup and SongLibrary.setupTrackIndices[iList] then
		return SongLibrary.setupTrackIndices[iList]
	end
	return iList
end

function SongLibrary.SetupIndexForCount(songId, setupCount)
	if not setupCount or not SongDB.Songs[songId] or not SongDB.Songs[songId].Setups then return nil end
	local i
	for i = 1, #SongDB.Songs[songId].Setups do
		if setupCount == #SongDB.Songs[songId].Setups[i] then return i end
	end
	return i
end

function SongLibrary.FindSongByMatch(filename, trackName, numParts)
	local SongIndex = {}

	local Number_Of_Found_Songs = 0
	SongIndex[0] = Number_Of_Found_Songs

	filename = string.lower(filename)
	trackName = string.lower(trackName)
	numParts = tonumber(numParts)

	for i = 1, SongLibrary.librarySize do
		local SongDB_Filename = string.lower(SongDB.Songs[i].Filename)

		if SongDB_Filename == filename then
			local trackcount = #SongDB.Songs[i].Tracks

			if trackcount == numParts then
				for j = 1, trackcount do
					local SongDB_TrackName = string.lower(SongDB.Songs[i].Tracks[j].Name)

					if SongDB_TrackName == trackName then
						Number_Of_Found_Songs = Number_Of_Found_Songs + 1
						SongIndex[Number_Of_Found_Songs] = i
						break
					end
				end
			end
		end
	end

	if Number_Of_Found_Songs == 0 then
		for i = 1, SongLibrary.librarySize do
			local trackcount = #SongDB.Songs[i].Tracks

			if trackcount == numParts then
				for j = 1, trackcount do
					local SongDB_TrackName = string.lower(SongDB.Songs[i].Tracks[j].Name)

					if SongDB_TrackName == trackName then
						Number_Of_Found_Songs = Number_Of_Found_Songs + 1
						SongIndex[Number_Of_Found_Songs] = i
						break
					end
				end
			end
		end
	end

	SongIndex[0] = Number_Of_Found_Songs

	return SongIndex
end

function SongLibrary.FindSongByTrackName(trackName)
	local SongIndex = {}

	local Number_Of_Found_Songs = 0
	SongIndex[0] = Number_Of_Found_Songs

	local Synced_TrackName = string.lower(trackName)

	for i = 1, SongLibrary.librarySize do
		local trackcount = #SongDB.Songs[i].Tracks

		for j = 1, trackcount do
			local SongDB_TrackName = string.lower(SongDB.Songs[i].Tracks[j].Name)

			if Synced_TrackName == string.sub(SongDB_TrackName, 1, #Synced_TrackName) then
				Number_Of_Found_Songs = Number_Of_Found_Songs + 1
				SongIndex[Number_Of_Found_Songs] = i
				break
			end
		end
	end

	SongIndex[0] = Number_Of_Found_Songs

	return SongIndex
end
