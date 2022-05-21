--- An example to calculate times for Innsbruck
-- usage: lua example yy mm dd dst
-- example lua example 2022 05 21 true

local SunTime = require("suntime")

local yy, mm, dd, dst = arg[1], arg[2], arg[3], arg[4]

if not yy or not mm or not dd or not dst then
	print("usage: suntime yy mm dd dst")
	print("  yy .. the year")
	print("  mm .. the month")
	print("  dd .. the day")
	print("  dst .. true if daylight saving time is true")
	return
end

if dst == "true" then
	dst = true
else
	dst = nil
end

SunTime:setPosition("Innsbruck Flughafen", 47.25786, 11.35111, 1, 578, true)

--SunTime:setSimple()
SunTime:setAdvanced()

local function timeHMS(time)
	if time then
		local h = math.floor(time)
		local m = math.floor((time - h) * 60)
		local s = math.floor(time*3600-h*3600-m*60)
		return string.format("%02d:%02d:%02d", h, m, s)
	else
		return "none"
	end
end

SunTime:setPosition("Innsbruck Flughafen", 47.25786, 11.35111, 1, 578, true)
SunTime:setDate(yy, mm, dd, dst)
SunTime:calculateTimes()

print("Calculate sun times for", SunTime.pos.name)
print(string.format("Date: %04d-%02d-%02d", yy, mm, dd))
print("Solar midnight:   " .. timeHMS(SunTime.midnight))
print("Begin of:")
print("    Astron. dawn: " .. timeHMS(SunTime.rise_astronomic))
print("    Nautic dawn:  " .. timeHMS(SunTime.rise_nautic))
print("    Civil dawn:   " .. timeHMS(SunTime.rise_civil))
print("Sun rise:         " .. timeHMS(SunTime.rise))
print("Solar noon:       " .. timeHMS(SunTime.noon))
print("Sun set:          " .. timeHMS(SunTime.set))
print("begin of tusk:")
print("    Civil tusk:   " .. timeHMS(SunTime.set_civil))
print("    Nautic tusk:  " .. timeHMS(SunTime.set_nautic))
print("    Astron. tusk: " .. timeHMS(SunTime.set_astronomic))

