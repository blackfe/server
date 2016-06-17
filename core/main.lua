local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
	print("Server start")
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
    skynet.uniqueservice("gamesql")
    local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
        port = 6254,
		maxclient = max_client,
		nodelay = true,
    })

	skynet.exit()
end)
