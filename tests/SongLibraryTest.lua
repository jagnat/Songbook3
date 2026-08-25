Settings = { DescriptionVisible = false, DescriptionFirst = false }

SongDB = {
	Directories = { "/Folk/", "/Rock/", "/Rock/Live/" },
	Songs = {
		{
			Filename = "First Song", Filepath = "/Rock/", Artist = "The Minstrels",
			Genre = "rock anthem", Mood = "bright energetic", Transcriber = "Alice",
			Partcounts = "AB", Tracks = { { Id = "1", Name = "Lute" }, { Id = "2", Name = "Drum" } },
		},
		{
			Filename = "Second Song", Filepath = "/Folk/", Artist = "The Wanderers",
			Genre = "folk ballad", Mood = "calm", Transcriber = "Bob",
			Partcounts = "C", Tracks = { { Id = "1", Name = "Ballad for Harp" } },
		},
		{
			Filename = "Live Song", Filepath = "/Rock/Live/", Artist = "The Minstrels",
			Genre = "rock", Mood = "energetic", Transcriber = "Alice",
			Partcounts = "D", Tracks = { { Id = "1", Name = "Cowbell" } },
		},
	},
}

dofile("src/SongLibrary.lua")
SongLibrary.Init()

assert(SongLibrary.librarySize == 3)
assert(SongDB.Songs[1].Filename == "Second Song", "songs were not sorted by path and filename")
assert(SongLibrary.ValidateDatabase(SongDB))
assert(not SongLibrary.ValidateDatabase(nil))
assert(not SongLibrary.ValidateDatabase({ Directories = {}, Songs = { {} } }))

local subdirs = SongLibrary.GetSubdirectories()
assert(#subdirs == 2 and subdirs[1] == "Folk/" and subdirs[2] == "Rock/")
SongLibrary.NavigateToDirectory("Rock/")
assert(SongLibrary.selectedDir == "/Rock/")
subdirs = SongLibrary.GetSubdirectories()
assert(#subdirs == 1 and subdirs[1] == "Live/")

local results = SongLibrary.GetSongsInDirectory({ composer = "minstrel", partcount = "1-2" })
assert(#results == 1 and SongDB.Songs[results[1].index].Filename == "First Song")
results = SongLibrary.SearchSongs("cowbell")
assert(#results == 1 and SongDB.Songs[results[1].index].Filename == "Live Song")
assert(SongLibrary.ParsePartsFilter("1, 3-4", 5) == "[ACD]")
assert(SongLibrary.MatchStringList("folk rock", "jazz rock"))
assert(not SongLibrary.MatchStringList("folk", "jazz rock"))
assert(SongLibrary.IsEmptyString("  "))

SongLibrary.selectedSongIndex = 2
SongLibrary.selectedSong = "First Song"
SongLibrary.selectedTrack = 2

local databaseEvents = 0
local function onDatabaseChanged(database)
	databaseEvents = databaseEvents + 1
	assert(database == SongDB)
end
SongLibrary.On("databaseChanged", onDatabaseChanged)

local refreshedDatabase = {
	Directories = { "/Folk/", "/Rock/" },
	Songs = {
		{ Filename = "First Song", Filepath = "/Rock/", Tracks = {
			{ Id = "1", Name = "Lute" }, { Id = "2", Name = "Drum" }, { Id = "3", Name = "Harp" },
		} },
		{ Filename = "Aardvark", Filepath = "/Folk/", Tracks = { { Id = "1", Name = "Flute" } } },
	},
}

local replaced, selectedIndex = SongLibrary.ReplaceDatabase(refreshedDatabase)
assert(replaced and selectedIndex == 2)
assert(SongDB == refreshedDatabase)
assert(SongLibrary.selectedDir == "/Rock/")
assert(SongLibrary.selectedSong == "First Song" and SongLibrary.selectedTrack == 2)
assert(databaseEvents == 1)

local activeDatabase = SongDB
replaced = SongLibrary.ReplaceDatabase({ Directories = {}, Songs = { {} } })
assert(not replaced and SongDB == activeDatabase, "invalid refresh replaced the active database")

SongLibrary.Off("databaseChanged", onDatabaseChanged)
SongLibrary.NavigateToPath("/Removed/")
replaced = SongLibrary.ReplaceDatabase(refreshedDatabase)
assert(replaced and SongLibrary.selectedDir == "/" and databaseEvents == 1)

replaced, selectedIndex = SongLibrary.ReplaceDatabase({ Directories = {}, Songs = {} })
assert(replaced and selectedIndex == 0)
assert(SongLibrary.librarySize == 0 and SongLibrary.selectedSongIndex == 0)
assert(SongLibrary.selectedSong == "" and SongLibrary.selectedTrack == 1)

print("SongLibrary tests passed")
