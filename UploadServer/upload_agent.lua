local skynet = require "skynet"
local socket = require "socket"
local sproto = require "sproto"
local Sproto = require "main_proto"
local sprotoloader = require "sprotoloader"
require("functions")
local client_fd
local REQUEST = {}
local CMD = {}
local gate
local host
local upload_master
local server_name
local ERROR = require("Errors")
local currVer = {0,0,0}
local endVer = ""
local urlMap = {}
local serverVerMap
function REQUEST:checkUpload()
   skynet.error("checkUpload")
   local ver = string.split(self.ver,".")
   local server_id = self.zoneID
   local currVer = currVer
   local endVer = endVer
   if server_id ~= 0 then
      if serverVerMap[server_id] ~= nil then
         currVer = serverMap[server_id].currVer
         endVer = servrMap[server_id].endVer
      else
         return {result = ERROR.ERROR}
      end
   end
   if #ver ~= 3 then
      return {result = ERROR.INVALID_VER}
   end
   if ver[1] == currVer[1] and ver[2] == currVer[2] and ver[3] == currVer[3] then
      return {bUpload = 0}
   end
   local bSmaller = false
   if ver[1] < currVer[1] then
      bSmaller = true
   elseif ver[1] > currVer[1] then
   else
      if ver[2] < currVer[2] then
         bSmaller = true
      elseif ver[2] > currVer[2] then
      else
         if ver[3] < currVer[3] then
            bSmaller = true
         end
      end
   end

   if bSmaller then
      local beginVer = string.gsub(self.ver,"%.","_")
      local url = "http://47.88.6.248/"..beginVer.."-"..endVer..".zip"
      skynet.error(url)
      return {result = 0,bUpdate = 1,sURL = url}
   else
      return {result = ERROR.INVALID_VER}
   end
end

local function request(name,args,response)
   skynet.error("request "..name)
   local f = assert(REQUEST[name])
   local r = f(args)
   if response then
      return response(r)
   end
end

local function send_package(pack)
   local package = string.pack(">s2",pack)
   socket.write(client_fd,package)
end

skynet.register_protocol {
   name = "client",
   id = skynet.PTYPE_CLIENT,
   unpack = function(msg,sz)
      return host:dispatch(msg,sz)
   end,
   dispatch = function(_,_,type,...)
      if type == "REQUEST" then
         local ok,result = pcall(request,...)
         if ok then
            if result then
               send_package(result)
            end
         end
      else
      end
   end

}

function CMD.start(config)
   local fd = config.client

   upload_sproto = sprotoloader.load(Sproto.UPLOAD_PROTO)
   host = upload_sproto:host "package"
   gate = config.gate
   client_fd = fd
   currVer = config.currVer
   endVer = config.endVer
   serverVerMap = config.serverVerMap
   skynet.call(gate,"lua","forward",fd)
end

function CMD.disconnect()
   skynet.exit()
end

skynet.start(function()
      skynet.dispatch("lua",function(_,_,command,...)
                         local f= CMD[command]
                         skynet.ret(skynet.pack(f(...)))
      end)
      server_name = skynet.getenv("server_name")
end)
