SongTimerPanel = class(Turbine.UI.Control)

local WIDTH = 150
local HEIGHT = 22

function SongTimerPanel:Constructor()
	Turbine.UI.Control.Constructor(self)

	self.onTimerText = nil
	self.onStopped = nil

	self.enabled = true
	self.countdown = true
	self.warning = false
	self.running = false
	self.startTime = 0
	self.duration = 0
	self.currentValue = 0

	self.label = Turbine.UI.Label()
	self.label:SetParent(self)
	self.label:SetMultiline(false)
	self.label:SetSize(WIDTH, HEIGHT)
	self.label:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold22)
	self.label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
	self.label:SetMouseVisible(false)

	Turbine.UI.Control.SetSize(self, WIDTH, HEIGHT)
	Turbine.UI.Control.SetVisible(self, false)
end

function SongTimerPanel:IsTimerEnabled()
	return self.enabled
end

function SongTimerPanel:SetTimerEnabled(enabled)
	self.enabled = enabled
	if not enabled then self:Stop() end
end

function SongTimerPanel:IsCountdown()
	return self.countdown
end

function SongTimerPanel:SetCountdown(countdown)
	self.countdown = countdown
end

function SongTimerPanel:Start(trackName)
	self.startTime = Turbine.Engine.GetLocalTime()
	self.duration = TimerMath.ParseDuration(trackName)
	self.currentValue = TimerMath.InitialValue(self.duration, self.countdown)
	self:ShowValue(self.currentValue)
	self:SetVisible(true)
	self.running = true
	self:SetWantsUpdates(true)
end

function SongTimerPanel:Stop()
	self.running = false
	self:SetWantsUpdates(false)
	self:SetVisible(false)
	if self.onTimerText then self.onTimerText("0:00") end
	if self.onStopped then self.onStopped() end
end

function SongTimerPanel:ShowValue(value)
	local text = TimerMath.Format(value)
	self.label:SetText(text)
	if self.onTimerText then self.onTimerText(text) end
end

function SongTimerPanel:Update()
	local previous = self.currentValue
	local elapsed = Turbine.Engine.GetLocalTime() - self.startTime
	local value, keepRunning = TimerMath.Tick(elapsed, self.duration, self.countdown)
	self.currentValue = value
	if keepRunning then
		if value ~= previous then self:ShowValue(value) end
	else
		self:Stop()
	end
end

function SongTimerPanel:ShowInstrumentWarning(text)
	self.warning = true
	self.label:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold18)
	self.label:SetForeColor(ColorTheme.colourWrongInstrument)
	self.label:SetText(text)
	self:SetVisible(true)
end

function SongTimerPanel:ClearInstrumentWarning()
	self.label:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold22)
	self.label:SetForeColor(ColorTheme.colourDefault)
	self:SetVisible(false)
	self.warning = false
end

function SongTimerPanel:HasInstrumentWarning()
	return self.warning
end
