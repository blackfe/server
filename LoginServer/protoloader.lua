-- module proto as examples/proto.lua

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto = require "login_proto"
skynet.start(function()
	sprotoloader.save(proto.c2s, 1)
    sprotoloader.save(proto.s2c, 2)
end)
