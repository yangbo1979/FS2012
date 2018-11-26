serverIp = 'www.breadboard.com.cn'--'192.168.0.5'--
serverPort = 1883
mac = string.gsub(wifi.sta.getmac(), ":", "")
reconnectInterval = 5000
--local regReqTopic = "/regReq"
local fsValTopic = "/breathMon:"..mac
local fsOnlineTopic = "/devOnlineMonitor:"..mac
local fsValStr = ""
print(fsValTopic)
local mqttInst = nil
local stpCount = 0

pubTimer = tmr.create()
pubTimer:register(1000, tmr.ALARM_AUTO, function() 
     --print(timeSec+tmr.time()-offsetTime)
     if(mqttInst) then
          publishFSVal(timeSec+tmr.time()-offsetTime..fsValStr)
          fsValStr = ""
     end
end)



readTimer = tmr.create()
readTimer:register(200, tmr.ALARM_AUTO, function()
     fsVal = FS2012.read()
     if(fsVal<=0.2) then 
          fsVal = 0 
          stpCount = stpCount + 1
          if(stpCount > 75 )then 
               bEnableBeep=true
          else 
               bEnableBeep=false
          end
     else
          stpCount = 0
     end
     if(fsVal<655.35) then
          fsValStr = fsValStr ..","..fsVal
     end
end)
--readTimer:start()

-- init mqtt client without logins, keepalive timer 120s
--m = mqtt.Client("bbClient_test", 120)

-- init mqtt client with logins, keepalive timer 120sec
if(m==nil) then 
m = mqtt.Client(mac, 120, "breathMonitor", "bradw@#ad2")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) 
     if(tmr.state(1)==nil)then 
          tmr.alarm(1, reconnectInterval, 0, function()
               dofile('mqttClient.lua')
          end)
     end
     sPrint ("offline")
     pubTimer:stop() 
end)

-- on publish message receive event
m:on("message", function(client, topic, data) 
  sPrint(topic .. ":" ) 
  if(topic == fsOnlineTopic) then
     if(data == '?') then
          client:publish(fsOnlineTopic, 1, 0, 0, function(client) print("dev pub online") end)
     end
  end
  --[[
  if data ~= nil then
     print(data)
     
     if(topic == regAnsTopic) then
          if(string.len(data)==20)then
               --got sn
               if(file.open(configSnFile, "w")) then
                    file.writeline('sn="'..data..'"')
                    file.close()
                    node.restart()
               end
          else
               if(data == '-1') then
                    --not binding
                    sPrint("not binding")
               elseif(data == '1') then
                    --binded
                    sPrint("binded")
               end
          end
     elseif(topic == '/PLOTTER_'..sn) then
          print('plotter data')
     end--topic
  end--data~=nil
  ]]--
  
end)

end
-- for TLS: m:connect("192.168.11.118", secure-port, 1)
m:connect(serverIp, serverPort, 0, function(client)
     sPrint("connected")
     mqttInst = client
     pubTimer:start()
     readTimer:start()
     -- Calling subscribe/publish only makes sense once the connection
     -- was successfully established. You can do that either here in the
     -- 'connect' callback or you need to otherwise make sure the
     -- connection was established (e.g. tracking connection status or in
     -- m:on("connect", function)).
     
     -- subscribe topic with qos = 0

     --[[
     subTopics = {[regAnsTopic]=1}
     if(sn~=nil)then
          subTopics['/PLOTTER_'..sn]=1
     end
     client:subscribe(subTopics, function(client)
          sPrint("subscribe success:")
          client:publish(regReqTopic, mac, 0, 0, function(client) print("sent") end)
     end)
     ]]--

     
     subTopics = {[fsOnlineTopic]=1}
     client:subscribe(subTopics, function(client)
          sPrint("subscribe success:")
          client:publish(fsOnlineTopic, 1, 0, 0, function(client) print("dev pub online") end)
     end)
     
     -- publish a message with data = hello, QoS = 0, retain = 0
     
     --tmr.alarm(2, 5000, 1, function()
     --end)
     end,
     function(client, reason)
     sPrint("failed reason: " .. reason)
     if(tmr.state(1)==nil)then 
          tmr.alarm(1, reconnectInterval, 0, function()
               dofile('mqttClient.lua')
          end)
     end
end)

function publishFSVal(v)
     print(v)
     mqttInst:publish(fsValTopic, v, 0, 0, function(client) print("sent") end)
end

--m:close();
