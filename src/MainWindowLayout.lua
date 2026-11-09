MainWindowLayout = {}

MainWindowLayout.MIN_WIDTH = 461
MainWindowLayout.MIN_HEIGHT = 200
MainWindowLayout.MIN_TRACKS_HEIGHT = 40

local HEADER_HEIGHT = 184
local SEARCH_TOP = 160
local SEARCH_HEIGHT = 20
local LIST_FRAME_LEFT = 12
local LIST_FRAME_RIGHT = 11
local LIST_LEFT = 18
local LIST_RIGHT = 10
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

-- list components are cut to the list background instead of spilling over the footer
local function clip(r, area)
	local areaRight, areaBottom = area.left + area.width, area.top + area.height
	local left = math.min(math.max(r.left, area.left), areaRight)
	local top = math.min(math.max(r.top, area.top), areaBottom)
	local right = math.min(r.left + r.width, areaRight)
	local bottom = math.min(r.top + r.height, areaBottom)
	return rect(left, top, math.max(0, right - left), math.max(0, bottom - top), r.visible)
end

-- state: searchVisible, tracksVisible, tracksHeight, filtersVisible, filterWidth, libraryEmpty,
-- instrumentHeight (space reserved, 0 when hidden), instrumentPanelWidth, instrumentPanelHeight
-- rects are window-relative except listFrameHeading (to listFrame) and separatorHeading and
-- separatorArrows (to separator)
function MainWindowLayout.Compute(width, height, state)
	local layout = {}
	local hasSongs = not state.libraryEmpty
	local showTracks = hasSongs and state.tracksVisible

	layout.playerSync = rect(15, 30, width - 30, 56)
	layout.version = rect(40, 25, 50, 14)
	layout.tooltip = rect(width - 270, 77, 245, 30)
	layout.controlBar = rect(0, 100, 450, 35)
	layout.trackList = rect(247, 101, 35, 35)
	layout.description = rect(23, 140, width - 52, 16)

	layout.searchInput = rect(17, SEARCH_TOP, 150, SEARCH_HEIGHT, state.searchVisible)
	layout.searchButton = rect(172, SEARCH_TOP, 80, SEARCH_HEIGHT, state.searchVisible)
	layout.clearButton = rect(255, SEARCH_TOP, 70, SEARCH_HEIGHT, state.searchVisible)

	local listTop = HEADER_HEIGHT
	if state.searchVisible then listTop = listTop + SEARCH_HEIGHT end
	local listHeight = math.max(0, height - listTop - state.instrumentHeight - FOOTER_OFFSET - INSTRUMENT_PADDING)
	local frameWidth = width - LIST_FRAME_LEFT - LIST_FRAME_RIGHT
	local listWidth = width - LIST_LEFT - LIST_RIGHT
	local contentTop = listTop + SEPARATOR_HEIGHT

	layout.listFrame = rect(LIST_FRAME_LEFT, listTop, frameWidth, listHeight)
	layout.listFrameHeading = rect(5, 0, frameWidth, SEPARATOR_HEIGHT)
	-- the background sits below the frame heading but keeps the frame's height
	local area = rect(LIST_LEFT, contentTop, listWidth, listHeight)
	layout.listBackground = area

	local tracksSpace = showTracks and (SEPARATOR_HEIGHT + state.tracksHeight) or 0
	local browserHeight = math.max(0, listHeight - tracksSpace)
	local browserBottom = contentTop + browserHeight
	local filterWidth = state.filtersVisible and state.filterWidth or 0

	layout.filterPanel = clip(rect(LIST_LEFT, contentTop, state.filterWidth, browserHeight, state.filtersVisible), area)
	layout.songBrowser = clip(rect(LIST_LEFT + filterWidth, contentTop, listWidth - filterWidth, browserHeight, hasSongs), area)
	layout.separator = clip(rect(LIST_LEFT, browserBottom, listWidth, SEPARATOR_HEIGHT, showTracks), area)
	layout.separatorHeading = rect(0, 0, listWidth, SEPARATOR_HEIGHT, showTracks)
	layout.separatorArrows = rect(listWidth / 2 - 10, 1, 20, 10, showTracks)
	layout.trackDetail = clip(rect(LIST_LEFT, browserBottom + SEPARATOR_HEIGHT, listWidth, state.tracksHeight, showTracks), area)
	layout.timer = clip(rect(LIST_LEFT + listWidth - TIMER_WIDTH, browserBottom - TIMER_HEIGHT, TIMER_WIDTH, TIMER_HEIGHT, hasSongs), area)

	layout.instrumentSlots = rect(INSTRUMENT_LEFT, height - INSTRUMENT_BOTTOM - state.instrumentPanelHeight,
		state.instrumentPanelWidth, state.instrumentPanelHeight, state.instrumentHeight > 0)
	layout.footer = rect(0, height - FOOTER_OFFSET, width, FOOTER_HEIGHT)
	layout.emptyLabel = rect(30, listTop + 25, math.max(220, width - 60), math.max(40, listHeight - 25), state.libraryEmpty)
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
