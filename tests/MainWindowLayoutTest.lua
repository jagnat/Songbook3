dofile("src/MainWindowLayout.lua")

local LIST_CHILDREN = { "songBrowser", "separator", "trackDetail", "filterPanel", "timer" }
local HEADER = { "playerSync", "version", "tooltip", "controlBar", "trackList", "description" }
local SEARCH_ROW = { "searchInput", "searchButton", "clearButton" }

-- mirrors InstrumentSlotsPanel geometry; 0 rows means the slots are hidden
local function makeState(opts, rows)
	local state = {
		searchVisible = opts.search,
		tracksVisible = opts.tracks,
		tracksHeight = opts.tracksHeight or 150,
		filtersVisible = opts.filters,
		filterWidth = 170,
		libraryEmpty = opts.empty or false,
		instrumentPanelWidth = 40 * 5,
	}
	if rows == 0 then
		state.instrumentHeight = 0
		state.instrumentPanelHeight = 38
	else
		state.instrumentHeight = 45 * rows
		state.instrumentPanelHeight = 45 * rows - 7
	end
	return state
end

local function expectRect(r, left, top, width, height, visible, name)
	local ok = r.left == left and r.top == top and r.width == width and r.height == height
	if visible ~= nil then ok = ok and r.visible == visible end
	assert(ok, string.format("%s: got (%s, %s, %s, %s, %s)", name, tostring(r.left), tostring(r.top),
		tostring(r.width), tostring(r.height), tostring(r.visible)))
end

-- snapshot: default size, search on, tracks off, one instrument row
local l = MainWindowLayout.Compute(342, 398, makeState({ search = true, tracks = false, filters = false }, 1))
expectRect(l.playerSync, 15, 30, 312, 56, true, "a.playerSync")
expectRect(l.version, 40, 25, 50, 14, true, "a.version")
expectRect(l.tooltip, 72, 77, 245, 30, true, "a.tooltip")
expectRect(l.controlBar, 0, 100, 450, 35, true, "a.controlBar")
expectRect(l.trackList, 247, 101, 35, 35, true, "a.trackList")
expectRect(l.description, 23, 140, 290, 16, true, "a.description")
expectRect(l.searchInput, 17, 160, 150, 20, true, "a.searchInput")
expectRect(l.searchButton, 172, 160, 80, 20, true, "a.searchButton")
expectRect(l.clearButton, 255, 160, 70, 20, true, "a.clearButton")
expectRect(l.listFrame, 12, 204, 319, 107, true, "a.listFrame")
expectRect(l.listFrameHeading, 5, 0, 319, 13, true, "a.listFrameHeading")
expectRect(l.listBackground, 18, 217, 314, 107, true, "a.listBackground")
expectRect(l.songBrowser, 18, 217, 314, 107, true, "a.songBrowser")
assert(not l.separator.visible and not l.trackDetail.visible and not l.filterPanel.visible)
expectRect(l.timer, 182, 302, 150, 22, true, "a.timer")
expectRect(l.instrumentSlots, 10, 323, 200, 38, true, "a.instrumentSlots")
expectRect(l.footer, 0, 368, 342, 20, true, "a.footer")
expectRect(l.emptyLabel, 30, 229, 282, 82, false, "a.emptyLabel")
expectRect(l.resizeCtrl, 322, 378, 20, 20, true, "a.resizeCtrl")

-- snapshot: search off, tracks and filters on, two instrument rows
l = MainWindowLayout.Compute(600, 700, makeState({ search = false, tracks = true, filters = true }, 2))
expectRect(l.playerSync, 15, 30, 570, 56, true, "b.playerSync")
expectRect(l.tooltip, 330, 77, 245, 30, true, "b.tooltip")
expectRect(l.controlBar, 0, 100, 450, 35, true, "b.controlBar")
expectRect(l.description, 23, 140, 548, 16, true, "b.description")
assert(not l.searchInput.visible and not l.searchButton.visible)
expectRect(l.listFrame, 12, 184, 577, 384, true, "b.listFrame")
expectRect(l.listBackground, 18, 197, 572, 384, true, "b.listBackground")
expectRect(l.filterPanel, 18, 197, 170, 221, true, "b.filterPanel")
expectRect(l.songBrowser, 188, 197, 402, 221, true, "b.songBrowser")
expectRect(l.separator, 18, 418, 572, 13, true, "b.separator")
expectRect(l.separatorHeading, 0, 0, 572, 13, true, "b.separatorHeading")
expectRect(l.separatorArrows, 276, 1, 20, 10, true, "b.separatorArrows")
expectRect(l.trackDetail, 18, 431, 572, 150, true, "b.trackDetail")
expectRect(l.timer, 440, 396, 150, 22, true, "b.timer")
expectRect(l.instrumentSlots, 10, 580, 200, 83, true, "b.instrumentSlots")
expectRect(l.footer, 0, 670, 600, 20, true, "b.footer")
expectRect(l.resizeCtrl, 580, 680, 20, 20, true, "b.resizeCtrl")

