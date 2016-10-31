local sparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local common_types = require "common_types"

local _origin_proto_map = {}
_origin_proto_map[SProto.LOGIN_PROTO] = require "login_proto"
_origin_proto_map[SProto.GAME_PROTO] = require "game_proto"

module(SProto)

SProto.ProtoMap = {}

SProto.LOGIN_PROTO = 1
SProto.GAME_PROTO = 2

for k,v in pairs(_origin_proto_map) do
	local localTypes = v.types or ""
	SProto.ProtoMap[k] = sparser.parsers common_types .. localTypes .. v.c2s .. v.s2c
	sprotoloader.save(SProto.ProtoMap[k], k)
end


