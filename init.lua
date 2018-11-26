tmr.alarm(0,1000,0,function()
     dofile('test.lua')
end)

bBeep = false
bEnableBeep = false
bPin = 3
gpio.mode(bPin,gpio.OUTPUT)
tmr.alarm(1,2000,1,function()
     if(bEnableBeep) then 
          if(bBeep)then gpio.write(bPin,gpio.HIGH)
          else gpio.write(bPin,gpio.LOW)
          end
          bBeep = not bBeep
     else
          gpio.write(bPin,gpio.LOW)
     end
end)