-- snapshot: empty library, instrument slots hidden
l = MainWindowLayout.Compute(500, 500, makeState({ search = true, tracks = true, filters = false, empty = true }, 0))
expectRect(l.listFrame, 12, 204, 477, 254, true, "c.listFrame")
assert(not l.songBrowser.visible and not l.separator.visible and not l.trackDetail.visible)
expectRect(l.emptyLabel, 30, 229, 440, 229, true, "c.emptyLabel")
expectRect(l.instrumentSlots, 10, 425, 200, 38, false, "c.instrumentSlots")

-- snapshot: tracks taller than the list are cut to the list background
l = MainWindowLayout.Compute(461, 330, makeState({ search = true, tracks = true, filters = false }, 1))
expectRect(l.listBackground, 18, 217, 433, 39, true, "d.listBackground")
expectRect(l.songBrowser, 18, 217, 433, 0, true, "d.songBrowser")
expectRect(l.separator, 18, 217, 433, 13, true, "d.separator")
expectRect(l.trackDetail, 18, 230, 433, 26, true, "d.trackDetail")
expectRect(l.timer, 301, 217, 150, 0, true, "d.timer")

-- snapshot: window too short for its content, list sizes floor at zero
l = MainWindowLayout.Compute(461, 200, makeState({ search = true, tracks = true, filters = false }, 1))
expectRect(l.listFrame, 12, 204, 438, 0, true, "e.listFrame")
expectRect(l.songBrowser, 18, 217, 433, 0, true, "e.songBrowser")
expectRect(l.trackDetail, 18, 217, 433, 0, true, "e.trackDetail")
expectRect(l.emptyLabel, 30, 229, 401, 40, false, "e.emptyLabel")

-- resize clamp
local screen = { left = 100, top = 100, screenWidth = 1920, screenHeight = 1080, dirHeight = 100, tracksVisible = true, tracksHeight = 150 }
local w, h = MainWindowLayout.ClampWindowSize(300, 150, screen)
assert(w == 461 and h == 330)
screen.tracksVisible = false
w, h = MainWindowLayout.ClampWindowSize(300, 150, screen)
assert(w == 461 and h == 200)
w, h = MainWindowLayout.ClampWindowSize(800, 600, screen)
assert(w == 800 and h == 600)
screen.left, screen.top = 1700, 900
w, h = MainWindowLayout.ClampWindowSize(800, 600, screen)
assert(w == 220 and h == 180)
screen.tracksVisible = true
w, h = MainWindowLayout.ClampWindowSize(800, 600, screen)
assert(w == 220 and h == 330)

assert(MainWindowLayout.ClampTracksHeight(10) == 40)
assert(MainWindowLayout.ClampTracksHeight(40) == 40)
assert(MainWindowLayout.ClampTracksHeight(200) == 200)

-- properties
local function inside(r, width, height)
	return r.left >= 0 and r.top >= 0 and r.left + r.width <= width and r.top + r.height <= height
end

local function within(r, area)
	return r.left >= area.left and r.top >= area.top and r.left + r.width <= area.left + area.width
		and r.top + r.height <= area.top + area.height
end

local function overlaps(a, b)
	return a.left < b.left + b.width and b.left < a.left + a.width and a.top < b.top + b.height and b.top < a.top + a.height
end

-- header overlaps the window has always had: the track button sits on the control bar and the
-- tooltip and version label share rows with their neighbours
local HEADER_OVERLAPS = {
	["trackList/controlBar"] = true,
	["tooltip/controlBar"] = true,
	["tooltip/trackList"] = true,
	["playerSync/tooltip"] = true,
	["playerSync/version"] = true,
}

local function bottomOf(layout, names)
	local bottom = 0
	for _, name in ipairs(names) do
		local r = layout[name]
		bottom = math.max(bottom, r.top + r.height)
	end
	return bottom
end

-- smallest height at which the browser keeps room for the timer and the tracks keep their size
local function requiredHeight(state)
	local listTop = 184 + (state.searchVisible and 20 or 0)
	local content
	if state.libraryEmpty then
		content = 65
	else
		content = 22
		if state.tracksVisible then content = content + 13 + state.tracksHeight end
	end
	return listTop + state.instrumentHeight + 42 + content
end

local sizes = { { 461, 200 }, { 342, 398 }, { 461, 330 }, { 1200, 900 } }
local bools = { true, false }
local checked, contained = 0, 0

