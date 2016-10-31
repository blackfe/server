local skynet = require "skynet"
local function tick()
   skynet.error("tick"..skynet.time())
   skynet.timeout(100,tick)
end

local battleAgents = {}
local CMD = {}
function CMD.newBattle(...)
   local agent = skynet.newservice("AIAgent",...)
   table.insert(battleAgents,agent)
end

skynet.start(function()
      SERVER_NAME = skynet.getenv("server_name")
      skynet.dispatch("lua",function(session,source,cmd,...)
                         local f = assert(CMD[cmd])
                         skynet.ret(skynet.pack(f(...)))

      end)
      skynet.starttime()
      skynet.timeout(100,tick)
end)
