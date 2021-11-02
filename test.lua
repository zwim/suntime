--[[ Test script for suntime.lua

Todo: usage
]]


local SunTime = require("suntime")

-- SunTime:setPosition("Casablanca", 33.58, -7.60, 1, 20, true)
-- SunTime:setPosition("Athene", 37.97, 23.73, 1, 50, true)
-- SunTime:setPosition("Rome", 41.91, 12.48, 1, 10, true)
-- SunTime:setPosition("Innsbruck Flughafen", 47.25786, 11.35111, 1, 578, true)
-- SunTime:setPosition("Berlin", 52.53387/180*math.pi, 13.37955/180*math.pi, 1, 100)
-- SunTime:setPosition("Oslo", 59.91853, 10.75567, 1, 0, true)
-- SunTime:setPosition("Reykjavik", 64.14381/180*math.pi, -21.92626/180*math.pi, 0, 10)
 SunTime:setPosition("Akureyri", 65.6872/180*math.pi, -18.08651/180*math.pi, 0, 0)
-- SunTime:setPosition("Hammerfest", 70.66588, 23.67893, 1, 0, true)
-- SunTime:setPosition("Nordpol", 90/180*math.pi, 11/180*math.pi, 1, 100)
-- SunTime:setPosition("Südpol", -89.4/180*math.pi, 50/180*math.pi, 1, 100)

--SunTime:setSimple()
SunTime:setAdvanced()

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

local function formatDate(y, m, d)
	return string.format("%04d-%02d-%02d", y, m, d)
end

local function round(x)
	if x > 0 then
		return math.floor(x + 0.5)
	else
		return math.floor(x - 0.5)
	end
end

--[[
--SunTime:setPosition("Berlin", 52.5/180*math.pi, 13.5/180*math.pi, 1) -- Berlin
--SunTime:setPosition("Akureyri", Rad(65.6872), Rad(18.08651), 1) -- Berlin
SunTime:setPosition("Kibi", 47.51581/180*math.pi, 12.08958/180*math.pi, 1) -- Kibi
--SunTime:setPosition("Innsbruck", 47.27/180*math.pi, 11.39/180*math.pi, 1) -- Innsbruck

SunTime:setAdvanced()
SunTime:setDate() -- today
--SunTime:setDate(2021,12,11, false, 12,00,00) -- test

print("\nadvanced calc")
SunTime:calculateTimes()

print("Position:      ", SunTime.name)
printTime("Astronomisch:  ", SunTime.rise_astronomic)
printTime("Nautisch:      ", SunTime.rise_nautic)
printTime("Civil:         ", SunTime.rise_civil)
printTime("Sonnenaufgang: ", SunTime.rise)

printTime("Mittag:        ", SunTime.noon)

printTime("Sonnenunterang:", SunTime.set)
printTime("Civil:         ", SunTime.set_civil)
printTime("Nautisch:      ", SunTime.set_nautic)
printTime("Astronomisch:  ", SunTime.set_astronomic)

printTime("Mitternacht:   ", SunTime.midnight)

print("\nsimple calc")

SunTime:setSimple()
SunTime:setDate() -- today
--SunTime:setDate(2021,12,11, false, 12,00,00) -- test

SunTime:calculateTimes()

print("Position:      ", SunTime.name)
printTime("Astronomisch:  ", SunTime.rise_astronomic)
printTime("Nautisch:      ", SunTime.rise_nautic)
printTime("Civil:         ", SunTime.rise_civil)
printTime("Sonnenaufgang: ", SunTime.rise)

printTime("Mittag:        ", SunTime.noon)

printTime("Sonnenunterang:", SunTime.set)
printTime("Civil:         ", SunTime.set_civil)
printTime("Nautisch:      ", SunTime.set_nautic)
printTime("Astronomisch:  ", SunTime.set_astronomic)

printTime("Mitternacht:   ", SunTime.midnight)
]]

local dom = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

