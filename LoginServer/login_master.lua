local skynet = require "skynet"
require "skynet.manager"
require "functions"
local gate
local CMD = {}
local SOCKET = {}
local agent = {}
local SERVER_NAME
local server_list = {}
local max_account = 0
local function close_agent(fd)
   local a = agent[fd]
   if a then
      skynet.call(gate,"lua","kick",fd)
      skynet.send(a,"lua","disconnect")
   end
end

function CMD.start(conf)
   skynet.call(gate,"lua","open",conf)
end

function CMD.close(fd)
   close_agent(fd)
end

function CMD.newAccountID()
   max_account = max_account + 1
   skynet.call("GAMESQL","lua","set","server_state",{count = max_account},{servername = SERVER_NAME})
   return max_account
end

function CMD.register(server)
   skynet.error("game server "..server.name.." regist")
   server_list[server.id] = server
end

function SOCKET.open(fd,addr)
   skynet.error("New client login from :".. addr)
   agent[fd] = skynet.newservice("login_agent")

   skynet.call(agent[fd],"lua","start",{gate = gate,client = fd,watchdog = skynet.self(),server_list = server_list})
end

function SOCKET.close(fd)
   close_agent(fd)
end

function SOCKET.error(fd,message)
   skynet.error("Client "..fd.." login with errro:"..message)
   close_agent(fd)
end

function SOCKET.warning(fd,size)

end

function SOCKET.data(fd,size)
end



skynet.start(function()
      SERVER_NAME = skynet.getenv("server_name")
      skynet.dispatch("lua",function(session,source,cmd,subcmd,...)
                         if cmd == "socket" then
                            local f = SOCKET[subcmd]
                            if f then
                               f(...)
                            end
                         else
                            local f = CMD[cmd]
                            skynet.ret(skynet.pack(f(subcmd,...)))
                         end

      end)
      gate = skynet.newservice("gate")
      skynet.register("login_master")
      skynet.call("GAMESQL","lua","register",SERVER_NAME)
      skynet.error("123")
      local data = skynet.call("GAMESQL","lua","get","server_state",{servername = SERVER_NAME})
      max_account = data.count or 0
end)
