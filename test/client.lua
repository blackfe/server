package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../common/proto/?.lua;../common/?.lua;../Utils/?.lua"

if _VERSION ~= "Lua 5.3" then
   error "Use lua 5.3"
end

require "functions"

local socket = require "clientsocket"
local sparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local crypt = require "crypt"
local Sproto = require "main_proto"

local fd
local sp
local host
local request

local session = 0
local last = ""
local bLogin = false
local bUpload = false
local RESPONSE = {}
local REQUEST = {}

local sessionCB = {}

local myPos
local otherPlayers

local clientkey
local secret
local server_ip = ""


local function send_package(fd,pack)
      local package = string.pack(">s2",pack)
      socket.send(fd,package)
end
local function send_request(name,args)
      session = session + 1
      if RESPONSE[name] == nil then
        --print("call back "..name.." not found")
      else
        sessionCB[session] = RESPONSE[name]
      end
      
      local str = request(name,args,session)
      print(str)
      send_package(fd,str)
end

local function unpack_package(text)
      local size = #text
      if size < 2 then
         return nil,text
      end
      local s = text:byte(1)* 256 + text:byte(2)
      if size < s + 2 then
         return nil,text
      end
      return text:sub(3,2+s),text:sub(3+s)
end

local function recv_package(last)
      local result
      result,last = unpack_package(last)
      if result then
         return result,last
      end
      local r = socket.recv(fd)
      if not r then
         return nil,last
      end
      if r == "" then
         error "Server closed"
      end

      return unpack_package(last .. r)
end

local function deal_request(name,args)
      print("REQUEST",name)
      if args then
        print(dump(args))
      end
end

local function deal_response(session,args)
      if args then
        print(dump(args))
      end

      if sessionCB[session] == nil then
        return
      end

      local f = sessionCB[session]
      f(args)
end

local function deal_package(t,...)
  if t == "REQUEST" then
     deal_request(...)
  else
    assert(t=="RESPONSE")
    deal_response(...)
  end
end

local function dispatch_package()
  while true do
    local v
    if fd then
        v,last = recv_package(last)
    end
    if not v then
      break
    end
    deal_package(host:dispatch(v))
  end
end


function RESPONSE:playersInfo()
  local bFound = false
  for i,v in ipairs(self.player) do
    local otherPlayer
    if otherPlayers[v.account] == nil then
      otherPlayer = {}
      otherPlayers[v.account] = otherPlayer
    end

    otherPlayer.pos = v.pos
  end
end

function REQUEST:playerMove()
  print("player "..self.account.." move to "..self.pos.x.." "..self.pos.y.." "..self.pos.z)
end

function RESPONSE:move()
end

function RESPONSE:myInfo()
  myPos = self.pos
end

local function verify_token(token)
  return string.format("%s:%s",
                       crypt.base64encode(token.user),
                       crypt.base64encode(token.password))
end

function RESPONSE:getSecret()
  local serverkey = crypt.base64decode(self.serverkey)

  local challenge = crypt.base64decode(self.challenge)
  secret = crypt.dhsecret(serverkey, clientkey)
  local hmac = crypt.hmac64(challenge,secret)
  local token = crypt.base64encode(crypt.desencode(secret,verify_token({user = "blackfe"..math.random(100),password = "62544872"})))
  send_request("verify",{hmac = crypt.base64encode(hmac), token = token})
end

local function encode_token(token)
  local str = string.format("%s:%s",
                       crypt.base64encode(token.accountID),
                       crypt.base64encode(token.server))
  print("str ".. str)
  return str
end


function RESPONSE:verify()
  if self.result ~= 0  then
    print("login failed")
    exit()
  end
  local randomIndex = math.random(#self.zones)
  local server = self.zones[randomIndex].name
  server_ip = self.zones[randomIndex].ip
  print(dump(self))
  local etoken = crypt.base64encode(crypt.desencode(secret,encode_token({accountID = tostring(self.accountID), server = server})))
  print(dump(etoken))
  send_request("login",{etoken = etoken})
end

function RESPONSE:checkUpload()
  bUpload = true
  socket.close(fd)
  fd = nil
end

function RESPONSE:login()
  bLogin = true
  sp = sprotoloader.load(Sproto.GAME_PROTO)
    host = sp:host("package")
    request = host:attach(sp)
    socket.close(fd)
    os.exit()
    print(dump(server_ip))
    local _ip = string.split(server_ip,":")
    fd = assert(socket.connect(_ip[1], tonumber(_ip[2])))

end


function move()
  print("move")
  if myPos ~= nil then
    local offset = {}
    offset.x = math.random(0,10)
    offset.y = math.random(0,10)
    offset.z = math.random(0,10)
    offset.o = math.random(0,10)
    myPos.x = myPos.x + offset.x
    myPos.y = myPos.y + offset.y
    myPos.z = myPos.z + offset.z
    myPos.o = myPos.o + offset.o
    send_request("move",{pos = myPos})
  end
end

local count = 0

function start_upload()
  if fd then
    return
  end

  fd = assert(socket.connect("47.88.6.248",8002))
  sp = sprotoloader.load(Sproto.UPLOAD_PROTO)
  host = sp:host("package")
  request = host:attach(sp)
  send_request("checkUpload",{zoneID = 1001,ver = "0.0.1"})
end

function start_login()
  if fd then
    socket.close(fd)
    fd = nil
  end
  fd = assert(socket.connect("47.88.6.248", 8001))
  sp = sprotoloader.load(Sproto.LOGIN_PROTO)
  host = sp:host("package")
  request = host:attach(sp)

  clientkey = crypt.randomkey()
  send_request("getSecret",{clientkey = crypt.base64encode(crypt.dhexchange(clientkey))})
end

math.randomseed(os.clock())

while true do
  local cmd
  if fd then
      dispatch_package()
  end

  if bUpload == false then
    start_upload()
  elseif bLogin == false then
    start_login()
    bLogin = true
  else

  end
  socket.usleep(10)
end
