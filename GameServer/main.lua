local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
      skynet.uniqueservice("protoloader")

      local watchdog = skynet.newservice("watchdog")
      skynet.call(watchdog, "lua", "start", {
                     port = skynet.getenv("port"),
                     maxclient = max_client,
                     nodelay = true,
      })

      skynet.exit()
end)

