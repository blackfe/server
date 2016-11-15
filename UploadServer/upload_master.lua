local skynet = require "skynet"
require "skynet.manager"
require "functions"
local CMD = {}
local SOCKET = {}
local gate
local agent = {}
local SERVER_NAME
local serverVerMap = {}
local recommend_server
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

function CMD.register(config)
   serverVerMap[config.id] = {}
   serverVerMap[config.id].currVer = string.split(config.currVer,".")
   serverVerMap[config.id].currVerStr = string.gsub(config.currVer,"%.","_")
   if recommend_server == nil then
      recommend_server = serverVerMap[config.id]
   end
end

function CMD.close(fd)
   close_agent(fd)
end

function SOCKET.open(fd,addr)
   skynet.error("New client connect from :".. addr)
   agent[fd] = skynet.newservice("upload_agent")

   skynet.call(agent[fd],"lua","start",{gate = gate,client = fd,recommend_server = recommend_server,serverVerMap = serverVerMap})
end

function SOCKET.close(fd)
   close_agent(fd)
end

function SOCKET.error(fd,message)
   skynet.error("Client "..fd.." connect with errro:"..message)
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
      skynet.register("upload_master")
end)
