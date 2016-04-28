local sparser = require "sprotoparser"

local player_proto = {}
local player_info = [[
.Base {
  hp 0 : integer
  level 1 : integer
}
]]

player_proto.player_info = sparser.parse(player_info)
