local skynet = require "skynet"
local socket = require "socket"

local CMD = {}

function CMD.open(conf)
  print(debug.traceback())
  local host = conf.host or "0.0.0.0"
  local port = assert(tonumber(conf.port))
  local sock = socket.listen(host,port)
  socket.start(sock,function(fd,addr)
    print("client connect"..addr)
  end)
end


skynet.start (function ()
  skynet.dispatch ("lua",function(_,_,command,...)
     print("loginserver command ".. command)
     local f = assert(CMD[command])
     skynet.retpack (f(...))
  end)
end)