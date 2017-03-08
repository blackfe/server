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
local currVerStr = ""
local urlMap = {}
local serverVerMap
local recommend_server
local localFilePath = "/home/game_res/"
local httpPath = "http://47.88.6.248/"
local fileExistsCache = {}
local function checkFileExists(fullPath)
   skynet.error("checkFileExists:"..fullPath)
   if fileExistsCache[fullPath] == true then
      return true
   end

   local file = io.open(fullPath,"rb")
   if file then
      file:close()
      fileExistsCache[fullPath] = true
      return true
   end
   return false
end

function REQUEST:checkUpload()
   skynet.error("checkUpload")
   local ver = string.split(self.ver,".")
   local server_id = self.lastZoneID
   local currVer = currVer
   local currVerStr = currVerStr
   local _server


   if server_id ~= nil and serverVerMap[server_id] ~= nil then
      _server = serverVerMap[server_id]
   else
      _server = recommend_server
   end


   skynet.error(dump(_server))
   currVer = _server.currVer
   currVerStr = _server.currVerStr


   if #ver ~= 3 then
      return {result = ERROR.INVALID_VER}
   end
   if ver[1] == currVer[1] and ver[2] == currVer[2] and ver[3] == currVer[3] then
      return {bUpload = 0}
   end

   skynet.error("start check")
   local bSmaller = false
   local bForceUpdate = false
   if ver[1] < currVer[1] then
      bSmaller = true
   elseif ver[1] > currVer[1] then
      bForceUpdate = true
   else
      if ver[2] < currVer[2] then
         bSmaller = true
      elseif ver[2] > currVer[2] then
         bForceUpdate = true
      else
         if ver[3] < currVer[3] then
            bSmaller = true
         end
      end
   end

   if bSmaller then
      skynet.error("bSmaller")
      local beginVer = string.gsub(self.ver,"%.","_")
      local fileName = beginVer.."-"..currVerStr..".zip"

      if checkFileExists(localFilePath..fileName) then
         local url = httpPath..fileName
         return {result = 0,updateType = 1,sURL = url}
      else
         bForceUpdate = true
      end
   end

   if bForceUpdate then
      skynet.error("bForceUpdate")
      local fileName = currVerStr .. ".zip"
      if checkFileExists(localFilePath..fileName) then
         local url = httpPath .. fileName
         return {result = 0,updateType = 2,sURL = url}
      end
   end

   return {result = ERROR.INVALID_VER}
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
   serverVerMap = config.serverVerMap
   recommend_server = config.recommend_server
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
