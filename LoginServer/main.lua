local skynet = require "skynet"
require("skynet.manager")
skynet.start(function()
      skynet.uniqueservice("protoloader")
      local loginserver = skynet.newservice("login_master")
      skynet.call(loginserver,"lua","start",{
                     port = 8001
      })
end)
