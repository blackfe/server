local skynet = require "skynet"
local netpack = require "netpack"
local crypt = require "crypt"
require "functions"
require "TableLoader"
local CMD = {}
local SOCKET = {}
local gate
local agent = {}
local onlinePlayerMgr 
local accountTokenMap = {}
local server_name
local server_id

function SOCKET.open(fd, addr)
	skynet.error("New client from : " .. addr)
	agent[fd] = skynet.newservice("agent")
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self(), mgr = onlinePlayerMgr })
end

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

function CMD.broadcast(name,...)
  for k,v in pairs(agent) do
    skynet.call(v,"lua",name,...)
  end
end

function CMD.login(data)
	local accountID = data.accountID
	local user_data = skynet.call("GAMESQL","lua","get",server_name,{accountID = accountID})

	local token = crypt.randomkey()

	if accountTokenMap[accountID] == nil then
		accountTokenMap[accountID] = {}
	end
	accountTokenMap[accountID].token = token
	if #user_data == 0 then
		skynet.call("GAMESQL","lua","add",server_name,{accountID = accountID})
		accountTokenMap[accountID].data = {}
	else
		accountTokenMap[accountID].data = user_data[1]
	end

	return token
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
	    print("session "..session.."source "..source.."cmd "..cmd)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	server_id = skynet.getenv("server_id")
	server_name = Table.ServerList.get(server_id).sName
	gate = skynet.newservice("gate")
	onlinePlayerMgr = skynet.newservice("OnlinePlayerMgr")
	skynet.call(onlinePlayerMgr,"lua","start",{watchdog = skynet.self()})
	skynet.call("login_master","lua","register",{id = server_id,name = server_name,ip = "127.0.0.1:"..skynet.getenv("port"),addr = skynet.self()})
	require "config"
	skynet.call("upload_master","lua","register",{id = server_id,currVer = LUA_VERSION})
	skynet.call("GAMESQL","lua","register",server_name)
end)
