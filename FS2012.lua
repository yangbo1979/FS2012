-- ***************************************************************************
-- FS2012 module for ESP8266 with nodeMCU
--
-- Written by yangbo
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************


--[[
require('FS2012')
sda = 1
scl = 2
spd = i2c.SLOW
FS2012.init(sda,scl,spd)
readTimer = tmr.create()
readTimer:register(100, tmr.ALARM_AUTO, function() print(FS2012.read()) end)
readTimer:start()
]]--

local moduleName = 'FS2012'
local M = {}
_G[moduleName] = M

--I2C slave address of FS2012
local FS2012_ADDR = 0x07

id  = 0
sda = 1
scl = 2
spd = i2c.SLOW

function M.init(sdaPin,sclPin,spd)
     -- initialize i2c, set pin1 as sda, set pin2 as scl
     sda = sdaPin or sda
     scl = sclPin or scl
     spd = i2c.SLOW or spd
     i2c.setup(id, sda, scl, i2c.SLOW)
end
-- user defined function: read from reg_addr content of dev_addr
function read_reg(dev_addr)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    c = i2c.read(id, 2)
    val = string.byte(c,1)*256 + string.byte(c,2)
    i2c.stop(id)
    return val
end

function M.read()
     reg = read_reg(FS2012_ADDR)
     return reg/100
end
return M
