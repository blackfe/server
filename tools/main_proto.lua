
package.cpath = "../skynet/luaclib/?.so"
package.path = "./?.lua;../skynet/lualib/?.lua;../common/?.lua;../Utils/?.lua"

local sparser = require "sprotoparser"
--local sprotoloader = require "sprotoloader"

local _header = [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

local _origin_proto_map = {}

if SProto then
	return SProto
end

SProto = {}

SProto.ProtoMap = {}

SProto.LOGIN_PROTO = 1
SProto.GAME_PROTO = 2
SProto.UPLOAD_PROTO = 3
_origin_proto_map[SProto.LOGIN_PROTO] = require "login_proto"
_origin_proto_map[SProto.GAME_PROTO] = require "game_proto"
_origin_proto_map[SProto.UPLOAD_PROTO] = require "upload_proto"
for k,v in pairs(_origin_proto_map) do

	SProto.ProtoMap[k] = sparser.parse(_header..v.data)
	--sprotoloader.save(SProto.ProtoMap[k], k)
end

return SProto
