local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
require("functions")

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd
local onlinePlayerMgr
local myPos = nil
local account

local function initPos()
  myPos = {}
  myPos.x = math.random(0,100)
  myPos.y = math.random(0,100)
  myPos.z = math.random(0,100)
  myPos.o = 0
  skynet.call(onlinePlayerMgr,"lua","playerMove",account,myPos)
end

function REQUEST:login()
  print("login",self.username,self.password)
  host = sprotoloader.load(3):host "package"
  send_request = host:attach(sprotoloader.load(4))
  account = skynet.call(onlinePlayerMgr,"lua","playerLogin")
  return {account = account}
end

function REQUEST:playersInfo()
 local playersInfo = skynet.call(onlinePlayerMgr,"lua","getPlayersInfo",account)
 return playersInfo
end

function REQUEST:move()
  skynet.call(onlinePlayerMgr,"lua","playerMove",account,self.pos)
  return {result = 1}
end

function REQUEST:myInfo()
 if myPos == nil then
   initPos()
 end

 return {pos = {x = myPos.x,y = myPos.y,z = myPos.z,o = myPos.o}} 
end

local function request(name, args, response)
    print("request "..name)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	onlinePlayerMgr = conf.mgr
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	--[[skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)]]

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.updatePlayerMove(playerAccount,pos)
  if account ~= playerAccount then
     send_request("playerMove",{pos = pos})
  end
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
