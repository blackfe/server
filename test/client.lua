package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../proto/?.lua"

if _VERSION ~= "Lua 5.3" then
   error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "login_proto"
local sparser = require "sprotoparser"
local sproto = require "sproto"


local fd = assert(socket.connect("127.0.0.1", 6254))
local host = sproto.new(proto.s2c):host("package")
local request = host:attach(sproto.new(proto.c2s))