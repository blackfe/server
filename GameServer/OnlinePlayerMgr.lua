local skynet = require "skynet"

local players = {}
local account = 1000000
local watchdog
local gamesql = "GAMESQL"
local CMD = {}
function CMD.playerLogin(...)
  account = account + 1
  local accountInfo = skynet.call(gamesql,"lua","get_account_info",...)
  players[account] = accountInfo
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
    skynet.ret(skynet.pack(f(...)))
  end)
end)
