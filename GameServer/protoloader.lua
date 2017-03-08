-- module proto as examples/proto.lua

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
skynet.start(function()
      require "main_proto"
end)
