require('FS2012')
ntpSvrList = {"ntp1.aliyun.com","ntp2.aliyun.com","ntp3.aliyun.com"}
timeSec,offsetTime = nil
function syncTime(svrId)
     print(ntpSvrList[svrId])
     sntp.sync(ntpSvrList[svrId],
       function(sec, usec, server, info)
         print('sync', sec, usec, server)
         timeSec = sec
         offsetTime = tmr.time()
         require('mqttClient')
       end,
       function()
        print('try another:')
        syncTime((svrId+1)%3+1)
       end
     )
end

function sPrint(str)
     print(str)
end

FS2012.init()







 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 syncTime(1)
 end)
wifi.setmode(wifi.STATION)
station_cfg={}
require("wificonfig")
wifi.sta.config(station_cfg)