if arg[1] and arg[2] and arg[3] then
	local yy, mm, dd = arg[1], arg[2], arg[3]
	SunTime:setDate(yy, mm, dd, false)
	SunTime.rise = SunTime:calculateTimeIter(SunTime.eod, 6)
	SunTime.set = SunTime:calculateTimeIter(SunTime.eod, 18)

	local a = math.floor(SunTime.rise)
	local b = math.floor((SunTime.rise - a)*60)
	local c = math.floor(SunTime.rise * 3600 + 1800) % 60

	local d = math.floor(SunTime.set)
	local e = math.floor((SunTime.set - d)*60)
	local f = math.floor(SunTime.set * 3600 + 1800) % 60

	print( dd .. "." .. mm .. "." .. yy .. "    " ..
		a .. ":" .. b .. ":" .. c .. "    " ..
		d .. ":" .. e .. ":" .. f)
else
	function os.capture(cmd, raw)
		local f = assert(io.popen(cmd, 'r'))
		local s = assert(f:read('*a'))
		f:close()
		if raw then
			return s
		end
		s = string.gsub(s, '^%s+', '')
		s = string.gsub(s, '%s+$', '')
		s = string.gsub(s, '[\n\r]+', ' ')
		return s
	end

	local rise_diff_sec = 0
	local set_diff_sec = 0
	for y = 2020, 2050 do
		for m = 1, 12 do
			for d = 1, dom[m] do
				local dst = false
				if m > 3 and m < 10 then --quick and dirty daylight saving time
--					dst = true
				end

				local tz = SunTime.time_zone
				if dst then
					tz = tz+1
				end

				local retval = os.capture("SPA/spa " .. SunTime.pos.latitude*180/math.pi .. " "
					.. SunTime.pos.longitude*180/math.pi .. " " ..SunTime.pos.altitude .. " "
					.. y .. " ".. m .. " " .. d .. " " .. tz .." " .. 1)
				retval = retval:gsub("-99999", "99")

				SunTime:setDate(y, m, d, dst)
				SunTime:calculateTimes()

				local tmp
				tmp = retval:sub(26,26+7)
				local spa_rise
				if not tmp:find("99") then
					spa_rise = tonumber(tmp:sub(1,2)) + tonumber(tmp:sub(4,5))/60
						+ tonumber(tmp:sub(7,8))/3600
				end
				tmp = retval:sub(43,43+7)
				local spa_set
				if not tmp:find("99") then
					spa_set = tonumber(tmp:sub(1,2)) + tonumber(tmp:sub(4,5))/60
						+ tonumber(tmp:sub(7,8))/3600
				end

				local diff_rise = 0
				if spa_rise and SunTime.rise then
					diff_rise = spa_rise - SunTime.rise
				end
				local diff_set = 0
				if spa_set and SunTime.set then
					diff_set = spa_set - SunTime.set
				end

				if spa_set < spa_rise then
					spa_set = spa_set + 24
				end

				if diff_rise then
					if diff_rise < -12 then
						diff_rise = diff_rise + 24
					elseif diff_rise > 12 then
						diff_rise = diff_rise - 24
					end
					tmp = math.abs(round(diff_rise * 3600))
					if tmp > rise_diff_sec then
						rise_diff_sec = tmp
					end
				end
				if diff_set then
					if diff_set < -12 then
						diff_set = diff_set + 24
					elseif diff_set > 12 then
						diff_set = diff_set - 24
					end
					tmp = math.abs(round(diff_set * 3600))
					if tmp > set_diff_sec then
						set_diff_sec = tmp
					end
				end

				if y == 2021 then
					-- times in fractions of a day
					print(retval, "SunTime: " .. formatDate(y, m, d) .." ",
						SunTime.rise and (timeHMS(SunTime.rise)),
						SunTime.set and (timeHMS(SunTime.set)),
						SunTime.noon and (timeHMS(SunTime.noon)),
						SunTime.midnight and (timeHMS(SunTime.midnight)),
						"Diff/sec: " .. round(diff_rise*3600) .. " " .. round(diff_set*3600))
				end
			end
		end
	end

	print("Maximum error for: " .. SunTime.pos.name .. " " .. round(rise_diff_sec) .. " " .. round(set_diff_sec))
end
