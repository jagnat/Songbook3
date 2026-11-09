dofile("src/TimerMath.lua")

assert(TimerMath.ParseDuration("Lute (3:45)") == 225)
assert(TimerMath.ParseDuration("Lute (03:05) extra") == 185)
assert(TimerMath.ParseDuration("Lute (3:75)") == 0)
assert(TimerMath.ParseDuration("Lute (61:00)") == 0)
assert(TimerMath.ParseDuration("Lute") == 0)
assert(TimerMath.ParseDuration(nil) == 0)

assert(TimerMath.InitialValue(225, true) == 225)
assert(TimerMath.InitialValue(225, false) == 0)
assert(TimerMath.InitialValue(0, true) == 0)

local value, keep = TimerMath.Tick(10, 225, true)
assert(value == 215 and keep)
value, keep = TimerMath.Tick(226, 225, true)
assert(value == -1 and not keep)
value, keep = TimerMath.Tick(100, 225, false)
assert(value == 100 and keep)
value, keep = TimerMath.Tick(226, 225, false)
assert(not keep)
value, keep = TimerMath.Tick(5000, 0, true)
assert(value == 5000 and keep)

assert(TimerMath.Format(0) == "0:00")
assert(TimerMath.Format(65) == "1:05")
assert(TimerMath.Format(225) == "3:45")

print("TimerMathTest ok")
