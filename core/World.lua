local skynet = require "skynet"
local players = {}
local robs = {}
local MAX_ROB_COUNT = 8
local CMD = {}

function _tempData()
   return {
      hp = 1 ,
      level = 1,
      skillList = {
         [1]={
            id=100001,
            level=1
         }
      }
   }
end

function initRobots()
   for i = 1,MAX_ROB_COUNT do
      local _temp = _tempData()
      robs[i] = _temp
   end
end

function CMD.enterWorld(agent)
   local _temp  = {}
   for k,v in pairs(players) do
      _temp[k] = v
   end
   for k,v in pairs(players) do
      _temp[k] = v
   end
   skynet.call(agent,"createObjects",_temp)
   table.insert(players,agent)
end

function CMD.leaveWorld(agent)
   for i,v in ipairs(players) do
      if v == agent then
         table.remove(players,i)
         return
      end
   end
end

function CMD.sendMsg(agent,dataStr)
   for i,v in ipairs(players) do
      if v ~= agent then
         skynet.call(v,"lua","sendMsg",dataStr)
      end
   end
end

skynet.start(function()
      local self = skynet.self()
      initRobots()
      skynet.dispatch("lua",function(_,source,command,...)
          local f = CMD[command]
          skynet.ret(skynet.pack(f(source,...)))
      end)
end)