for _, size in ipairs(sizes) do
	local width, height = size[1], size[2]
	for _, search in ipairs(bools) do
	for _, tracks in ipairs(bools) do
	for _, filters in ipairs(bools) do
	for _, empty in ipairs(bools) do
	for _, tracksHeight in ipairs({ 40, 150 }) do
	for rows = 0, 4 do
		local state = makeState({ search = search, tracks = tracks, filters = filters, empty = empty, tracksHeight = tracksHeight }, rows)
		local layout = MainWindowLayout.Compute(width, height, state)
		local label = string.format("%dx%d search=%s tracks=%s filters=%s empty=%s th=%d rows=%d",
			width, height, tostring(search), tostring(tracks), tostring(filters), tostring(empty), tracksHeight, rows)

		for name, r in pairs(layout) do
			assert(r.width >= 0 and r.height >= 0, label .. ": negative size for " .. name)
		end

		-- header sits above the search row, which sits above the list
		local headerBottom = bottomOf(layout, HEADER)
		for _, name in ipairs(HEADER) do
			local r = layout[name]
			assert(r.visible, label .. ": " .. name .. " hidden")
			if width >= MainWindowLayout.MIN_WIDTH then
				assert(inside(r, width, height) or height < headerBottom, label .. ": " .. name .. " outside window")
			end
		end
		for i = 1, #HEADER do
			for j = i + 1, #HEADER do
				local a, b = HEADER[i], HEADER[j]
				if not HEADER_OVERLAPS[a .. "/" .. b] and not HEADER_OVERLAPS[b .. "/" .. a] then
					assert(not overlaps(layout[a], layout[b]), label .. ": " .. a .. " overlaps " .. b)
				end
			end
		end
		assert(headerBottom <= layout.listFrame.top, label .. ": header overlaps list")

		assert(layout.searchInput.visible == search and layout.clearButton.visible == search, label)
		for _, name in ipairs(SEARCH_ROW) do
			local s = layout[name]
			assert(s.top >= headerBottom, label .. ": " .. name .. " overlaps header")
			if search then
				assert(s.top + s.height <= layout.listFrame.top, label .. ": " .. name .. " overlaps list")
			end
		end

		assert(layout.songBrowser.visible == not empty, label)
		assert(layout.emptyLabel.visible == empty, label)
		assert(layout.trackDetail.visible == (tracks and not empty), label)
		assert(layout.separator.visible == layout.trackDetail.visible, label)
		assert(layout.instrumentSlots.visible == (rows > 0), label)

		-- list components never leave the list background, whatever the window size
		local area = layout.listBackground
		assert(area.left == layout.listFrame.left + 6 and area.top == layout.listFrame.top + 13, label)
		for _, name in ipairs(LIST_CHILDREN) do
			assert(within(layout[name], area), label .. ": " .. name .. " outside list background")
		end

		-- browser, separator and tracks stack top to bottom
		local stack = { layout.songBrowser, layout.separator, layout.trackDetail }
		assert(layout.songBrowser.top == area.top, label)
		local bottom = area.top
		for _, r in ipairs(stack) do
			if r.visible and r.height > 0 then
				assert(r.top >= bottom, label .. ": stack overlap")
				bottom = r.top + r.height
			end
		end

		-- filter panel sits beside the browser
		local f, b = layout.filterPanel, layout.songBrowser
		if f.visible then
			assert(f.left == area.left and f.left + f.width <= b.left, label .. ": filter overlaps browser")
			assert(f.top == b.top and f.height == b.height, label)
		else
			assert(b.left == area.left, label)
		end
		assert(b.left + b.width == area.left + area.width, label)

		-- footer, instruments and resize grip anchor to the bottom
		local footer = layout.footer
		assert(footer.left == 0 and footer.width == width, label)
		assert(footer.top + footer.height <= height and footer.top >= height - 30, label .. ": footer not at bottom")
		local slots = layout.instrumentSlots
		assert(slots.top + slots.height <= footer.top, label .. ": instruments overlap footer")
		local grip = layout.resizeCtrl
		assert(grip.left + grip.width == width and grip.top + grip.height == height, label)

		if height >= requiredHeight(state) then
			contained = contained + 1
			if layout.trackDetail.visible then
				assert(layout.trackDetail.height == tracksHeight, label .. ": tracks squeezed")
				assert(layout.trackDetail.height >= MainWindowLayout.MIN_TRACKS_HEIGHT, label)
			end
			assert(layout.timer.height == 22, label .. ": timer clipped")
			assert(layout.listFrame.top + layout.listFrame.height <= slots.top or not slots.visible, label)
			for name, r in pairs(layout) do
				local isChild = name == "listFrameHeading" or name == "separatorHeading" or name == "separatorArrows"
				if r.visible and not isChild and (width >= MainWindowLayout.MIN_WIDTH or name ~= "controlBar") then
					assert(inside(r, width, height), label .. ": " .. name .. " outside window")
				end
			end
		end
		checked = checked + 1
	end
	end
	end
	end
	end
	end
end

assert(contained > 0)
print(string.format("MainWindowLayoutTest ok (%d layouts, %d fully contained)", checked, contained))
