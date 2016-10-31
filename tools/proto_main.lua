package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;./?.lua"


local sparser = require "sprotoparser"
local sproto = require "sproto"
local type_map = {}
type_map["type_proto"] = require("type_proto")

local proto_map = {}
proto_map["login_proto"] = require("login_proto")
proto_map["game_proto"] = require("game_proto")

local proto_data = ""
for k,v in pairs(type_map) do
	proto_data = proto_data .. v
end

for k,v in pairs(proto_map) do
	proto_data = proto_data .. v.c2s
	proto_data = proto_data .. v.s2c
end

local proto = sparser.parse(proto_data)
--sproto.new(proto)
