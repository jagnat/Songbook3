TimerMath = {}

function TimerMath.ParseDuration(trackName)
	local minutes, seconds = string.match(trackName or "", ".*%((%d+):(%d+)%).*")
	minutes, seconds = tonumber(minutes), tonumber(seconds)
	if minutes and seconds and minutes < 60 and seconds < 60 then
		return minutes * 60 + seconds
	end
	return 0
end

function TimerMath.InitialValue(duration, countdown)
	if countdown and duration > 0 then return duration end
	return 0
end

-- returns the value to display and whether the timer should keep running
function TimerMath.Tick(elapsed, duration, countdown)
	if countdown and duration > 0 then
		local remaining = duration - elapsed
		return remaining, remaining >= 0
	end
	return elapsed, duration == 0 or elapsed <= duration
end

function TimerMath.Format(value)
	local minutes = math.floor(value / 60)
	return string.format("%u:%02u", minutes, value - minutes * 60)
end
