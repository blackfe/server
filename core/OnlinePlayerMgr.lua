local skynet = require "skynet"

local players = {}
local account = 1000000
local watchdog
local CMD = {}
function CMD.playerLogin(player)
  account = account + 1
  players[account] = {}
  return account
end

local function updatePlayerMove(account,pos)
  skynet.call()
end

function CMD.playerMove(account,pos)
  if players[account] == nil then
    return false
  end

  players[account].pos = pos
  skynet.call(watchdog,"lua","broadcast","updatePlayerMove",account,pos)
  return true
end

function CMD.getPlayersInfo(myAccount)
  local rt = {}
  for k,v in pairs(players) do
      if k ~= myAccount then
         table.insert({account = k,pos = v.pos})
      end
  end
  return rt
end

function CMD.start(parm)
  watchdog = parm.watchdog
end

skynet.start(function ()
  local self = skynet.self()
  skynet.dispatch("lua",function(_,source,command,...)
    local f = assert (CMD[command])
    skynet.retpack(f(source,...))
  end)
end)