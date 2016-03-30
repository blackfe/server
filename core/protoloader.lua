-- module proto as examples/proto.lua
package.path = "./examples/?.lua;" .. package.path

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto = require "login_proto"
local proto2 = require "game_proto"
skynet.start(function()
	sprotoloader.save(proto.c2s, 1)
	sprotoloader.save(proto.s2c, 2)
	sprotoloader.save(proto2.c2s,3)
	sprotoloader.save(proto2.s2c,4)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
