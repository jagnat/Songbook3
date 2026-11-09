MainWindowLayout = {}

MainWindowLayout.MIN_WIDTH = 461
MainWindowLayout.MIN_HEIGHT = 200
MainWindowLayout.MIN_TRACKS_HEIGHT = 40

local HEADER_HEIGHT = 184
local SEARCH_TOP = 160
local SEARCH_HEIGHT = 20
local LIST_FRAME_LEFT = 12
local LIST_FRAME_RIGHT = 11
local LIST_CONTAINER_LEFT = 18
local LIST_CONTAINER_RIGHT = 10
local SEPARATOR_HEIGHT = 13
local FOOTER_OFFSET = 30
local FOOTER_HEIGHT = 20
local INSTRUMENT_PADDING = 12
local INSTRUMENT_LEFT = 10
local INSTRUMENT_BOTTOM = 37
local TIMER_WIDTH = 150
local TIMER_HEIGHT = 22
local RESIZE_SIZE = 20
local CONTENT_PADDING = 80

local function rect(left, top, width, height, visible)
	if visible == nil then visible = true end
	return { left = left, top = top, width = width, height = height, visible = visible }
end

-- state: searchVisible, tracksVisible, tracksHeight, filtersVisible, filterWidth, libraryEmpty,
-- instrumentHeight (space reserved, 0 when hidden), instrumentPanelWidth, instrumentPanelHeight
-- songBrowser, separator, trackDetail, filterPanel and timer are relative to listContainer;
-- listFrameHeading to listFrame; separatorHeading and separatorArrows to separator
function MainWindowLayout.Compute(width, height, state)
	local layout = {}
	local hasSongs = not state.libraryEmpty
	local showTracks = hasSongs and state.tracksVisible

	layout.searchInput = rect(17, SEARCH_TOP, 150, SEARCH_HEIGHT, state.searchVisible)
	layout.searchButton = rect(172, SEARCH_TOP, 80, SEARCH_HEIGHT, state.searchVisible)
	layout.clearButton = rect(255, SEARCH_TOP, 70, SEARCH_HEIGHT, state.searchVisible)

	local listTop = HEADER_HEIGHT
	if state.searchVisible then listTop = listTop + SEARCH_HEIGHT end
	local listHeight = math.max(0, height - listTop - state.instrumentHeight - FOOTER_OFFSET - INSTRUMENT_PADDING)
	local frameWidth = width - LIST_FRAME_LEFT - LIST_FRAME_RIGHT
	local containerWidth = width - LIST_CONTAINER_LEFT - LIST_CONTAINER_RIGHT

	layout.listFrame = rect(LIST_FRAME_LEFT, listTop, frameWidth, listHeight)
	layout.listFrameHeading = rect(5, 0, frameWidth, SEPARATOR_HEIGHT)
	-- the container sits below the frame heading but keeps the frame's height
	layout.listContainer = rect(LIST_CONTAINER_LEFT, listTop + SEPARATOR_HEIGHT, containerWidth, listHeight)

	local tracksSpace = showTracks and (SEPARATOR_HEIGHT + state.tracksHeight) or 0
	local browserHeight = math.max(0, listHeight - tracksSpace)
	local filterWidth = state.filtersVisible and state.filterWidth or 0

	layout.filterPanel = rect(0, 0, state.filterWidth, browserHeight, state.filtersVisible)
	layout.songBrowser = rect(filterWidth, 0, containerWidth - filterWidth, browserHeight, hasSongs)
	layout.separator = rect(0, browserHeight, containerWidth, SEPARATOR_HEIGHT, showTracks)
	layout.separatorHeading = rect(0, 0, containerWidth, SEPARATOR_HEIGHT, showTracks)
	layout.separatorArrows = rect(containerWidth / 2 - 10, 1, 20, 10, showTracks)
	layout.trackDetail = rect(0, browserHeight + SEPARATOR_HEIGHT, containerWidth, state.tracksHeight, showTracks)
	layout.timer = rect(containerWidth - TIMER_WIDTH, browserHeight - TIMER_HEIGHT, TIMER_WIDTH, TIMER_HEIGHT, hasSongs)

	layout.instrumentSlots = rect(INSTRUMENT_LEFT, height - INSTRUMENT_BOTTOM - state.instrumentPanelHeight,
		state.instrumentPanelWidth, state.instrumentPanelHeight, state.instrumentHeight > 0)
	layout.footer = rect(0, height - FOOTER_OFFSET, width, FOOTER_HEIGHT)
	layout.emptyLabel = rect(30, listTop + 25, math.max(220, width - 60), math.max(40, listHeight - 25), state.libraryEmpty)

	layout.description = rect(23, 140, width - 52, 16)
	layout.playerSync = rect(15, 30, width - 30, 56)
	layout.tooltip = rect(width - 270, 77, 245, 30)
	layout.resizeCtrl = rect(width - RESIZE_SIZE, height - RESIZE_SIZE, RESIZE_SIZE, RESIZE_SIZE)

	return layout
end

-- ctx: left, top, screenWidth, screenHeight, dirHeight, tracksVisible, tracksHeight
function MainWindowLayout.ClampWindowSize(width, height, ctx)
	width = math.max(width, MainWindowLayout.MIN_WIDTH)
	height = math.max(height, MainWindowLayout.MIN_HEIGHT)

	if ctx.left + width > ctx.screenWidth then width = ctx.screenWidth - ctx.left end
	if ctx.top + height > ctx.screenHeight then height = ctx.screenHeight - ctx.top end

	-- content room wins over the screen bound
	local tracksHeight = ctx.tracksVisible and ctx.tracksHeight or 0
	local minContentHeight = ctx.dirHeight + tracksHeight + CONTENT_PADDING
	if height < minContentHeight then height = minContentHeight end

	return width, height
end

function MainWindowLayout.ClampTracksHeight(tracksHeight)
	return math.max(tracksHeight, MainWindowLayout.MIN_TRACKS_HEIGHT)
end
