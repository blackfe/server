-- module proto as examples/proto.lua

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto2 = require "game_proto"
local proto3 = require "player_info_proto"
skynet.start(function()
    sprotoloader.save(proto2.c2s,1)
    sprotoloader.save(proto2.s2c,2)
    sprotoloader.save(proto3.player_info,3)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
