
-- Layout utility for Songbook3.
-- Provides vertical and horizontal stacking of Turbine UI controls.

Layout = {}

-- Stack children vertically.
--
-- children: array of { control, height, [visible] }
--   height  = number (fixed px) or "fill" (gets remaining space)
--   visible = false → control is hidden and takes no space (default true)
--   At most one child should use height = "fill"
--
-- options: { x, y, width, height, gap }
--   x      = if set, each child's left is set to this value (default: untouched)
--   y      = starting Y position (default 0)
--   width  = if set, each child's width is set to this value
--   height = total available height (required when using "fill")
--   gap    = pixels between visible items (default 0)
--
-- Returns the Y position after the last placed item.
--
function Layout.stackVertical(children, options)
	local x      = options.x
	local startY = options.y      or 0
	local gap    = options.gap    or 0
	local avail  = options.height or 0
	local width  = options.width

	-- Count visible fixed-height items and find the fill child
	local fixedTotal = 0
	local visibleCount = 0
	local fillIndex = nil

	for i, item in ipairs(children) do
		local visible = item.visible
		if visible == nil then visible = true end

		if visible then
			visibleCount = visibleCount + 1
			if item.height == "fill" then
				fillIndex = i
			else
				fixedTotal = fixedTotal + item.height
			end
		end
	end

	-- Gaps are between visible items only
	if visibleCount > 1 then
		fixedTotal = fixedTotal + gap * (visibleCount - 1)
	end

	local fillHeight = 0
	if fillIndex then
		fillHeight = avail - fixedTotal
		if fillHeight < 0 then fillHeight = 0 end
	end

	-- Position each child
	local currentY = startY
	local placed = 0

	for i, item in ipairs(children) do
		local visible = item.visible
		if visible == nil then visible = true end

		if not visible then
			item.control:SetVisible(false)
		else
			local h = (item.height == "fill") and fillHeight or item.height
			item.control:SetVisible(true)
			item.control:SetTop(currentY)
			if x then item.control:SetLeft(x) end
			item.control:SetHeight(h)
			if width then
				item.control:SetWidth(width)
			end
			currentY = currentY + h
			placed = placed + 1
			if placed < visibleCount then
				currentY = currentY + gap
			end
		end
	end

	return currentY
end

-- Stack children horizontally.
--
-- children: array of { control, width, [visible] }
--   width   = number (fixed px) or "fill" (gets remaining space)
--   visible = false → control is hidden and takes no space (default true)
--   At most one child should use width = "fill"
--
-- options: { x, y, height, width, gap }
--   x      = starting X position (default 0)
--   y      = if set, each child's top is set to this value (default: untouched)
--   height = if set, each child's height is set to this value
--   width  = total available width (required when using "fill")
--   gap    = pixels between visible items (default 0)
--
-- Returns the X position after the last placed item.
--
function Layout.stackHorizontal(children, options)
	local startX = options.x     or 0
	local y      = options.y
	local gap    = options.gap   or 0
	local avail  = options.width or 0
	local height = options.height

	local fixedTotal = 0
	local visibleCount = 0
	local fillIndex = nil

	for i, item in ipairs(children) do
		local visible = item.visible
		if visible == nil then visible = true end

		if visible then
			visibleCount = visibleCount + 1
			if item.width == "fill" then
				fillIndex = i
			else
				fixedTotal = fixedTotal + item.width
			end
		end
	end

	if visibleCount > 1 then
		fixedTotal = fixedTotal + gap * (visibleCount - 1)
	end

	local fillWidth = 0
	if fillIndex then
		fillWidth = avail - fixedTotal
		if fillWidth < 0 then fillWidth = 0 end
	end

	local currentX = startX
	local placed = 0

	for i, item in ipairs(children) do
		local visible = item.visible
		if visible == nil then visible = true end

		if not visible then
			item.control:SetVisible(false)
		else
			local w = (item.width == "fill") and fillWidth or item.width
			item.control:SetVisible(true)
			item.control:SetLeft(currentX)
			if y then item.control:SetTop(y) end
			item.control:SetWidth(w)
			if height then
				item.control:SetHeight(height)
			end
			currentX = currentX + w
			placed = placed + 1
			if placed < visibleCount then
				currentX = currentX + gap
			end
		end
	end

	return currentX
end
