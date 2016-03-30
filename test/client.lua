package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../proto/?.lua"

if _VERSION ~= "Lua 5.3" then
   error "Use lua 5.3"
end

local socket = require "clientsocket"
local login_proto = require "login_proto"
local game_proto = require "game_proto"
local sparser = require "sprotoparser"
local sproto = require "sproto"


local fd = assert(socket.connect("127.0.0.1", 6254))
local host = sproto.new(login_proto.s2c):host("package")
local request = host:attach(sproto.new(login_proto.c2s))

local bLogin = false

local session = 0
local last = ""

local function send_package(fd,pack)
      local package = string.pack(">s2",pack)
      socket.send(fd,package)
end
local function send_request(name,args)
      session = session + 1
      local str = request(name,args,session)
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

local function print_request(name,args)
      print("REQUEST",name)
      if args then
         for k,v in pairs(args) do
             print(k,v)
         end
      end
end

local function deal_response(session,args)
      print("RESPONSE",session)
      if bLogin == false then
        bLogin = true
        host = sproto.new(game_proto.s2c):host("package")
        request = host:attach(sproto.new(game_proto.c2s))
      end
      if args then
         for k,v in pairs(args) do
             print(k,v)
         end
      end
end

local function deal_package(t,...)
  if t == "REQUEST" then
     print_request(...)
  else
    assert(t=="RESPONSE")
    deal_response(...)
  end
end

local function dispatch_package()
  while true do
    local v
    v,last = recv_package(last)
    if not v then
      break
    end
    deal_package(host:dispatch(v))
  end
end

while true do
      dispatch_package()
      local cmd = socket.readstdin()
      if cmd then
         
      else
        if bLogin == false then
           send_request("login",{username="blackfe",password="123456"})
        else
           send_request("playersInfo")
        end
        socket.usleep(1000000)
      end
end
