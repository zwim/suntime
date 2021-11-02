# Suntime

Calculates ephemeris and different types of twilight depending on your geolocation.

## Usage

See `test.lua` for an example.

1.) Set your position:

` SunTime:setPosition(name, latitude/180*math.pi, longitude/180*math.pi, timezone, height)`

` SunTime:setPosition("Innsbruck Flughafen", 47.25786/180*math.pi, 11.35111/180*math.pi, 1, 578)`

2.) Set equation of time

`SunTime:setSimple() -- simple version valid for 2008-2027`

`SunTime:setAdvanced() -- advanced version valid for the next few hundred years`

3.) Set date

`SunTime:setDate(y, m, d, dst)`

`SunTime:setDate(2021, 10, 30, true)`

4.) Calulate times

`SunTime:calculateTimes()`

5.) Use the calculated times

Times are decimal hours, so `12.5` is `12:30:00`. If a time does not exist the value is `nil`.

```
    self.rise
    self.set 

    self.rise_civil 
    self.set_civil 
    self.rise_nautic
    self.set_nautic 
    self.rise_astronomic 
    self.set_astronomic

    self.noon 
    self.midnight

    self.times = {}
    self.times[1]  = self.midnight and (self.midnight - 24)
    self.times[2]  = self.rise_astronomic
    self.times[3]  = self.rise_nautic
    self.times[4]  = self.rise_civil
    self.times[5]  = self.rise
    self.times[6]  = self.noon
    self.times[7]  = self.set
    self.times[8]  = self.set_civil
    self.times[9]  = self.set_nautic
    self.times[10] = self.set_astronomic
    self.times[11] = self.midnight
```