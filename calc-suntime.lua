-- usage: lua example yy mm dd tz dst latitude longidute altitude
-- example lua example 2022 05 21 +1 true 47.51 12.09 520

-- may be used with  `date +"%Y %m %d %:z"`

local SunTime = require("suntime")

local yy, mm, dd, tz, dst, lat, long, alt = arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8]

lat = lat or 47.55
long = long or 12.12
alt = alt or 500
tz = tz or ""

-- when called from commandline tz is a string,
-- when called form C tz is a double
if type(tz) == "string" then
	local tz_pos = tz:find(":")
	if tz_pos then
		tz = tonumber(tz:sub(1, tz_pos-1) + tonumber(tz:sub(tz_pos+1) / 60))
	else
		tz = tonumber(tz)
	end
end

print(yy, mm, dd, tz, dst, lat, long, alt)

if not yy or not mm or not dd or not dst or not tz then
	print("usage: lua calc-suntime yy mm dd dst timezone latitude longitude altitude")
    print("       lua calc-suntime $(date +\"%Y %m %d %:z\") true")
	return
end

dst = dst == "true" and true or false

SunTime:setPosition("Hotpot", lat, long, tz, alt, true)

--SunTime:setSimple()
SunTime:setAdvanced()

SunTime:setDate(yy, mm, dd, dst)
SunTime:calculateTimes()

local function timeHMS(time)
	if time then
		local h = math.floor(time)
		local m = math.floor((time - h) * 60)
		local s = math.floor(time*3600-h*3600-m*60)
		return string.format("%02d",h) .. ":"
			.. string.format("%02d",m) .. ":"
			.. string.format("%02d",s)
	else
		return "none"
	end
end

local function formatDate(y, m, d, dst)
	return string.format("Date: %04d-%02d-%02d", y, m, d) .. "\ndaylight saving time: " .. tostring(dst)
end

print("Calculate sun times for", SunTime.pos.name)
print(formatDate(yy, mm, dd, dst))
print("Solar midnight:   " .. timeHMS(SunTime.midnight_beginning))
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
print("Solar midnight:   " .. timeHMS(SunTime.midnight))

return SunTime.times -- so that we can read that in C