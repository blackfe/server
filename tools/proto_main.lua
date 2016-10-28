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
	proto_data = proto_data .. v
end

local proto = sparser.parser proto_data
sproto.new(proto)