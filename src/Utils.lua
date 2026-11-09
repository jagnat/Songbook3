-- Utils
-- Shared utility functions for Songbook3.

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

function RemoveCallback(object, event, callback)
    if (object[event] == callback) then
        object[event] = nil;
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event]);
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i);
                    break;
                end
            end
        end
    end
end

Utils = {}

-- shrinks to fit the display first, then moves back on screen
function Utils.ClampToDisplay(left, top, width, height, displayWidth, displayHeight)
	local changed = false
	if width > displayWidth then width = displayWidth; changed = true end
	if height > displayHeight then height = displayHeight; changed = true end
	if left + width > displayWidth then left = displayWidth - width; changed = true end
	if top + height > displayHeight then top = displayHeight - height; changed = true end
	if left < 0 then left = 0; changed = true end
	if top < 0 then top = 0; changed = true end
	return left, top, width, height, changed
end
