local skynet = require "skynet"
local players = {}
local npc = {}
local CMD = {}
function tick()
   skynet.timeout(100,tick)
end

function CMD.start(...)
      skynet.timeout(100,tick)
end

skynet.start(function()
      skynet.starttime()
end)
