require('FS2012')
FS2012.init()

readTimer = tmr.create()
readTimer:register(100, tmr.ALARM_AUTO, function() 
	print(FS2012.read()) 
end)
readTimer:start()