dofile("src/Utils.lua")

local function check(expected, ...)
	local actual = { ... }
	for i = 1, #expected do
		assert(actual[i] == expected[i], "value " .. i .. ": expected " .. tostring(expected[i]) .. ", got " .. tostring(actual[i]))
	end
end

check({ 10, 20, 300, 200, false }, Utils.ClampToDisplay(10, 20, 300, 200, 1920, 1080))
check({ 1620, 20, 300, 200, true }, Utils.ClampToDisplay(1800, 20, 300, 200, 1920, 1080))
check({ 10, 880, 300, 200, true }, Utils.ClampToDisplay(10, 1000, 300, 200, 1920, 1080))
check({ 0, 0, 300, 200, true }, Utils.ClampToDisplay(-5, -10, 300, 200, 1920, 1080))
check({ 0, 0, 1920, 1080, true }, Utils.ClampToDisplay(100, 100, 2500, 1200, 1920, 1080))
check({ 1620, 880, 300, 200, false }, Utils.ClampToDisplay(1620, 880, 300, 200, 1920, 1080))

print("UtilsTest ok")
