require "functions"
local skynet = require "skynet"

skynet.start(function()
    local loginsvr = skynet.newservice("loginserver")
    local addr = skynet.getenv("address")
    local addrTable = string.split(addr,":")
    assert(#addrTable==2)
    skynet.call(loginsvr,"lua","open",{host=addrTable[1],port=addrTable[2]})
end)