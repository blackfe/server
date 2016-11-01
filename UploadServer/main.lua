local skynet = require "skynet"
require("skynet.manager")
skynet.start(function()
      local uploadserver = skynet.newservice("upload_master")
      skynet.call(uploadserver,"lua","start",{
                     address = "47.88.6.248",
                     port = 8002
      })
end)
