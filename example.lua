--- An example to calculate times for Innsbruck
-- usage: lua example yy mm dd dst
-- example lua example 2022 05 21 true

local SunTime = require("suntime")

local yy, mm, dd, dst = arg[1], arg[2], arg[3], arg[4]

if not yy or not mm or not dd or not dst then
	print("usage: suntime yy mm dd dst")
	return
end

if dst == "true" then
	dst = true
end

SunTime:setPosition("Innsbruck Flughafen", 47.25786, 11.35111, 1, 578, true)

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

local dom = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

if arg[1] and arg[2] and arg[3] then
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
					dst = true
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

--				if spa_set < spa_rise then
--					spa_set = spa_set + 24
--				end

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

				if y == 2021 and not arg[1] then
					-- times in fractions of a day
					print(retval, "SunTime: " .. formatDate(y, m, d) .." ",
						SunTime.rise and (timeHMS(SunTime.rise)),
						SunTime.set and (timeHMS(SunTime.set)),
						SunTime.noon and (timeHMS(SunTime.noon)),
						SunTime.noon and SunTime:getHeight(SunTime.noon)*180/math.pi,
						SunTime.midnight and (timeHMS(SunTime.midnight)),
						SunTime.midnight and SunTime:getHeight(SunTime.midnight)*180/math.pi,
						"Diff/sec: " .. round(diff_rise*3600) .. " " .. round(diff_set*3600))
				end
			end
		end
	end

end
