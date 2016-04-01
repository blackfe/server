local skynet = require "skynet"
local socket = require "socket"
local sproto = require "sproto"
local proto = require "login_proto"
local CMD = {}
local host
local request
local REQUEST = {}

function REQUEST:login()
  print("login",self.username,self.password)  
end

function CMD.open(conf)
  print(debug.traceback())
  local host = conf.host or "0.0.0.0"
  local port = assert(tonumber(conf.port))
  local sock = socket.listen(host,port)
  socket.start(sock,function(fd,addr)
    print("client connect"..addr)
  end)
end



local function request(name,args,response)
  local f = assert(REQUEST[name])
  local r = f(args)
  if response then
    return response(r)
  end
end

skynet.register_protocol {
  name = "client",
  id = skynet.PTYPE_CLIENT,
  unpack = function(msg,sz)
    print(msg)
    return host:dispatch(msg,sz)
  end,
  dispatch = function(_,_,type,...)
    print(debug.traceback())
    if type == "REQUEST" then
      local ok,result = pcall(request,...)
      if ok then
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

skynet.start (function ()
  host = sproto.new(proto.s2c):host("package")
  request = host:attach(sproto.new(proto.c2s))
  skynet.dispatch ("lua",function(_,_,command,...)
     print("loginserver command ".. command)
     local f = assert(CMD[command])
     skynet.retpack (f(...))
  end)
end)