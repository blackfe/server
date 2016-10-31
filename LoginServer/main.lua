local skynet = require "skynet"
require("skynet.manager")
skynet.start(function()
      local loginserver = skynet.newservice("login_master")
      skynet.call(loginserver,"lua","start",{
                     address = "47.88.6.248",
                     port = 8001
      })
end)
