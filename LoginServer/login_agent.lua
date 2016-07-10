local skynet = require "skynet"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
require("functions")
local crypt = require "crypt"
local client_fd
local REQUEST = {}
local CMD = {}
local host
local login_sproto
local login_master
local server_name
local challenge
local secret
local ERROR = require("Errors")

local server_list = {}

function REQUEST:getSecret()
   challenge = crypt.randomkey()
   local clientkey = crypt.base64decode(self.clientkey)
   local serverkey = crypt.randomkey()
   secret = crypt.dhsecret(clientkey,serverkey)
   return {serverkey = crypt.base64encode(crypt.dhexchange(serverkey)),challenge = crypt.base64encode(challenge)}
end

function REQUEST:verify()
   local client_hmac = crypt.base64decode(self.hmac)
   if client_hmac ~= crypt.hmac64(challenge,secret) then
      return {result = ERROR.VERIFY_FAILED }
   end

   local token = crypt.desdecode(secret,crypt.base64decode(self.token))
   local user,password = token:match("([^@]+):(.+)")
   user = crypt.base64decode(user)
   password = crypt.base64decode(password)
   local user_data = skynet.call("GAMESQL","lua","get",server_name,{username=user})
   local accountID = nil
   if #user_data == 0 then
      accountID = skynet.call(login_master,"lua","newAccountID")
      skynet.call("GAMESQL","lua","add",server_name,{username = user,password = password,accountID = accountID})
   else
      if user_data[1].password ~= password then
         return {result = ERROR.ERROR_PASSWORD}
      end
      accountID = user_data[1].accountID
   end

   local zones = {}
   for k,v in pairs(server_list) do
      table.insert(zones,v)
   end

   local roles = {}
   if user_data.rolesInfo ~= nil then
      roles = login_sproto:decode("RoleInfo")
   end

   return {result = ERROR.SUCCESS,accountID = accountID, zones = zones, roles = roles}
end

function REQUEST:login()
   skynet.error(dump(self))
   local etoken = crypt.desdecode(secret,crypt.base64decode(self.etoken))
   skynet.error(etoken)
   local accountID,server = etoken:match("([^@]+):(.+)")
   accountID = crypt.base64decode(accountID)
   server = crypt.base64decode(server)
   local s = server_list[server]
   skynet.error(accountID)
   if s ~= nil then
      local token = skynet.call(s.addr,"lua","login",{accountID = accountID})
      return {result = ERROR.SUCCESS,token = token}
   else
      return {result = ERROR.ERROR}
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
         if ok  then
            if result then
               send_package(result)
            end
         else
            skynet.error(result)
         end
      else

      end
   end

}

function CMD.start(config)
   skynet.error(dump(config))
   local fd = config.client
   local gate = config.gate
   login_master = config.watchdog

   server_list = config.server_list
   login_sproto = sprotoloader.load(1)
   host = login_sproto:host "package"
   client_fd = fd
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
