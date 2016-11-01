local skynet = require "skynet"
require "skynet.manager"
require "functions"
local CMD = {}
local SOCKET = {}
local gate
local agent = {}
local SERVER_NAME
local currVer = {0,0,0}
local serverVerMap = {}
local endVer = ""
local function close_agent(fd)
   local a = agent[fd]
   if a then
      skynet.call(gate,"lua","kick",fd)
      skynet.send(a,"lua","disconnect")
   end
end

function CMD.start(conf)
   skynet.call(gate,"lua","open",conf)
   local versionFile = io.open("/usr/local/nginx/html/version.txt","r")

   if versionFile then
      local ver = versionFile:read("*all")
      ver = string.gsub(ver,"\n","")
      currVer = string.split(ver,".")
      if #currVer ~=3 then
         skynet.error("version error")
         skynet.exit()
      end
      endVer = string.gsub(ver,"%.","_")
   end
end

function CMD.register(config)
   serverVerMap[config.id] = {}
   serverVerMap[config.id].currVer = string.split(config.currVer,".")
   serverVerMap[config.id].endVer = config.currVer
end

function CMD.close(fd)
   close_agent(fd)
end

function SOCKET.open(fd,addr)
   skynet.error("New client connect from :".. addr)
   agent[fd] = skynet.newservice("upload_agent")

   skynet.call(agent[fd],"lua","start",{gate = gate,client = fd,currVer = currVer,endVer = endVer,serverVerMap = serverVerMap})
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
